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

        public Gee.List<IIdentityArc> arc_list;

        public signal void same_network(IIdentityArc ia);
        public signal void another_network(IIdentityArc ia, int64 network_id);
        public signal void do_prepare_enter(int enter_id);
        public signal void do_finish_enter(int enter_id, int guest_gnode_level, EntryData entry_data, int go_connectivity_position);
        public signal void do_prepare_migration(/* TODO */);
        public signal void do_finish_migration(/* TODO */);

        public HookingManager()
        {
            arc_list = new ArrayList<IIdentityArc>();
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
        route_delete_reserve_request (Netsukuku.IDeleteReservationRequest p0,
                    CallerInfo? _rpc_caller=null)
        {
            error("not implemented yet");
        }

        public void
        route_explore_request (Netsukuku.IExploreGNodeRequest p0,
                    CallerInfo? _rpc_caller=null)
        {
            error("not implemented yet");
        }

        public void
        route_explore_response (Netsukuku.IExploreGNodeResponse p1,
                    CallerInfo? _rpc_caller=null)
        {
            error("not implemented yet");
        }

        public void
        route_mig_request (Netsukuku.IRequestPacket p0,
                    CallerInfo? _rpc_caller=null)
        {
            error("not implemented yet");
        }

        public void
        route_mig_response (Netsukuku.IResponsePacket p1,
                    CallerInfo? _rpc_caller=null)
        {
            error("not implemented yet");
        }

        public void
        route_search_error (Netsukuku.ISearchMigrationPathErrorPkt p2,
                    CallerInfo? _rpc_caller=null)
        {
            error("not implemented yet");
        }

        public void
        route_search_request (Netsukuku.ISearchMigrationPathRequest p0,
                    CallerInfo? _rpc_caller=null)
        {
            error("not implemented yet");
        }

        public void
        route_search_response (Netsukuku.ISearchMigrationPathResponse p1,
                    CallerInfo? _rpc_caller=null)
        {
            error("not implemented yet");
        }

    }
}
