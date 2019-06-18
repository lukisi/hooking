using Gee;
using Netsukuku;
using Netsukuku.Hooking;
using TaskletSystem;

namespace SystemPeer
{
    class HookingCoordinator : Object, ICoordinator
    {
        public HookingCoordinator(int local_identity_index)
        {
            this.local_identity_index = local_identity_index;
        }
        private int local_identity_index;
        private IdentityData? _identity_data;
        public IdentityData identity_data {
            get {
                _identity_data = find_local_identity_by_index(local_identity_index);
                if (_identity_data == null) tasklet.exit_tasklet();
                return _identity_data;
            }
        }

        public Object evaluate_enter(Object evaluate_enter_data) throws CoordProxyError
        {
            assert(identity_data.proxy_endpoints != null);
            string endpoint = identity_data.proxy_endpoints[levels];
            string send_pathname = @"conn_$(endpoint)";
            string client_address = ""; string next = "";
            for (int i = 0; i < levels; i++)
            {
                client_address = @"$(client_address)$(next)$(identity_data.get_my_naddr_pos(i))";
                next = ",";
            }
            var src_nic = new ClientAddressSrcNic(client_address);
            ICommStub st = get_comm_stream_system(local_identity_index, send_pathname, src_nic, true);
            Object ret;
            try {
                ret = st.evaluate_enter(evaluate_enter_data);
            } catch (StubError e) {
                warning(@"HookingCoordinator.evaluate_enter: StubError: $(e.message)");
                throw new CoordProxyError.GENERIC(@"StubError: $(e.message)");
            } catch (StreamSystemError e) {
                warning(@"HookingCoordinator.evaluate_enter: StreamSystemError: $(e.message)");
                throw new CoordProxyError.GENERIC(@"StreamSystemError: $(e.message)");
            } catch (DeserializeError e) {
                warning(@"HookingCoordinator.evaluate_enter: DeserializeError: $(e.message)");
                throw new CoordProxyError.GENERIC(@"DeserializeError: $(e.message)");
            }
            return ret;
        }

        public Object begin_enter(int lvl, Object begin_enter_data) throws CoordProxyError
        {
            assert(lvl != 0);
            assert(identity_data.proxy_endpoints != null);
            string endpoint = identity_data.proxy_endpoints[lvl];
            string send_pathname = @"conn_$(endpoint)";
            string client_address = ""; string next = "";
            for (int i = 0; i < levels; i++)
            {
                client_address = @"$(client_address)$(next)$(identity_data.get_my_naddr_pos(i))";
                next = ",";
            }
            var src_nic = new ClientAddressSrcNic(client_address);
            ICommStub st = get_comm_stream_system(local_identity_index, send_pathname, src_nic, true);
            Object ret;
            try {
                ret = st.begin_enter(new ArgLevelObj(lvl, begin_enter_data));
            } catch (StubError e) {
                warning(@"HookingCoordinator.begin_enter: StubError: $(e.message)");
                throw new CoordProxyError.GENERIC(@"StubError: $(e.message)");
            } catch (StreamSystemError e) {
                warning(@"HookingCoordinator.begin_enter: StreamSystemError: $(e.message)");
                throw new CoordProxyError.GENERIC(@"StreamSystemError: $(e.message)");
            } catch (DeserializeError e) {
                warning(@"HookingCoordinator.begin_enter: DeserializeError: $(e.message)");
                throw new CoordProxyError.GENERIC(@"DeserializeError: $(e.message)");
            }
            return ret;
        }

