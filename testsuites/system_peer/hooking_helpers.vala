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

        public Object abort_enter(int lvl, Object abort_enter_data) throws CoordProxyError
        {
            error("not implemented yet");
        }

        public Object begin_enter(int lvl, Object begin_enter_data) throws CoordProxyError
        {
            error("not implemented yet");
        }

        public Object completed_enter(int lvl, Object completed_enter_data) throws CoordProxyError
        {
            error("not implemented yet");
        }

        public void delete_reserve(int host_lvl, int reserve_request_id)
        {
            error("not implemented yet");
        }

        public Object evaluate_enter(Object evaluate_enter_data) throws CoordProxyError
        {
            error("not implemented yet");
        }

        public void finish_enter(int lvl, Object finish_enter_data)
        {
            error("not implemented yet");
        }

        public void finish_migration(int lvl, Object finish_migration_data)
        {
            error("not implemented yet");
        }

        public Object get_hooking_memory(int lvl) throws CoordProxyError
        {
            error("not implemented yet");
        }

        public int get_n_nodes()
        {
            error("not implemented yet");
        }

        public void prepare_enter(int lvl, Object prepare_enter_data)
        {
            error("not implemented yet");
        }

        public void prepare_migration(int lvl, Object prepare_migration_data)
        {
            error("not implemented yet");
        }

        public void reserve(int host_lvl, int reserve_request_id, out int new_pos, out int new_eldership) throws CoordReserveError
        {
            error("not implemented yet");
        }

        public void set_hooking_memory(int lvl, Object memory) throws CoordProxyError
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

        public int get_epsilon(int level)
        {
            error("not implemented yet");
        }

        public int get_gsize(int level)
        {
            error("not implemented yet");
        }

        public int get_levels()
        {
            error("not implemented yet");
        }

        public int get_my_eldership(int level)
        {
            error("not implemented yet");
        }

        public int get_my_pos(int level)
        {
            error("not implemented yet");
        }

        public int get_n_nodes()
        {
            error("not implemented yet");
        }

        public int64 get_network_id()
        {
            error("not implemented yet");
        }

        public int get_subnetlevel()
        {
            error("not implemented yet");
        }
    }

    class HookingIdentityArc : Object, IIdentityArc
    {
        public HookingIdentityArc(int local_identity_index)
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

        public IdentityArc ia;

        public IHookingManagerStub get_stub()
        {
            error("not implemented yet");
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