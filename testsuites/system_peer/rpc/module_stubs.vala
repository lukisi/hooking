using Gee;
using Netsukuku;
using Netsukuku.Hooking;
using TaskletSystem;

namespace SystemPeer
{
    class HookingManagerStubHolder : Object, IHookingManagerStub
    {
        public HookingManagerStubHolder(IAddressManagerStub addr, IdentityArc ia)
        {
            this.addr = addr;
            this.ia = ia;
        }

        private IAddressManagerStub addr;
        public IdentityArc? ia;

        private void log_call(string m_name)
        {
            print(@"HookingManager: Identity #$(ia.identity_data.local_identity_index): [$(printabletime())] calling $(m_name)");
            print(@" unicast to nodeid $(ia.peer_nodeid.id).\n");
        }

        public INetworkData retrieve_network_data(bool ask_coord)
        throws HookingNotPrincipalError, NotBootstrappedError, StubError, DeserializeError
        {
            log_call("retrieve_network_data");
            return addr.hooking_manager.retrieve_network_data(ask_coord);
        }

        public IEntryData search_migration_path(int lvl)
        throws NoMigrationPathFoundError, MigrationPathExecuteFailureError, NotBootstrappedError, StubError, DeserializeError
        {
            log_call("search_migration_path");
            return addr.hooking_manager.search_migration_path(lvl);
        }

        public void
        route_delete_reserve_request(IDeleteReservationRequest p0)
        throws StubError, DeserializeError
        {
            log_call("route_delete_reserve_request");
            addr.hooking_manager.route_delete_reserve_request(p0);
        }

        public void
        route_explore_request(IExploreGNodeRequest p0)
        throws StubError, DeserializeError
        {
            log_call("route_explore_request");
            addr.hooking_manager.route_explore_request(p0);
        }

        public void
        route_explore_response(IExploreGNodeResponse p1)
        throws StubError, DeserializeError
        {
            log_call("route_explore_response");
            addr.hooking_manager.route_explore_response(p1);
        }

        public void
        route_mig_request(IRequestPacket p0)
        throws StubError, DeserializeError
        {
            log_call("route_mig_request");
            addr.hooking_manager.route_mig_request(p0);
        }

        public void
        route_mig_response(IResponsePacket p1)
        throws StubError, DeserializeError
        {
            log_call("route_mig_response");
            addr.hooking_manager.route_mig_response(p1);
        }

        public void
        route_search_error(ISearchMigrationPathErrorPkt p2)
        throws StubError, DeserializeError
        {
            log_call("route_search_error");
            addr.hooking_manager.route_search_error(p2);
        }

        public void
        route_search_request(ISearchMigrationPathRequest p0)
        throws StubError, DeserializeError
        {
            log_call("route_search_request");
            addr.hooking_manager.route_search_request(p0);
        }

        public void
        route_search_response(ISearchMigrationPathResponse p1)
        throws StubError, DeserializeError
        {
            log_call("route_search_response");
            addr.hooking_manager.route_search_response(p1);
        }
    }
}