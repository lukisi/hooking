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

        private void log_resp(string m_name)
        {
            print(@"HookingManager: Identity #$(ia.identity_data.local_identity_index): [$(printabletime())] response for $(m_name)");
            print(@" from nodeid $(ia.peer_nodeid.id).\n");
        }

        public INetworkData retrieve_network_data(bool ask_coord)
        throws HookingNotPrincipalError, NotBootstrappedError, StubError, DeserializeError
        {
            log_call("retrieve_network_data");
            print(@"   with ask_coord=$(ask_coord).\n");
            tester_events.add(@"HookingManager:$(ia.identity_data.local_identity_index):call_retrieve_network_data(ask_coord=$(ask_coord))");
            return addr.hooking_manager.retrieve_network_data(ask_coord);
        }

        public IEntryData search_migration_path(int lvl)
        throws NoMigrationPathFoundError, MigrationPathExecuteFailureError, NotBootstrappedError, StubError, DeserializeError
        {
            log_call("search_migration_path");
            print(@"   with lvl=$(lvl).\n");
            tester_events.add(@"HookingManager:$(ia.identity_data.local_identity_index):call_search_migration_path(lvl=$(lvl))");
            IEntryData ret = null;
            try {
                ret = addr.hooking_manager.search_migration_path(lvl);
                assert(ret is EntryData);
                EntryData _ret = (EntryData)ret;
                string s_pos = ""; string next = "";
                foreach (int p in _ret.pos)
                {
                    s_pos = @"$(s_pos)$(next)$(p)";
                    next = ",";
                }
                string s_elderships = ""; next = "";
                foreach (int e in _ret.elderships)
                {
                    s_elderships = @"$(s_elderships)$(next)$(e)";
                    next = ",";
                }
                string s_entry_data = @"{netid:$(_ret.network_id),pos:[$(s_pos)],elderships:[$(s_elderships)]}";
                log_resp("search_migration_path");
                print(@"   returned $(s_entry_data).\n");
                tester_events.add(@"HookingManager:$(ia.identity_data.local_identity_index):response_search_migration_path:"
                    + @"ret=$(s_entry_data)");
            } catch (NoMigrationPathFoundError e) {
                log_resp("search_migration_path");
                print(@"   returned NoMigrationPathFoundError: $(e.message).\n");
                tester_events.add(@"HookingManager:$(ia.identity_data.local_identity_index):response_search_migration_path:"
                    + @"NoMigrationPathFoundError:$(e.message)");
                throw e;
            } catch (MigrationPathExecuteFailureError e) {
                log_resp("search_migration_path");
                print(@"   returned MigrationPathExecuteFailureError: $(e.message).\n");
                tester_events.add(@"HookingManager:$(ia.identity_data.local_identity_index):response_search_migration_path:"
                    + @"MigrationPathExecuteFailureError:$(e.message)");
                throw e;
            } catch (NotBootstrappedError e) {
                log_resp("search_migration_path");
                print(@"   returned NotBootstrappedError: $(e.message).\n");
                tester_events.add(@"HookingManager:$(ia.identity_data.local_identity_index):response_search_migration_path:"
                    + @"NotBootstrappedError:$(e.message)");
                throw e;
            } catch (StubError e) {
                 log_resp("search_migration_path");
                print(@"   returned StubError: $(e.message).\n");
                tester_events.add(@"HookingManager:$(ia.identity_data.local_identity_index):response_search_migration_path:"
                    + @"StubError:$(e.message)");
               throw e;
            } catch (DeserializeError e) {
                log_resp("search_migration_path");
                print(@"   returned DeserializeError: $(e.message).\n");
                tester_events.add(@"HookingManager:$(ia.identity_data.local_identity_index):response_search_migration_path:"
                    + @"DeserializeError:$(e.message)");
                throw e;
            }
            return ret;
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