        public Object completed_enter(int lvl, Object completed_enter_data) throws CoordProxyError
        {
            assert(lvl != 0);
            assert(identity_data.proxy_endpoints != null);
            string endpoint = identity_data.proxy_endpoints[lvl];
            string send_pathname = @"conn_$(endpoint)";
            string client_address = ""; string next = "";
            for (int i = 0; i < levels; i++)
            {
                client_address = @"$(client_address)$(next)$(identity_data.get_my_naddr_pos(i))";
                next = ",";
            }
            var src_nic = new ClientAddressSrcNic(client_address);
            ICommStub st = get_comm_stream_system(local_identity_index, send_pathname, src_nic, true);
            Object ret;
            try {
                ret = st.completed_enter(new ArgLevelObj(lvl, completed_enter_data));
            } catch (StubError e) {
                warning(@"HookingCoordinator.completed_enter: StubError: $(e.message)");
                throw new CoordProxyError.GENERIC(@"StubError: $(e.message)");
            } catch (StreamSystemError e) {
                warning(@"HookingCoordinator.completed_enter: StreamSystemError: $(e.message)");
                throw new CoordProxyError.GENERIC(@"StreamSystemError: $(e.message)");
            } catch (DeserializeError e) {
                warning(@"HookingCoordinator.completed_enter: DeserializeError: $(e.message)");
                throw new CoordProxyError.GENERIC(@"DeserializeError: $(e.message)");
            }
            return ret;
        }

        public Object abort_enter(int lvl, Object abort_enter_data) throws CoordProxyError
        {
            assert(lvl != 0);
            assert(identity_data.proxy_endpoints != null);
            string endpoint = identity_data.proxy_endpoints[lvl];
            string send_pathname = @"conn_$(endpoint)";
            string client_address = ""; string next = "";
            for (int i = 0; i < levels; i++)
            {
                client_address = @"$(client_address)$(next)$(identity_data.get_my_naddr_pos(i))";
                next = ",";
            }
            var src_nic = new ClientAddressSrcNic(client_address);
            ICommStub st = get_comm_stream_system(local_identity_index, send_pathname, src_nic, true);
            Object ret;
            try {
                ret = st.abort_enter(new ArgLevelObj(lvl, abort_enter_data));
            } catch (StubError e) {
                warning(@"HookingCoordinator.abort_enter: StubError: $(e.message)");
                throw new CoordProxyError.GENERIC(@"StubError: $(e.message)");
            } catch (StreamSystemError e) {
                warning(@"HookingCoordinator.abort_enter: StreamSystemError: $(e.message)");
                throw new CoordProxyError.GENERIC(@"StreamSystemError: $(e.message)");
            } catch (DeserializeError e) {
                warning(@"HookingCoordinator.abort_enter: DeserializeError: $(e.message)");
                throw new CoordProxyError.GENERIC(@"DeserializeError: $(e.message)");
            }
            return ret;
        }

        public void prepare_enter(int lvl, Object prepare_enter_data)
        {
            assert(identity_data.propagation_endpoints != null);
            foreach (string endpoint in identity_data.propagation_endpoints[lvl])
            {
                string send_pathname = @"conn_$(endpoint)";
                ICommStub st = get_comm_stream_system(local_identity_index, send_pathname, new NullSrcNic(), true);
                try {
                    st.prepare_enter(new ArgLevelObj(lvl, prepare_enter_data));
                } catch (StubError e) {
                    warning(@"HookingCoordinator.prepare_enter: StubError: $(e.message)");
                } catch (StreamSystemError e) {
                    warning(@"HookingCoordinator.prepare_enter: StreamSystemError: $(e.message)");
                } catch (DeserializeError e) {
                    warning(@"HookingCoordinator.prepare_enter: DeserializeError: $(e.message)");
                }
            }
            // Finally the module Coordinator will call on this node. So this class will simulate it.
            identity_data.hook_mgr.prepare_enter(lvl, prepare_enter_data);
        }

