/*
 *  This file is part of Netsukuku.
 *  Copyright (C) 2018 Luca Dionisi aka lukisi <luca.dionisi@gmail.com>
 *
 *  Netsukuku is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  Netsukuku is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Netsukuku.  If not, see <http://www.gnu.org/licenses/>.
 */

using Gee;
using TaskletSystem;
using Netsukuku.Hooking;

namespace Netsukuku.Hooking.MessageRouting
{
    internal errordomain SearchMigrationPathError {
        GENERIC
    }

    internal delegate void ExecuteSearchDelegate
        (TupleGNode visiting_gnode,
        int max_host_lvl, int reserve_request_id,
        out int min_host_lvl, out int? final_host_lvl, out int? real_new_pos, out int? real_new_eldership,
        out Gee.List<PairTupleGNodeInt>? set_adjacent, out int? new_conn_vir_pos, out int? new_eldership);

    internal class MessageRouting : Object
    {
        private IHookingMapPaths map_paths;
        private int levels;
        private Gee.List<int> gsizes;
        private Gee.List<int> my_pos;
        private HashMap<int, IChannel> request_id_map;
        private ExecuteSearchDelegate execute_search;

        public MessageRouting(IHookingMapPaths map_paths, owned ExecuteSearchDelegate execute_search)
        {
            this.map_paths = map_paths;
            levels = map_paths.get_levels();
            my_pos = new ArrayList<int>();
            gsizes = new ArrayList<int>();
            for (int i = 0; i < levels; i++)
            {
                my_pos.add(map_paths.get_my_pos(i));
                gsizes.add(map_paths.get_gsize(i));
            }
            this.execute_search = (owned) execute_search;
            request_id_map = new HashMap<int, IChannel>();
        }

        private int my_pos_highest_virtual_level()
        {
            for (int i = levels - 1; i >= 0; i--)
                if (my_pos[i] >= gsizes[i])
                    return i;
            return -1;
        }

        public void send_search_request
        (SolutionStep current,
        int max_host_lvl, int reserve_request_id,
        out int min_host_lvl, out int? final_host_lvl, out int? real_new_pos, out int? real_new_eldership,
        out Gee.List<PairTupleGNodeInt>? set_adjacent, out int? new_conn_vir_pos, out int? new_eldership)
        throws SearchMigrationPathError
        {
            Gee.List<PathHop> path_hops = get_path_hops(current);
            if (path_hops.size == 1)
            {
                execute_search(path_hops[0].visiting_gnode, max_host_lvl, reserve_request_id,
                    out min_host_lvl, out final_host_lvl, out real_new_pos, out real_new_eldership,
                    out set_adjacent, out new_conn_vir_pos, out new_eldership);
                return;
            }
            // prepare packet to send
            SearchMigrationPathRequest p0 = new SearchMigrationPathRequest
                (path_hops, max_host_lvl, reserve_request_id);
            // prepare to receive response
            p0.origin = make_tuple_from_level(0, map_paths);
            p0.caller = make_tuple_from_level(0, map_paths);
            p0.pkt_id = PRNGen.int_range(0, int.MAX);
            IChannel ch = tasklet.get_channel();
            request_id_map[p0.pkt_id] = ch;
            // send request
            make_tuple_from_level(1,map_paths);
            IHookingManagerStub st = best_gw_to(p0.path_hops[1].visiting_gnode, map_paths);
            try {
                st.route_search_request(p0);
            } catch (StubError e) {
                // nop.
            } catch (DeserializeError e) {
                // nop.
            }
            // wait response with timeout
            Object resp;
            int timeout = 100000; // TODO
            try {
                resp = (Object)ch.recv_with_timeout(timeout);
                if (! (resp is SearchMigrationPathResponse))
                    throw new SearchMigrationPathError.GENERIC("Got error packet.");
            } catch (ChannelError e) {
                // TIMEOUT_EXPIRED
                throw new SearchMigrationPathError.GENERIC("Timeout.");
            }
            SearchMigrationPathResponse response = (SearchMigrationPathResponse)resp;
            min_host_lvl = response.min_host_lvl;
            final_host_lvl = response.final_host_lvl;
            real_new_pos = response.real_new_pos;
            real_new_eldership = response.real_new_eldership;
            set_adjacent = response.set_adjacent;
            new_conn_vir_pos = response.new_conn_vir_pos;
            new_eldership = response.new_eldership;
        }

