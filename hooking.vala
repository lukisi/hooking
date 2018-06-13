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
        private MessageRouting.MessageRouting message_routing;

        public signal void same_network(IIdentityArc ia);
        public signal void another_network(IIdentityArc ia, int64 network_id);
        public signal void do_prepare_enter(int enter_id);
        public signal void do_finish_enter(int enter_id, int guest_gnode_level, EntryData entry_data, int go_connectivity_position);
        public signal void do_prepare_migration(/* TODO */);
        public signal void do_finish_migration(/* TODO */);

        public HookingManager(IHookingMapPaths map_paths)
        {
            arc_list = new ArrayList<IIdentityArc>();
            this.map_paths = map_paths;
            message_routing = new MessageRouting.MessageRouting
                (map_paths, execute_search, execute_explore, execute_delete_reserve);
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
