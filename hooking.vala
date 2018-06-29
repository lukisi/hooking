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

    internal int get_global_timeout(int size)
    {
        // based on size of my network
        // TODO
        return 10000;
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

        private IHookingMapPaths map_paths;
        private ICoordinator coord;
        private int levels;
        private Gee.List<int> gsizes;
        private MessageRouting.MessageRouting message_routing;
        private ArcHandler.ArcHandler arc_handler;
        private ProxyCoord.ProxyCoord proxy_coord;
        private PropagationCoord.PropagationCoord propagation_coord;

        public signal void same_network(IIdentityArc ia);
        public signal void another_network(IIdentityArc ia, int64 network_id);
        public signal void do_prepare_enter(int enter_id);
        public signal void do_finish_enter(int enter_id, int guest_gnode_level, EntryData entry_data, int go_connectivity_position);
        public signal void do_prepare_migration(/* TODO */);
        public signal void do_finish_migration(/* TODO */);

        public HookingManager(IHookingMapPaths map_paths, ICoordinator coord)
        {
            this.map_paths = map_paths;
            levels = map_paths.get_levels();
            gsizes = new ArrayList<int>();
            for (int i = 0; i < levels; i++)
                gsizes.add(map_paths.get_gsize(i));
            this.coord = coord;
            message_routing = new MessageRouting.MessageRouting
                (map_paths, execute_search, execute_explore, execute_delete_reserve, execute_mig);
            proxy_coord = new ProxyCoord.ProxyCoord(this, map_paths, coord);
            propagation_coord = new PropagationCoord.PropagationCoord(this, map_paths, coord);
            arc_handler = new ArcHandler.ArcHandler(this, map_paths, coord, proxy_coord, propagation_coord);
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
            // Assert (I am in visiting_gnode) AND (I am real). Else, ignore message.
            if (! i_am_inside(visiting_gnode, map_paths)) tasklet.exit_tasklet(null);
            if (tuple_has_virtual_pos(make_tuple_from_level(0, map_paths))) tasklet.exit_tasklet(null);
            min_host_lvl = level(visiting_gnode, map_paths);
            final_host_lvl = null;
            real_new_pos = null;
            real_new_eldership = null;
            set_adjacent = null;
            new_conn_vir_pos = null;
            new_eldership = null;
            int pos = -1;
            int eldership = -1;
            while (min_host_lvl <= max_host_lvl)
            {
                try {
                    coord.reserve(min_host_lvl, reserve_request_id, out pos, out eldership);
                } catch (CoordReserveError e) {
                    min_host_lvl++;
                    continue;
                }
                break;
            }
            if (min_host_lvl > max_host_lvl)
            {
                // this g-node cannot reserve a place inside max_host_lvl
                return;
            }
            final_host_lvl = min_host_lvl;
            if (pos < gsizes[final_host_lvl - 1])
            {
                real_new_pos = pos;
                real_new_eldership = eldership;
                return;
            }
            new_conn_vir_pos = pos;
            new_eldership = eldership;
            final_host_lvl++;
            while (final_host_lvl <= max_host_lvl)
            {
                try {
                    coord.reserve(final_host_lvl, reserve_request_id, out pos, out eldership);
                } catch (CoordReserveError e) {
                    assert_not_reached();
                }
                if (pos < gsizes[final_host_lvl - 1])
                {
                    real_new_pos = pos;
                    real_new_eldership = eldership;
                    break;
                }
                final_host_lvl++;
            }
            set_adjacent = new ArrayList<PairTupleGNodeInt>();
            for (int i = min_host_lvl; i < levels; i++)
            {
                Gee.List<IPairHCoordInt> adjacent_hc_set = map_paths.adjacent_to_my_gnode(i, min_host_lvl);
                foreach (IPairHCoordInt adjacent_hc in adjacent_hc_set)
                {
                    HCoord hc = adjacent_hc.get_hc_adjacent();
                    int border_real_pos = adjacent_hc.get_pos_my_border_gnode();
                    TupleGNode adj = make_tuple_from_hc(hc, map_paths);
                    set_adjacent.add(new PairTupleGNodeInt(adj, border_real_pos));
                }
            }
            return;
        }

        private void execute_explore
        (int requested_lvl, out TupleGNode result)
        {
            result = make_tuple_from_level(requested_lvl, map_paths);
            return;
        }

        private void execute_delete_reserve
        (TupleGNode dest_gnode, int reserve_request_id)
        {
            coord.delete_reserve(level(dest_gnode, map_paths), reserve_request_id);
            return;
        }

        private void execute_mig
        (RequestPacket p)
        {
            if (p.operation == RequestPacketType.PREPARE_MIGRATION)
            {
                int lvl = level(p.dest, map_paths);
                /* TODO
                Object prepare_migration_data = new PrepareMigrationData(p.migration_id);
                coord.prepare_migration(lvl, prepare_migration_data);
                */
            }
            else if (p.operation == RequestPacketType.FINISH_MIGRATION)
            {
                int lvl = level(p.dest, map_paths);
                /* TODO
                Object finish_migration_data = new FinishMigrationData
                    (p.migration_id,
                    p.conn_gnode_pos,
                    p.host_gnode,
                    p.real_new_pos,
                    p.real_new_eldership);
                coord.finish_migration(lvl, finish_migration_data);
                */
            }
            else
            {
                // ignore pkt
                tasklet.exit_tasklet(null);
            }
        }

        public void add_arc(IIdentityArc ia)
        {
            arc_handler.add_arc(ia);
        }

        public void remove_arc(IIdentityArc ia)
        {
            arc_handler.remove_arc(ia);
        }

        public Object evaluate_enter(Object evaluate_enter_data, Gee.List<int> client_address)
        {
            return proxy_coord.execute_proxy_evaluate_enter(evaluate_enter_data, client_address);
        }

        public Object begin_enter(int lvl, Object begin_enter_data, Gee.List<int> client_address)
        {
            return proxy_coord.execute_proxy_begin_enter(lvl, begin_enter_data, client_address);
        }

        public Object completed_enter(int lvl, Object completed_enter_data, Gee.List<int> client_address)
        {
            return proxy_coord.execute_proxy_completed_enter(lvl, completed_enter_data, client_address);
        }

        public Object abort_enter(int lvl, Object abort_enter_data, Gee.List<int> client_address)
        {
            return proxy_coord.execute_proxy_abort_enter(lvl, abort_enter_data, client_address);
        }

        public void prepare_enter(int lvl, Object prepare_enter_data)
        {
            propagation_coord.execute_propagate_prepare_enter(lvl, prepare_enter_data);
        }

        public void finish_enter(int lvl, Object finish_enter_data)
        {
            propagation_coord.execute_propagate_finish_enter(lvl, finish_enter_data);
        }

        private Gee.List<Solution> find_shortest_mig(int reserve_request_id, int first_host_lvl, int ok_host_lvl)
        {
            int subnetlevel = map_paths.get_subnetlevel();
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

        private void execute_shortest_mig(Solution sol)
        throws MigrationPathExecuteFailureError
        {
            Gee.List<MigData> migs = get_migs(sol, map_paths);
            for (int i = migs.size - 1; i >= 0; i--)
            {
                MigData mig = migs[i];
                RequestPacket p0 = build_request_packet_prepare(mig);
                message_routing.send_mig_request(mig.mig_gnode, p0);
            }
            // just for farthest step
            {
                int i = migs.size - 1;
                MigData mig = migs[i];
                RequestPacket p0 = build_request_packet_finish(mig);
                message_routing.send_mig_request(mig.mig_gnode, p0);
            }
            for (int i = migs.size - 2; i >= 0; i--)
            {
                MigData mig = migs[i];
                MigData mig_next = migs[i+1];
                RequestPacket p0 = build_request_packet_finish(mig, mig_next);
                message_routing.send_mig_request(mig.mig_gnode, p0);
            }
        }

        /* Remotable methods
         */

        public INetworkData
        retrieve_network_data(bool ask_coord,
                    CallerInfo? _rpc_caller=null)
        throws HookingNotPrincipalError
        {
            TupleGNode me = make_tuple_from_level(0, map_paths);
            if (tuple_has_virtual_pos(me)) throw new HookingNotPrincipalError.GENERIC("Not main.");
            NetworkData ret = new NetworkData();
            ret.neighbor_pos = new ArrayList<int>();
            for (int i = 0; i < levels; i++)
                ret.neighbor_pos.add(map_paths.get_my_pos(i));
            ret.gsizes = new ArrayList<int>();
            ret.gsizes.add_all(gsizes);
            ret.network_id = map_paths.get_network_id();
            ret.neighbor_min_level = map_paths.get_subnetlevel();
            ret.neighbor_n_nodes = map_paths.get_n_nodes();
            if (ask_coord) ret.neighbor_n_nodes = coord.get_n_nodes();
            return ret;
        }

        public IEntryData
        search_migration_path(int lvl,
                    CallerInfo? _rpc_caller=null)
        throws NoMigrationPathFoundError, MigrationPathExecuteFailureError
        {
            int epsilon = map_paths.get_epsilon(lvl);
            int first_host_lvl = lvl + 1;
            int ok_host_lvl = lvl + epsilon;
            int reserve_request_id = PRNGen.int_range(0, int.MAX);
            Gee.List<Solution> solutions = find_shortest_mig(reserve_request_id, first_host_lvl, ok_host_lvl);
            if (solutions.is_empty) throw new NoMigrationPathFoundError.GENERIC("You might try at lower level.");
            Solution sol = solutions.last();
            if (sol.leaf.get_distance() == 0)
            {
                // direct access, no migrations needed
                TupleGNode host_gnode = make_tuple_from_level(sol.final_host_lvl, map_paths);
                EntryData ret = new EntryData();
                ret.network_id = map_paths.get_network_id();
                ret.pos = new ArrayList<int>();
                ret.elderships = new ArrayList<int>();
                ret.pos.add_all(host_gnode.pos);
                ret.elderships.add_all(host_gnode.eldership);
                ret.pos.insert(0, sol.real_new_pos);
                ret.elderships.insert(0, sol.real_new_eldership);
                return ret;
            }
            else
            {
                execute_shortest_mig(sol); // may throw MigrationPathExecuteFailureError
                // if it succeeds
                SolutionStep root = sol.leaf.parent;
                SolutionStep second = sol.leaf;
                while (root.parent != null)
                {
                    root = root.parent;
                    second = second.parent;
                }
                TupleGNode host_gnode = root.visiting_gnode;
                EntryData ret = new EntryData();
                ret.network_id = map_paths.get_network_id();
                ret.pos = new ArrayList<int>();
                ret.elderships = new ArrayList<int>();
                ret.pos.add_all(host_gnode.pos);
                ret.elderships.add_all(host_gnode.eldership);
                ret.pos.insert(0, second.previous_migrating_gnode.pos[0]);
                ret.elderships.insert(0, second.previous_gnode_new_eldership);
                return ret;
            }
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
            if (! (p0 is RequestPacket)) return; // ignore bad pkt.
            message_routing.route_mig_request((RequestPacket)p0);
        }

        public void
        route_mig_response (IResponsePacket p1,
                    CallerInfo? _rpc_caller=null)
        {
            if (! (p1 is ResponsePacket)) return; // ignore bad pkt.
            message_routing.route_mig_response((ResponsePacket)p1);
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