        public void route_search_request(SearchMigrationPathRequest p0)
        {
            // check pkt
            if (p0.path_hops.size < 2) return; // ignore bad pkt
            if (i_am_inside(p0.path_hops[1].visiting_gnode, map_paths))
            {
                // check adjacency
                bool adjacency = tuple_contains(p0.caller, p0.path_hops[1].previous_migrating_gnode);
                adjacency = adjacency && tuple_contains(p0.path_hops[1].previous_migrating_gnode, p0.path_hops[0].visiting_gnode);
                adjacency = adjacency && level(p0.path_hops[1].previous_migrating_gnode, map_paths) + 1
                                         == level(p0.path_hops[0].visiting_gnode, map_paths);
                if (! adjacency)
                {
                    // send error in routing
                    SearchMigrationPathErrorPkt p1 = new SearchMigrationPathErrorPkt();
                    p1.origin = p0.origin;
                    p1.pkt_id = p0.pkt_id;
                    IHookingManagerStub st = best_gw_to(p1.origin, map_paths);
                    try {
                        st.route_search_error(p1);
                    } catch (StubError e) {
                        // nop.
                    } catch (DeserializeError e) {
                        // nop.
                    }
                    return;
                }
                if (p0.path_hops.size > 2)
                {
                    p0.caller = make_tuple_from_level(0, map_paths);
                    p0.path_hops.remove_at(0);
                    // route request
                    IHookingManagerStub st = best_gw_to(p0.path_hops[1].visiting_gnode, map_paths);
                    try {
                        st.route_search_request(p0);
                    } catch (StubError e) {
                        // nop.
                    } catch (DeserializeError e) {
                        // nop.
                    }
                    return;
                }
                // check I am real
                int lvl_next = my_pos_highest_virtual_level();
                if (lvl_next == -1)
                {
                    // I am real
                    p0.path_hops.remove_at(0);
                    SearchMigrationPathResponse p1 = new SearchMigrationPathResponse();
                    p1.origin = p0.origin;
                    p1.pkt_id = p0.pkt_id;
                    int? p1_min_host_lvl;
                    int? p1_final_host_lvl;
                    int? p1_real_new_pos;
                    int? p1_real_new_eldership;
                    Gee.List<PairTupleGNodeInt> p1_set_adjacent;
                    int? p1_new_conn_vir_pos;
                    int? p1_new_eldership;
                    execute_search(p0.path_hops[0].visiting_gnode, p0.max_host_lvl, p0.reserve_request_id,
                        out p1_min_host_lvl, out p1_final_host_lvl, out p1_real_new_pos, out p1_real_new_eldership,
                        out p1_set_adjacent, out p1_new_conn_vir_pos, out p1_new_eldership);
                    p1.min_host_lvl = p1_min_host_lvl;
                    p1.final_host_lvl = p1_final_host_lvl;
                    p1.real_new_pos = p1_real_new_pos;
                    p1.real_new_eldership = p1_real_new_eldership;
                    p1.set_adjacent = p1_set_adjacent;
                    p1.new_conn_vir_pos = p1_new_conn_vir_pos;
                    p1.new_eldership = p1_new_eldership;
                    // send response
                    IHookingManagerStub st = best_gw_to(p1.origin, map_paths);
                    try {
                        st.route_search_response(p1);
                    } catch (StubError e) {
                        // nop.
                    } catch (DeserializeError e) {
                        // nop.
                    }
                    return;
                }
                else
                {
                    // Must find a real node
                    for (int pos_next = 0; pos_next < gsizes[lvl_next]; pos_next++)
                    {
                        if (map_paths.exists(lvl_next, pos_next))
                        {
                            // route request
                            IHookingManagerStub st = map_paths.gateway(lvl_next, pos_next);
                            try {
                                st.route_search_request(p0);
                            } catch (StubError e) {
                                // nop.
                            } catch (DeserializeError e) {
                                // nop.
                            }
                            return;
                        }
                    }
                    // If I am virtual at lvl_next there must be a real one at that level.
                    assert_not_reached();
                }
            }
            else
            {
                if (! i_am_inside(p0.path_hops[0].visiting_gnode, map_paths))
                {
                    // send error in routing
                    SearchMigrationPathErrorPkt p1 = new SearchMigrationPathErrorPkt();
                    p1.origin = p0.origin;
                    p1.pkt_id = p0.pkt_id;
                    IHookingManagerStub st = best_gw_to(p1.origin, map_paths);
                    try {
                        st.route_search_error(p1);
                    } catch (StubError e) {
                        // nop.
                    } catch (DeserializeError e) {
                        // nop.
                    }
                    return;
                }
                p0.caller = make_tuple_from_level(0, map_paths);
                // route request
                IHookingManagerStub st = best_gw_to(p0.path_hops[1].visiting_gnode, map_paths);
                try {
                    st.route_search_request(p0);
                } catch (StubError e) {
                    // nop.
                } catch (DeserializeError e) {
                    // nop.
                }
                return;
            }
        }

        public void route_search_error(SearchMigrationPathErrorPkt p)
        {
            if (positions_equal(make_tuple_from_level(0, map_paths), p.origin))
            {
                // deliver
                if (! request_id_map.has_key(p.pkt_id)) return;
                IChannel ch = request_id_map[p.pkt_id];
                ch.send(p);
                return;
            }
            // route error
            IHookingManagerStub st = best_gw_to(p.origin, map_paths);
            try {
                st.route_search_error(p);
            } catch (StubError e) {
                // nop.
            } catch (DeserializeError e) {
                // nop.
            }
            return;
        }

        public void route_search_response(SearchMigrationPathResponse p)
        {
            if (positions_equal(make_tuple_from_level(0, map_paths), p.origin))
            {
                // deliver
                if (! request_id_map.has_key(p.pkt_id)) return;
                IChannel ch = request_id_map[p.pkt_id];
                ch.send(p);
                return;
            }
            // route error
            IHookingManagerStub st = best_gw_to(p.origin, map_paths);
            try {
                st.route_search_response(p);
            } catch (StubError e) {
                // nop.
            } catch (DeserializeError e) {
                // nop.
            }
            return;
        }
    }
}
