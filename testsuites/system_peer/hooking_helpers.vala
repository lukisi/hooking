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
            ICommStub st = get_comm_stream_system(send_pathname, new NullSourceID(), new NullUnicastID(), src_nic, true);
            Object ret;
            try {
                ret = st.evaluate_enter(evaluate_enter_data);
            } catch (StubError e) {
                warning(@"StubError: $(e.message)");
                throw new CoordProxyError.GENERIC(@"StubError: $(e.message)");
            } catch (StreamSystemError e) {
                warning(@"StreamSystemError: $(e.message)");
                throw new CoordProxyError.GENERIC(@"StreamSystemError: $(e.message)");
            } catch (DeserializeError e) {
                warning(@"DeserializeError: $(e.message)");
                throw new CoordProxyError.GENERIC(@"DeserializeError: $(e.message)");
            }
            return ret;
        }

        public Object begin_enter(int lvl, Object begin_enter_data) throws CoordProxyError
        {
            assert(identity_data.proxy_endpoints != null);
            string send_pathname = identity_data.proxy_endpoints[lvl];
            error("not implemented yet");
        }

        public Object abort_enter(int lvl, Object abort_enter_data) throws CoordProxyError
        {
            assert(identity_data.proxy_endpoints != null);
            string send_pathname = identity_data.proxy_endpoints[lvl];
            error("not implemented yet");
        }

        public Object completed_enter(int lvl, Object completed_enter_data) throws CoordProxyError
        {
            assert(identity_data.proxy_endpoints != null);
            string send_pathname = identity_data.proxy_endpoints[lvl];
            error("not implemented yet");
        }

        public void prepare_enter(int lvl, Object prepare_enter_data)
        {
            assert(identity_data.propagation_endpoints != null);
            foreach (string s in identity_data.propagation_endpoints[lvl])
            {
                string send_pathname = s;
                // TODO
            }
            error("not implemented yet");
        }

        public void finish_enter(int lvl, Object finish_enter_data)
        {
            assert(identity_data.propagation_endpoints != null);
            foreach (string s in identity_data.propagation_endpoints[lvl])
            {
                string send_pathname = s;
                // TODO
            }
            error("not implemented yet");
        }

        public void prepare_migration(int lvl, Object prepare_migration_data)
        {
            assert(identity_data.propagation_endpoints != null);
            foreach (string s in identity_data.propagation_endpoints[lvl])
            {
                string send_pathname = s;
                // TODO
            }
            error("not implemented yet");
        }

        public void finish_migration(int lvl, Object finish_migration_data)
        {
            assert(identity_data.propagation_endpoints != null);
            foreach (string s in identity_data.propagation_endpoints[lvl])
            {
                string send_pathname = s;
                // TODO
            }
            error("not implemented yet");
        }

        public Object get_hooking_memory(int lvl) throws CoordProxyError
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
            error("not implemented yet");
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
            int delta_levels = 0;
            int delta_exp = g_exp[delta_levels+level];
            while (delta_exp < 6 && delta_levels+level < levels) // TODO or levels-1?
            {
                delta_levels++;
                delta_exp += g_exp[delta_levels+level];
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
            error("not implemented yet");
        }

        public bool exists(int level, int pos)
        {
            error("not implemented yet");
        }

        public IHookingManagerStub gateway(int level, int pos)
        {
            error("not implemented yet");
        }

        public int get_eldership(int level, int pos)
        {
            error("not implemented yet");
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
        public HookingPairHCoordInt(int local_identity_index)
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

        public HCoord get_hc_adjacent()
        {
            error("not implemented yet");
        }

        public int get_level_my_gnode()
        {
            error("not implemented yet");
        }

        public int get_pos_my_border_gnode()
        {
            error("not implemented yet");
        }
    }
}