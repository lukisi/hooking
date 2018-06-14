/*
 *  This file is part of Netsukuku.
 *  Copyright (C) 2017-2018 Luca Dionisi aka lukisi <luca.dionisi@gmail.com>
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
using Netsukuku;
using TaskletSystem;

namespace Netsukuku.Hooking
{
    internal string json_string_object(Object obj)
    {
        Json.Node n = Json.gobject_serialize(obj);
        Json.Generator g = new Json.Generator();
        g.root = n;
        string ret = g.to_data(null);
        return ret;
    }

    internal Object dup_object(Object obj)
    {
        Type type = obj.get_type();
        string t = json_string_object(obj);
        Json.Parser p = new Json.Parser();
        try {
            assert(p.load_from_data(t));
        } catch (Error e) {assert_not_reached();}
        Object ret = Json.gobject_deserialize(type, p.get_root());
        return ret;
    }

    internal ITasklet tasklet;
    public class HookingManager : Object, IHookingManagerSkeleton
    {
        public static void init(ITasklet _tasklet)
        {
            // Register serializable types
            typeof(EntryData).class_peek();
            tasklet = _tasklet;
        }

        public static void init_rngen(IRandomNumberGenerator? rngen=null, uint32? seed=null)
        {
            PRNGen.init_rngen(rngen, seed);
        }

        private Gee.List<IIdentityArc> arc_list;
        private IHookingMapPaths map_paths;
        private int levels;
        private Gee.List<int> gsizes;
        private Gee.List<int> my_pos;
        private int subnetlevel;
        private MessageRouting.MessageRouting message_routing;

        public signal void same_network(IIdentityArc ia);
        public signal void another_network(IIdentityArc ia, int64 network_id);
        public signal void do_prepare_enter(int enter_id);
        public signal void do_finish_enter(int enter_id, int guest_gnode_level, EntryData entry_data, int go_connectivity_position);
        public signal void do_prepare_migration(/* TODO */);
        public signal void do_finish_migration(/* TODO */);

        public HookingManager(IHookingMapPaths map_paths, int subnetlevel)
        {
            arc_list = new ArrayList<IIdentityArc>();
            this.map_paths = map_paths;
            levels = map_paths.get_levels();
            my_pos = new ArrayList<int>();
            gsizes = new ArrayList<int>();
            for (int i = 0; i < levels; i++)
            {
                my_pos.add(map_paths.get_my_pos(i));
                gsizes.add(map_paths.get_gsize(i));
            }
            this.subnetlevel = subnetlevel;
            message_routing = new MessageRouting.MessageRouting
                (map_paths, execute_search, execute_explore, execute_delete_reserve);
        }

        private bool tuple_has_virtual_pos(TupleGNode t)
        {
            int d = levels - t.pos.size;
            for (int i = d; i < levels; i++)
                if (t.pos[i - d] >= gsizes[i])
                    return true;
            return false;
        }

        private void execute_search
        (TupleGNode visiting_gnode,
        int max_host_lvl, int reserve_request_id,
        out int min_host_lvl, out int? final_host_lvl, out int? real_new_pos, out int? real_new_eldership,
        out Gee.List<PairTupleGNodeInt>? set_adjacent, out int? new_conn_vir_pos, out int? new_eldership)
        {
            error("not implemented yet");
        }

        private void execute_explore
        (int requested_lvl, out TupleGNode result)
        {
            error("not implemented yet");
        }

        private void execute_delete_reserve
        (TupleGNode dest_gnode, int reserve_request_id)
        {
            error("not implemented yet");
        }

        public void add_arc(IIdentityArc ia)
        {
            // TODO
            arc_list.add(ia);
        }

        public void remove_arc(IIdentityArc ia)
        {
            // TODO
        }

        private Gee.List<Solution> find_shortest_mig(int reserve_request_id, int first_host_lvl, int ok_host_lvl)
        {
            if (first_host_lvl <= subnetlevel) first_host_lvl = subnetlevel + 1;
            if (ok_host_lvl < first_host_lvl) ok_host_lvl = first_host_lvl;
            TupleGNode v = make_tuple_from_level(first_host_lvl, map_paths);
            int max_host_lvl = levels;
            ArrayList<Solution> solutions = new ArrayList<Solution>();
            int prev_sol_distance = -1;

            ArrayList<TupleGNode> S = new ArrayList<TupleGNode>(positions_equal);
            LinkedList<SolutionStep> Q = new LinkedList<SolutionStep>();

            S.add(v);
            SolutionStep root = new SolutionStep(v);
            Q.offer(root);

            while (! Q.is_empty)
            {
                SolutionStep current = Q.poll();
                if (prev_sol_distance != -1 &&
                    prev_sol_distance + 5 <= current.get_distance() &&
                    prev_sol_distance * 1.3 <= current.get_distance()
                    ) break;
                int min_host_lvl;
                int? final_host_lvl;
                int? real_new_pos;
                int? real_new_eldership;
                Gee.List<PairTupleGNodeInt>? set_adjacent;
                int? new_conn_vir_pos;
                int? new_eldership;
                try {
                    message_routing.send_search_request
                    (current, max_host_lvl, reserve_request_id,
                    out min_host_lvl, out final_host_lvl, out real_new_pos, out real_new_eldership,
                    out set_adjacent, out new_conn_vir_pos, out new_eldership);
                } catch (MessageRouting.SearchMigrationPathError e) {
                    S.remove(current.visiting_gnode);
                    continue;
                }
                if (min_host_lvl > levels)
                {
                    // invalid response
                    continue;
                }
                if (min_host_lvl > max_host_lvl)
                {
                    // no possibilities for this migration-path.
                    continue;
                }
                current.visiting_gnode = make_tuple_up_to_level(current.visiting_gnode, min_host_lvl, map_paths);
                if (final_host_lvl <= ok_host_lvl)
                {
                    // This solution is enough, we won't search further on.
                    Solution sol = new Solution(current, final_host_lvl, real_new_pos, real_new_eldership);
                    solutions.add(sol);
                    return solutions;
                }
                if (min_host_lvl == final_host_lvl)
                {
                    // This is a solution. No further possibilities for this migration-path.
                    Solution sol = new Solution(current, final_host_lvl, real_new_pos, real_new_eldership);
                    solutions.add(sol);
                    prev_sol_distance = sol.leaf.get_distance();
                    max_host_lvl = final_host_lvl - 1;
                    continue;
                }
                if (final_host_lvl <= max_host_lvl)
                {
                    // This is a solution. We can further extend this migration-path.
                    Solution sol = new Solution(current, final_host_lvl, real_new_pos, real_new_eldership);
                    solutions.add(sol);
                    prev_sol_distance = sol.leaf.get_distance();
                    max_host_lvl = final_host_lvl - 1;
                }
                // process adjacent g-nodes of current.visiting_gnode.
                foreach (PairTupleGNodeInt n_and_borderpos in set_adjacent)
                {
                    TupleGNode n = n_and_borderpos.t;
                    int border_real_pos = n_and_borderpos.i;
                    if (level(n, map_paths) > min_host_lvl)
                    {
                        try {
                            message_routing.send_explore_request(current, n, min_host_lvl, out n);
                        } catch (MessageRouting.ExploreGNodeError e) {
                            // next iteration
                            continue;
                        }
                    }
                    if (level(n, map_paths) != min_host_lvl)
                    {
                        // next iteration
                        continue;
                    }
                    if (tuple_has_virtual_pos(n))
                    {
                        // next iteration
                        continue;
                    }
                    if (! (n in S))
                    {
                        // The level of host g-node (min_host_lvl) may rise during a given
                        //  path. We need to ensure that we didn't encounter `n` or its inner g-nodes.
                        SolutionStep? prev_step = current;
                        bool in_prev_step = false;
                        while (prev_step != null)
                        {
                            TupleGNode prev_step_gnode = prev_step.visiting_gnode;
                            TupleGNode prev_step_gnode_bigger = make_tuple_up_to_level(prev_step_gnode, min_host_lvl, map_paths);
                            if (positions_equal(prev_step_gnode_bigger, n))
                            {
                                in_prev_step = true;
                                break;
                            }
                            prev_step = prev_step.parent;
                        }
                        if (! in_prev_step)
                        {
                            // TODO
                            S.add(n);
                            TupleGNode previous_migrating_gnode = (TupleGNode)dup_object(current.visiting_gnode);
                            previous_migrating_gnode.pos.insert(0,border_real_pos);
                            previous_migrating_gnode.eldership.insert(0,-1);
                            SolutionStep n_step = new SolutionStep
                                (n,
                                previous_migrating_gnode,
                                new_conn_vir_pos,
                                new_eldership,
                                current);
                            Q.offer(n_step);
                        }
                    }
                }
            }
            return solutions;
        }

        /* Remotable methods
         */

        public INetworkData
        retrieve_network_data(bool ask_coord,
                    CallerInfo? _rpc_caller=null)
        throws HookingNotPrincipalError
        {
            error("not implemented yet");
        }

        public IEntryData
        search_migration_path(int lvl,
                    CallerInfo? _rpc_caller=null)
        throws NoMigrationPathFoundError, MigrationPathExecuteFailureError
        {
            error("not implemented yet");
        }

        public void
        route_search_request (ISearchMigrationPathRequest p0,
                    CallerInfo? _rpc_caller=null)
        {
            if (! (p0 is SearchMigrationPathRequest)) return; // ignore bad pkt.
            message_routing.route_search_request((SearchMigrationPathRequest)p0);
        }

        public void
        route_search_error (ISearchMigrationPathErrorPkt p2,
                    CallerInfo? _rpc_caller=null)
        {
            if (! (p2 is SearchMigrationPathErrorPkt)) return; // ignore bad pkt.
            message_routing.route_search_error((SearchMigrationPathErrorPkt)p2);
        }

        public void
        route_search_response (ISearchMigrationPathResponse p1,
                    CallerInfo? _rpc_caller=null)
        {
            if (! (p1 is SearchMigrationPathResponse)) return; // ignore bad pkt.
            message_routing.route_search_response((SearchMigrationPathResponse)p1);
        }

        public void
        route_explore_request (IExploreGNodeRequest p0,
                    CallerInfo? _rpc_caller=null)
        {
            if (! (p0 is ExploreGNodeRequest)) return; // ignore bad pkt.
            message_routing.route_explore_request((ExploreGNodeRequest)p0);
        }

        public void
        route_explore_response (IExploreGNodeResponse p1,
                    CallerInfo? _rpc_caller=null)
        {
            if (! (p1 is ExploreGNodeResponse)) return; // ignore bad pkt.
            message_routing.route_explore_response((ExploreGNodeResponse)p1);
        }

        public void
        route_mig_request (IRequestPacket p0,
                    CallerInfo? _rpc_caller=null)
        {
            error("not implemented yet");
        }

        public void
        route_mig_response (IResponsePacket p1,
                    CallerInfo? _rpc_caller=null)
        {
            error("not implemented yet");
        }

        public void
        route_delete_reserve_request (IDeleteReservationRequest p0,
                    CallerInfo? _rpc_caller=null)
        {
            if (! (p0 is DeleteReservationRequest)) return; // ignore bad pkt.
            message_routing.route_delete_reserve_request((DeleteReservationRequest)p0);
        }

    }
}