        public void finish_enter(int lvl, Object finish_enter_data)
        {
            assert(identity_data.propagation_endpoints != null);
            foreach (string endpoint in identity_data.propagation_endpoints[lvl])
            {
                // For a more correct simulation of this broadcast propagation, the inner part
                //  of this foreach-loop should be done in a new tasklet.
                string send_pathname = @"conn_$(endpoint)";
                ICommStub st = get_comm_stream_system(local_identity_index, send_pathname, new NullSrcNic(), false);
                try {
                    st.finish_enter(new ArgLevelObj(lvl, finish_enter_data));
                } catch (StubError e) {
                    warning(@"HookingCoordinator.finish_enter: StubError: $(e.message)");
                } catch (StreamSystemError e) {
                    warning(@"HookingCoordinator.finish_enter: StreamSystemError: $(e.message)");
                } catch (DeserializeError e) {
                    warning(@"HookingCoordinator.finish_enter: DeserializeError: $(e.message)");
                }
            }
            // Finally (or, in the same time) the module Coordinator will call on this node.
            identity_data.hook_mgr.finish_enter(lvl, finish_enter_data);
        }

        public void prepare_migration(int lvl, Object prepare_migration_data)
        {
            assert(identity_data.propagation_endpoints != null);
            foreach (string endpoint in identity_data.propagation_endpoints[lvl])
            {
                string send_pathname = @"conn_$(endpoint)";
                ICommStub st = get_comm_stream_system(local_identity_index, send_pathname, new NullSrcNic(), true);
                try {
                    st.prepare_migration(new ArgLevelObj(lvl, prepare_migration_data));
                } catch (StubError e) {
                    warning(@"HookingCoordinator.prepare_migration: StubError: $(e.message)");
                } catch (StreamSystemError e) {
                    warning(@"HookingCoordinator.prepare_migration: StreamSystemError: $(e.message)");
                } catch (DeserializeError e) {
                    warning(@"HookingCoordinator.prepare_migration: DeserializeError: $(e.message)");
                }
            }
            // Finally the module Coordinator will call on this node. So this class will simulate it.
            identity_data.hook_mgr.prepare_migration(lvl, prepare_migration_data);
        }

        public void finish_migration(int lvl, Object finish_migration_data)
        {
            assert(identity_data.propagation_endpoints != null);
            foreach (string endpoint in identity_data.propagation_endpoints[lvl])
            {
                // For a more correct simulation of this broadcast propagation, the inner part
                //  of this foreach-loop should be done in a new tasklet.
                string send_pathname = @"conn_$(endpoint)";
                ICommStub st = get_comm_stream_system(local_identity_index, send_pathname, new NullSrcNic(), false);
                try {
                    st.finish_migration(new ArgLevelObj(lvl, finish_migration_data));
                } catch (StubError e) {
                    warning(@"HookingCoordinator.finish_migration: StubError: $(e.message)");
                } catch (StreamSystemError e) {
                    warning(@"HookingCoordinator.finish_migration: StreamSystemError: $(e.message)");
                } catch (DeserializeError e) {
                    warning(@"HookingCoordinator.finish_migration: DeserializeError: $(e.message)");
                }
            }
            // Finally (or, in the same time) the module Coordinator will call on this node.
            identity_data.hook_mgr.finish_migration(lvl, finish_migration_data);
        }

        public Object? get_hooking_memory(int lvl) throws CoordProxyError
        {
            debug(@"HookingCoordinator: get_hooking_memory($(lvl)).");
            if (identity_data.hooking_memory.has_key(lvl)) return identity_data.hooking_memory[lvl];
            return null;
        }

        public void set_hooking_memory(int lvl, Object memory) throws CoordProxyError
        {
            debug(@"HookingCoordinator: set_hooking_memory($(lvl)).");
            identity_data.hooking_memory[lvl] = memory;
        }

        public int get_n_nodes()
        {
            return identity_data.coord_n_nodes;
        }

        public void reserve(int host_lvl, int reserve_request_id, out int new_pos, out int new_eldership) throws CoordReserveError
        {
            assert(host_lvl != 0);
            debug(@"HookingCoordinator[$(identity_data.local_identity_index)].reserve: "
                + @"started (host_lvl=$(host_lvl), reserve_request_id=$(reserve_request_id))...");
            assert(reserve_req.size > 0);
            string rr = reserve_req.remove_at(0);
            string[] args = rr.split(",");
            if (args.length != 4) error("bad args num in reserve-req");
            int64 expected_my_id;
            if (! int64.try_parse(args[0], out expected_my_id)) error("bad args expected_my_id in reserve-req");
            int64 expected_host_lvl;
            if (! int64.try_parse(args[1], out expected_host_lvl)) error("bad args expected_host_lvl in reserve-req");
            int64 returning_new_pos;
            if (! int64.try_parse(args[2], out returning_new_pos)) error("bad args returning_new_pos in reserve-req");
            int64 returning_new_eldership;
            if (! int64.try_parse(args[3], out returning_new_eldership)) error("bad args returning_new_eldership in reserve-req");
            assert(identity_data.local_identity_index == (int)expected_my_id);
            assert(host_lvl == (int)expected_host_lvl);
            new_pos = (int)returning_new_pos;
            new_eldership = (int)returning_new_eldership;
            debug(@"                               "
                + @"returning new_pos=$(new_pos), new_eldership=$(new_eldership).");
            tester_events.add(@"HookingCoordinator:$(identity_data.local_identity_index):"
                + @"reserve($(host_lvl),$(reserve_request_id)):new_pos[$(new_pos)]:new_eldership[$(new_eldership)]");
        }

        public void delete_reserve(int host_lvl, int reserve_request_id)
        {
            error("not implemented yet");
        }
    }

    class HookingMapPaths : Object, IHookingMapPaths
    {
        public HookingMapPaths(int local_identity_index)
        {
            this.local_identity_index = local_identity_index;
        }
        private int local_identity_index;
        private IdentityData? _identity_data;
        public IdentityData identity_data {
            get {
                _identity_data = find_local_identity_by_index(local_identity_index);
                if (_identity_data == null) tasklet.exit_tasklet();
                return _identity_data;
            }
        }

        public int64 get_network_id()
        {
            return identity_data.get_fp_of_my_gnode(levels-1);
        }

        public int get_n_nodes()
        {
            return identity_data.circa_n_nodes;
        }

        public int get_levels()
        {
            return levels;
        }

        public int get_gsize(int level)
        {
            return gsizes[level];
        }

        public int get_epsilon(int level)
        {
            int delta_levels = 1;
            int delta_exp = g_exp[level+delta_levels-1];
            while (delta_exp < 6 && level+delta_levels < levels)
            {
                delta_levels++;
                delta_exp += g_exp[level+delta_levels-1];
            }
            return delta_levels;
        }

        public int get_my_pos(int level)
        {
            return identity_data.get_my_naddr_pos(level);
        }

        public int get_my_eldership(int level)
        {
            return identity_data.get_eldership_of_my_gnode(level);
        }

        public int get_subnetlevel()
        {
            return 0;
        }

        public Gee.List<IPairHCoordInt> adjacent_to_my_gnode(int level_adjacent_gnodes, int level_my_gnode)
        {
            debug(@"HookingMapPaths: adjacent_to_my_gnode(level_adjacent_gnodes=$(level_adjacent_gnodes), level_my_gnode=$(level_my_gnode)).");
            ArrayList<IPairHCoordInt> ret = new ArrayList<IPairHCoordInt>();
            if (identity_data.adj.has_key(level_my_gnode))
                foreach (IPairHCoordInt i in identity_data.adj[level_my_gnode])
                if (i.get_hc_adjacent().lvl == level_adjacent_gnodes) ret.add(i);
            debug(@"HookingMapPaths: adjacent_to_my_gnode returning $(ret.size) elements.");
            tester_events.add(@"HookingMapPaths:$(identity_data.local_identity_index):"
                + @"adjacent_to_my_gnode(level_adjacent_gnodes=$(level_adjacent_gnodes),level_my_gnode=$(level_my_gnode)):"
                + @"size[$(ret.size)]");
            return ret;
        }

        public bool exists(int level, int pos)
        {
            assert(identity_data.gateways.has_key(level));
            if (identity_data.gateways[level].has_key(pos)) return true;
            return false;
        }

        public IHookingManagerStub? gateway(int level, int pos,
            CallerInfo? received_from=null,
            IHookingManagerStub? failed=null)
        {
            // If there is a (previous) failed stub, remove the physical arc it was based on.
            if (failed != null)
            {
                IdentityArc ia = ((HookingManagerStubHolder)failed).ia;
                assert(identity_data.gateways.has_key(level));
                if (identity_data.gateways[level].has_key(pos))
                    identity_data.gateways[level][pos].remove(ia);
                identity_data.identity_arcs.remove(ia);
            }
            // Search a gateway to reach (level, pos) excluding received_from
            NodeID? received_from_nodeid = null;
            if (received_from != null)
            {
                IdentityArc? caller_ia = skeleton_factory.from_caller_get_identityarc(received_from, identity_data);
                if (caller_ia != null) received_from_nodeid = caller_ia.peer_nodeid;
            }
            ArrayList<IdentityArc> available_gw = new ArrayList<IdentityArc>();
            assert(identity_data.gateways.has_key(level));
            if (identity_data.gateways[level].has_key(pos))
                available_gw.add_all(identity_data.gateways[level][pos]);
            while (! available_gw.is_empty)
            {
                IdentityArc gw = available_gw[0];
                NodeID gw_nodeid = gw.peer_nodeid;
                if (received_from_nodeid != null && received_from_nodeid.equals(gw_nodeid))
                {
                    available_gw.remove_at(0);
                    continue;
                }
                // found a gateway, excluding received_from
                break;
            }
            if (available_gw.is_empty) return null; // no more paths.
            IdentityArc gw_ia = available_gw[0];
            IAddressManagerStub addrstub = stub_factory.get_stub_identity_aware_unicast_from_ia(gw_ia, false);
            return new HookingManagerStubHolder(addrstub, gw_ia);
        }

        public int get_eldership(int level, int pos)
        {
            debug(@"HookingMapPaths[$(identity_data.local_identity_index)].get_eldership(($(level),$(pos))): started.");
            return identity_data.eldership[level][pos];
        }
    }

    class HookingIdentityArc : Object, IIdentityArc
    {
        public HookingIdentityArc(int local_identity_index, IdentityArc ia)
        {
            this.local_identity_index = local_identity_index;
            this.ia = ia;
        }
        private int local_identity_index;
        private IdentityData? _identity_data;
        public IdentityData identity_data {
            get {
                _identity_data = find_local_identity_by_index(local_identity_index);
                if (_identity_data == null) tasklet.exit_tasklet();
                return _identity_data;
            }
        }

        public IdentityArc ia;

        public IHookingManagerStub get_stub()
        {
            IAddressManagerStub addrstub = stub_factory.get_stub_identity_aware_unicast_from_ia(ia, true);
            return new HookingManagerStubHolder(addrstub, ia);
        }
    }

    class HookingPairHCoordInt : Object, IPairHCoordInt
    {
        public HookingPairHCoordInt(int level_my_gnode, int border_real_pos, HCoord hc)
        {
            this.level_my_gnode = level_my_gnode;
            this.border_real_pos = border_real_pos;
            this.hc = hc;
        }

        private int level_my_gnode;
        private int border_real_pos;
        private HCoord hc;

        public HCoord get_hc_adjacent()
        {
            return hc;
        }

        public int get_level_my_gnode()
        {
            return level_my_gnode;
        }

        public int get_pos_my_border_gnode()
        {
            return border_real_pos;
        }
    }
}