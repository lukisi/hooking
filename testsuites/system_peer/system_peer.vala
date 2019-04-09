using Netsukuku.Hooking;

using Gee;
using Netsukuku;
using TaskletSystem;

namespace SystemPeer
{
    string json_string_object(Object obj)
    {
        Json.Node n = Json.gobject_serialize(obj);
        Json.Generator g = new Json.Generator();
        g.root = n;
        string ret = g.to_data(null);
        return ret;
    }

    string topology;
    string firstaddr;
    int pid;
    [CCode (array_length = false, array_null_terminated = true)]
    string[] interfaces;
    [CCode (array_length = false, array_null_terminated = true)]
    string[] arcs;
    [CCode (array_length = false, array_null_terminated = true)]
    string[] _tasks;
    [CCode (array_length = false, array_null_terminated = true)]
    string[] _reserve_req;

    ITasklet tasklet;
    HashMap<int,IdentityData> local_identities;
    SkeletonFactory skeleton_factory;
    StubFactory stub_factory;
    HashMap<string,PseudoNetworkInterface> pseudonic_map;
    ArrayList<PseudoArc> arc_list;
    ArrayList<string> reserve_req;
    int next_local_identity_index = 0;
    ArrayList<int> gsizes;
    ArrayList<int> g_exp;
    int levels;
    ArrayList<string> tester_events;

    IdentityData create_local_identity(NodeID nodeid, int local_identity_index)
    {
        if (local_identities == null) local_identities = new HashMap<int,IdentityData>();
        assert(! (nodeid.id in local_identities.keys));
        IdentityData ret = new IdentityData(nodeid, local_identity_index);
        local_identities[nodeid.id] = ret;
        return ret;
    }

    IdentityData? find_local_identity(NodeID nodeid)
    {
        assert(local_identities != null);
        if (nodeid.id in local_identities.keys) return local_identities[nodeid.id];
        return null;
    }

    IdentityData? find_local_identity_by_index(int local_identity_index)
    {
        assert(local_identities != null);
        foreach (IdentityData id in local_identities.values)
            if (id.local_identity_index == local_identity_index)
            return id;
        return null;
    }

    void remove_local_identity(NodeID nodeid)
    {
        assert(local_identities != null);
        assert(nodeid.id in local_identities.keys);
        local_identities.unset(nodeid.id);
    }

    int main(string[] _args)
    {
        pid = 0; // default
        topology = "1,1,1,2"; // default
        firstaddr = ""; // default
        OptionContext oc = new OptionContext("<options>");
        OptionEntry[] entries = new OptionEntry[8];
        int index = 0;
        entries[index++] = {"topology", '\0', 0, OptionArg.STRING, ref topology, "Topology in bits. Default: 1,1,1,2", null};
        entries[index++] = {"firstaddr", '\0', 0, OptionArg.STRING, ref firstaddr, "First address. E.g. '0,0,1,3'. Default is random.", null};
        entries[index++] = {"pid", 'p', 0, OptionArg.INT, ref pid, "Fake PID (e.g. -p 1234).", null};
        entries[index++] = {"interfaces", 'i', 0, OptionArg.STRING_ARRAY, ref interfaces, "Interface (e.g. -i eth1). You can use it multiple times.", null};
        entries[index++] = {"arcs", 'a', 0, OptionArg.STRING_ARRAY, ref arcs, "Arc my_dev,peer_pid,peer_dev,cost (e.g. -a eth1,5678,eth0,300). You can use it multiple times.", null};
        entries[index++] = {"reserve-req", '\0', 0, OptionArg.STRING_ARRAY, ref _reserve_req, "Expected request for Coord.reserve()", null};
        entries[index++] = {"tasks", 't', 0, OptionArg.STRING_ARRAY, ref _tasks,
                "Task. You can use it multiple times.\n\t\t\t " +
                "E.g.: -t add_idarc,2000,1,0,1 means: after 2000 ms add an identity-arc\n\t\t\t " +
                "on arc #1 from my identity #0 to peer's identity #1.\n\t\t\t " +
                "See readme for docs on each task.", null};
        entries[index++] = { null };
        oc.add_main_entries(entries, null);
        try {
            oc.parse(ref _args);
        }
        catch (OptionError e) {
            print(@"Error parsing options: $(e.message)\n");
            return 1;
        }

        ArrayList<string> args = new ArrayList<string>.wrap(_args);
        tester_events = new ArrayList<string>();

        // Topoplogy of the network.
        gsizes = new ArrayList<int>();
        g_exp = new ArrayList<int>();
        string[] topology_bits_array = topology.split(",");
        foreach (string s_topology_bits in topology_bits_array)
        {
            int64 topology_bits;
            if (! int64.try_parse(s_topology_bits, out topology_bits)) error("Bad arg topology");
            int _g_exp = (int)topology_bits;

            if (_g_exp < 1 || _g_exp > 16) error(@"Bad g_exp $(_g_exp): must be between 1 and 16");
            int gsize = 1 << _g_exp;
            g_exp.add(_g_exp);
            gsizes.add(gsize);
        }
        levels = gsizes.size;
        ArrayList<int> naddr = new ArrayList<int>();
        // If first address is forced:
        if (firstaddr != "")
        {
            string[] firstaddr_array = firstaddr.split(",");
            if (firstaddr_array.length != levels) error("Bad first address");
            for (int i = 0; i < levels; i++)
            {
                string s_firstaddr_part = firstaddr_array[i];
                int64 i_firstaddr_part;
                if (! int64.try_parse(s_firstaddr_part, out i_firstaddr_part)) error("Bad first address");
                if (i_firstaddr_part < 0 || i_firstaddr_part > gsizes[i]-1) error("Bad first address");
                naddr.add((int)i_firstaddr_part);
            }
        }

        // Names of the network interfaces to do RPC.
        ArrayList<string> devs = new ArrayList<string>();
        foreach (string dev in interfaces) devs.add(dev);

        // Definitions of the node-arcs.
        ArrayList<string> pseudo_arc_mydev_list = new ArrayList<string>();
        ArrayList<int> pseudo_arc_peerpid_list = new ArrayList<int>();
        ArrayList<string> pseudo_arc_peerdev_list = new ArrayList<string>();
        ArrayList<long> pseudo_arc_cost_list = new ArrayList<long>();
        foreach (string arc in arcs)
        {
            string[] arc_items = arc.split(",");
            if (arc_items.length != 4) error("bad args num in '--arcs'");
            string arc_item_my_dev = arc_items[0];
            if (! (arc_item_my_dev in devs)) error("bad arg my_dev in '--arcs'");
            int64 _arc_item_peer_pid;
            if (! int64.try_parse(arc_items[1], out _arc_item_peer_pid)) error("bad arg peer_pid in '--arcs'");
            if ((int)_arc_item_peer_pid == pid) error("bad arg peer_pid in '--arcs'");
            string arc_item_peer_dev = arc_items[2];
            int64 _arc_item_cost;
            if (! int64.try_parse(arc_items[3], out _arc_item_cost)) error("bad arg cost in '--arcs'");
            pseudo_arc_mydev_list.add(arc_item_my_dev);
            pseudo_arc_peerpid_list.add((int)_arc_item_peer_pid);
            pseudo_arc_peerdev_list.add(arc_item_peer_dev);
            pseudo_arc_cost_list.add((long)_arc_item_cost);
        }

        ArrayList<string> tasks = new ArrayList<string>();
        foreach (string task in _tasks) tasks.add(task);

        reserve_req = new ArrayList<string>();
        foreach (string rr in _reserve_req) reserve_req.add(rr);

        if (pid == 0) error("Bad usage");
        if (devs.is_empty) error("Bad usage");

        // Initialize tasklet system
        PthTaskletImplementer.init();
        tasklet = PthTaskletImplementer.get_tasklet_system();

        // Initialize modules that have remotable methods (serializable classes need to be registered).
        HookingManager.init(tasklet);
        typeof(IdentityAwareSourceID).class_peek();
        typeof(IdentityAwareUnicastID).class_peek();
        typeof(IdentityAwareBroadcastID).class_peek();
        typeof(NeighbourSrcNic).class_peek();
        typeof(NullSourceID).class_peek();
        typeof(NullUnicastID).class_peek();
        typeof(ClientAddressSrcNic).class_peek();
        typeof(ArgBeginEnter).class_peek();
        typeof(ArgCompletedEnter).class_peek();
        typeof(ArgAbortEnter).class_peek();

        // Initialize pseudo-random number generators.
        string _seed = @"$(pid)";
        uint32 seed_prn = (uint32)_seed.hash();
        PRNGen.init_rngen(null, seed_prn);
        HookingManager.init_rngen(null, seed_prn);

        // If first address is random:
        if (firstaddr == "")
            for (int i = 0; i < levels; i++)
                naddr.add((int)PRNGen.int_range(0, gsizes[i]));

        // Pass tasklet system to the RPC library (ntkdrpc)
        init_tasklet_system(tasklet);

        // RPC
        skeleton_factory = new SkeletonFactory();
        stub_factory = new StubFactory();
        comm_skeleton_factory = new CommSkeletonFactory();

        pseudonic_map = new HashMap<string,PseudoNetworkInterface>();
        arc_list = new ArrayList<PseudoArc>();
        foreach (string dev in devs)
        {
            assert(!(dev in pseudonic_map.keys));
            string listen_pathname = @"recv_$(pid)_$(dev)";
            string send_pathname = @"send_$(pid)_$(dev)";
            string mac = fake_random_mac(pid, dev);
            // @"fe:aa:aa:$(PRNGen.int_range(10, 100)):$(PRNGen.int_range(10, 100)):$(PRNGen.int_range(10, 100))";
            print(@"INFO: mac for $(pid),$(dev) is $(mac).\n");
            PseudoNetworkInterface pseudonic = new PseudoNetworkInterface(dev, listen_pathname, send_pathname, mac);
            pseudonic_map[dev] = pseudonic;

            // Start listen datagram on dev
            skeleton_factory.start_datagram_system_listen(listen_pathname, send_pathname, new NeighbourSrcNic(mac));
            tasklet.ms_wait(1);
            print(@"started datagram_system_listen $(listen_pathname) $(send_pathname) $(mac).\n");

            // Start listen stream on linklocal
            string linklocal = fake_random_linklocal(mac);
            // @"169.254.$(PRNGen.int_range(1, 255)).$(PRNGen.int_range(1, 255))";
            print(@"INFO: linklocal for $(mac) is $(linklocal).\n");
            pseudonic.linklocal = linklocal;
            pseudonic.st_listen_pathname = @"conn_$(linklocal)";
            skeleton_factory.start_stream_system_listen(pseudonic.st_listen_pathname);
            tasklet.ms_wait(1);
            print(@"started stream_system_listen $(pseudonic.st_listen_pathname).\n");
        }
        for (int i = 0; i < pseudo_arc_mydev_list.size; i++)
        {
            string my_dev = pseudo_arc_mydev_list[i];
            int peer_pid = pseudo_arc_peerpid_list[i];
            string peer_dev = pseudo_arc_peerdev_list[i];
            long cost = pseudo_arc_cost_list[i];
            string peer_mac = fake_random_mac(peer_pid, peer_dev);
            string peer_linklocal = fake_random_linklocal(peer_mac);
            PseudoArc pseudoarc = new PseudoArc(my_dev, peer_pid, peer_mac, peer_linklocal, cost);
            arc_list.add(pseudoarc);
            print(@"INFO: arc #$(i) from $(my_dev) to pid$(peer_pid)+$(peer_dev)=$(peer_linklocal) with base cost of RTT = $(cost) usec\n");
        }

        // first id
        NodeID first_nodeid = fake_random_nodeid(pid, next_local_identity_index);
        string first_identity_name = @"$(pid)_$(next_local_identity_index)";
        print(@"INFO: nodeid for $(first_identity_name) is $(first_nodeid.id).\n");
        IdentityData first_identity_data = create_local_identity(first_nodeid, next_local_identity_index);
        main_identity_data = first_identity_data;
        ArrayList<int> my_naddr_pos = new ArrayList<int>();
        ArrayList<int> elderships = new ArrayList<int>();
        ArrayList<int> fp_list = new ArrayList<int>();
        my_naddr_pos.add_all(naddr);
        for (int i = 0; i < levels; i++)
        {
            elderships.add(0);
            fp_list.add(fake_random_fp(pid));
        }
        first_identity_data.update_my_naddr_pos_fp_list(my_naddr_pos, elderships, fp_list);
        next_local_identity_index++;

        // Start listen stream on pid_id for proxy/propagation communications
        string st_listen_pathname = @"conn_$(pid)_0";
        comm_skeleton_factory.start_stream_system_listen(st_listen_pathname, first_identity_data.local_identity_index);
        tasklet.ms_wait(1);
        print(@"started stream_system_listen $(st_listen_pathname).\n");

        first_identity_data.hook_mgr = new HookingManager(
            new HookingMapPaths(first_identity_data.local_identity_index),
            new HookingCoordinator(first_identity_data.local_identity_index));
        string addr = ""; string addrnext = "";
        for (int i = 0; i < levels; i++)
        {
            addr = @"$(addr)$(addrnext)$(first_identity_data.get_my_naddr_pos(i))";
            addrnext = ",";
        }
        string fp = @"$(fake_random_fp(pid))";
        for (int i = 0; i < levels; i++)
        {
            fp = @"$(fp),$(first_identity_data.get_fp_of_my_gnode(i))";
        }
        print(@"INFO: $(first_identity_name) has address $(addr) and fp $(fp).\n");
        tester_events.add(@"HookingManager:$(first_identity_data.local_identity_index):create_net:addr[$(addr)]:fp[$(fp)]");
        // immediately after creation, connect to signals.
        first_identity_data.hook_mgr.same_network.connect(first_identity_data.same_network);
        first_identity_data.hook_mgr.another_network.connect(first_identity_data.another_network);
        first_identity_data.hook_mgr.do_prepare_enter.connect(first_identity_data.do_prepare_enter);
        first_identity_data.hook_mgr.do_finish_enter.connect(first_identity_data.do_finish_enter);
        first_identity_data.hook_mgr.do_prepare_migration.connect(first_identity_data.do_prepare_migration);
        first_identity_data.hook_mgr.do_finish_migration.connect(first_identity_data.do_finish_migration);
        first_identity_data.hook_mgr.failing_arc.connect(first_identity_data.failing_arc);

        // First identity is immediately bootstrapped.

        first_identity_data.hook_mgr.bootstrapped(new ArrayList<IIdentityArc>());

        first_identity_data = null;

        foreach (string task in tasks)
        {
            if      (schedule_task_add_identity(task)) {}
            else if (schedule_task_add_identityarc(task)) {}
            else if (schedule_task_enter_net(task)) {}
            else if (schedule_task_add_gateway(task)) {}
            else if (schedule_task_addtag(task)) {}
            else if (schedule_task_update_n_nodes(task)) {}
            else if (schedule_task_update_coord_n_nodes(task)) {}
            else if (schedule_task_update_proxy_endpoint(task)) {}
            else if (schedule_task_update_propagation_endpoint(task)) {}
            else if (schedule_task_check_two_nodes_meet(task)) {}
            else error(@"unknown task $(task)");
        }

        // TODO

        // Register handlers for SIGINT and SIGTERM to exit
        Posix.@signal(Posix.Signal.INT, safe_exit);
        Posix.@signal(Posix.Signal.TERM, safe_exit);
        // Main loop
        while (true)
        {
            tasklet.ms_wait(100);
            if (do_me_exit) break;
        }

        // TODO

        // Remove connectivity identities.
        ArrayList<IdentityData> local_identities_copy = new ArrayList<IdentityData>();
        local_identities_copy.add_all(local_identities.values);
        foreach (IdentityData identity_data in local_identities_copy)
        {
            if (! identity_data.main_id)
            {
                // ... disconnect signal handlers of hook_mgr.
                identity_data.hook_mgr.same_network.disconnect(identity_data.same_network);
                identity_data.hook_mgr.another_network.disconnect(identity_data.another_network);
                identity_data.hook_mgr.do_prepare_enter.disconnect(identity_data.do_prepare_enter);
                identity_data.hook_mgr.do_finish_enter.disconnect(identity_data.do_finish_enter);
                identity_data.hook_mgr.do_prepare_migration.disconnect(identity_data.do_prepare_migration);
                identity_data.hook_mgr.do_finish_migration.disconnect(identity_data.do_finish_migration);
                identity_data.hook_mgr.failing_arc.disconnect(identity_data.failing_arc);

                // Stop listen stream on pid_id for proxy/propagation communications
                st_listen_pathname = @"conn_$(pid)_$(identity_data.local_identity_index)";
                comm_skeleton_factory.stop_stream_system_listen(st_listen_pathname);
                tasklet.ms_wait(1);
                print(@"stopped stream_system_listen $(st_listen_pathname).\n");

                remove_local_identity(identity_data.nodeid);
            }
        }
        local_identities_copy = null;

        // For main identity...
        assert(local_identities.keys.size == 1);
        IdentityData last_identity_data = local_identities.values.to_array()[0];
        assert(last_identity_data.main_id);

        // ... disconnect signal handlers of hook_mgr.
        last_identity_data.hook_mgr.same_network.disconnect(last_identity_data.same_network);
        last_identity_data.hook_mgr.another_network.disconnect(last_identity_data.another_network);
        last_identity_data.hook_mgr.do_prepare_enter.disconnect(last_identity_data.do_prepare_enter);
        last_identity_data.hook_mgr.do_finish_enter.disconnect(last_identity_data.do_finish_enter);
        last_identity_data.hook_mgr.do_prepare_migration.disconnect(last_identity_data.do_prepare_migration);
        last_identity_data.hook_mgr.do_finish_migration.disconnect(last_identity_data.do_finish_migration);
        last_identity_data.hook_mgr.failing_arc.disconnect(last_identity_data.failing_arc);

        // Stop listen stream on pid_id for proxy/propagation communications
        st_listen_pathname = @"conn_$(pid)_$(last_identity_data.local_identity_index)";
        comm_skeleton_factory.stop_stream_system_listen(st_listen_pathname);
        tasklet.ms_wait(1);
        print(@"stopped stream_system_listen $(st_listen_pathname).\n");

        remove_local_identity(last_identity_data.nodeid);
        last_identity_data = null;
        main_identity_data = null;

        ArrayList<string> final_devs = new ArrayList<string>();
        final_devs.add_all(pseudonic_map.keys);
        foreach (string dev in final_devs)
        {
            PseudoNetworkInterface pseudonic = pseudonic_map[dev];
            skeleton_factory.stop_stream_system_listen(pseudonic.st_listen_pathname);
            print(@"stopped stream_system_listen $(pseudonic.st_listen_pathname).\n");
            skeleton_factory.stop_datagram_system_listen(pseudonic.listen_pathname);
            print(@"stopped datagram_system_listen $(pseudonic.listen_pathname).\n");
            pseudonic_map.unset(dev);
        }
        skeleton_factory = null;

        PthTaskletImplementer.kill();

        print("Exiting. Event list:\n");
        foreach (string s in tester_events) print(@"$(s)\n");

        return 0;
    }

    bool do_me_exit = false;
    void safe_exit(int sig)
    {
        // We got here because of a signal. Quick processing.
        do_me_exit = true;
    }

    class PseudoNetworkInterface : Object
    {
        public PseudoNetworkInterface(string dev, string listen_pathname, string send_pathname, string mac)
        {
            this.dev = dev;
            this.listen_pathname = listen_pathname;
            this.send_pathname = send_pathname;
            this.mac = mac;
        }
        public string mac {get; private set;}
        public string send_pathname {get; private set;}
        public string listen_pathname {get; private set;}
        public string dev {get; private set;}
        public string linklocal {get; set;}
        public string st_listen_pathname {get; set;}
    }

    class PseudoArc : Object
    {
        public PseudoArc(string my_dev, int peer_pid, string peer_mac, string peer_linklocal, long cost)
        {
            assert(pseudonic_map.has_key(my_dev));
            my_nic = pseudonic_map[my_dev];
            this.peer_pid = peer_pid;
            this.peer_mac = peer_mac;
            this.peer_linklocal = peer_linklocal;
            this.cost = cost;
        }
        public PseudoNetworkInterface my_nic {get; private set;}
        public int peer_pid {get; private set;}
        public string peer_mac {get; private set;}
        public string peer_linklocal {get; private set;}
        public long cost {get; set;}
    }

    string fake_random_mac(int pid, string dev)
    {
        string _seed = @"$(pid)_$(dev)";
        uint32 seed_prn = (uint32)_seed.hash();
        Rand _rand = new Rand.with_seed(seed_prn);
        return @"fe:aa:aa:$(_rand.int_range(10, 100)):$(_rand.int_range(10, 100)):$(_rand.int_range(10, 100))";
    }

    string fake_random_linklocal(string mac)
    {
        uint32 seed_prn = (uint32)mac.hash();
        Rand _rand = new Rand.with_seed(seed_prn);
        return @"169.254.$(_rand.int_range(1, 255)).$(_rand.int_range(1, 255))";
    }

    int fake_random_fp(int pid)
    {
        string _seed = @"$(pid)";
        uint32 seed_prn = (uint32)_seed.hash();
        Rand _rand = new Rand.with_seed(seed_prn);
        return _rand.int_range(10000, 99999);
    }

    NodeID fake_random_nodeid(int pid, int node_index)
    {
        string _seed = @"$(pid)_$(node_index)";
        uint32 seed_prn = (uint32)_seed.hash();
        Rand _rand = new Rand.with_seed(seed_prn);
        return new NodeID((int)(_rand.int_range(1, 100000)));
    }

    IdentityData main_identity_data;
    class IdentityData : Object
    {
        public IdentityData(NodeID nodeid, int local_identity_index)
        {
            this.local_identity_index = local_identity_index;
            this.nodeid = nodeid;
            identity_arcs = new ArrayList<IdentityArc>();
            connectivity_from_level = 0;
            connectivity_to_level = 0;
            copy_of_identity = null;
            gateways = new HashMap<int,HashMap<int,ArrayList<IdentityArc>>>();
            for (int i = 0; i < levels; i++) gateways[i] = new HashMap<int,ArrayList<IdentityArc>>();
            my_naddr_pos = null;
            elderships = null;
            fp_list = null;
            circa_n_nodes = 1;
            proxy_endpoints = null;
            propagation_endpoints = null;
            coord_n_nodes = 1;
            hooking_memory = new HashMap<int,Object>();
        }

        public int local_identity_index;

        public NodeID nodeid;
        public int connectivity_from_level;
        public int connectivity_to_level;
        public weak IdentityData? copy_of_identity;
        public bool main_id {
            get {
                return this == main_identity_data;
            }
        }

        public HookingManager hook_mgr;

        private ArrayList<int> my_naddr_pos;
        private ArrayList<int> elderships;
        private ArrayList<int> fp_list;
        public int get_my_naddr_pos(int lvl) {return my_naddr_pos[lvl];}
        public int get_eldership_of_my_gnode(int lvl) {return elderships[lvl];}
        public int get_fp_of_my_gnode(int lvl) {return fp_list[lvl];}
        public int circa_n_nodes;

        // coord endpoints
        public ArrayList<string> proxy_endpoints;
        // If I want to call evaluate_enter [always to coord(levels)] I will set send_pathname=proxy_endpoints[levels];
        // If I want to call begin_enter to coord(lvl) I will set send_pathname=proxy_endpoints[lvl];
        // Note: there is a useless proxy_endpoints[0].
        public ArrayList<ArrayList<string>> propagation_endpoints;
        // If I want to call prepare_enter/finish_enter to all nodes in my g-node lvl I will
        // do foreach (string s in propagation_endpoints[lvl]) set send_pathname=s;
        // Note: there is a useless propagation_endpoints[0].

        // coord data
        public int coord_n_nodes;
        public HashMap<int,Object> hooking_memory;

        // must be called after updating main_identity_data
        public void update_my_naddr_pos_fp_list(Gee.List<int> my_naddr_pos, Gee.List<int> elderships, Gee.List<int> fp_list)
        {
            // bool first_identity: if TRUE it means that this is the first identity of the system.
            bool first_identity = copy_of_identity == null;
            // bool initialization: if TRUE it means that this is the very beginning of the life of this identity.
            //  If it is ALSO first_identity, then it means also that it is (by def) the main identity right now, on a network by itself.
            bool initialization = this.my_naddr_pos == null;
            if (first_identity && initialization)
            {
                // This is the beginning of first identity.
                assert(main_id);
                assert(this.my_naddr_pos == null);
                assert(this.elderships == null);
                assert(this.fp_list == null);
                assert(my_naddr_pos.size == levels);
                assert(elderships.size == levels);
                assert(fp_list.size == levels);
                this.my_naddr_pos = new ArrayList<int>();
                this.my_naddr_pos.add_all(my_naddr_pos);
                this.elderships = new ArrayList<int>();
                this.elderships.add_all(elderships);
                this.fp_list = new ArrayList<int>();
                this.fp_list.add_all(fp_list);
            }
            else if (first_identity) // && !initialization
            {
                // This is related to the old identity during a migration. Because during a enter_net
                //  the old identity simply is dismissed after a little while.
                //  In this case, also, the old identity was the first identity.
                assert(!main_id);
                error("not implemented yet");
            }
            else if (initialization && main_id) // && !first_identity
            {
                // This is the beginning of a new identity from the previous main identity. It may happen
                //  for a migration or a enter_net.
                assert(this.my_naddr_pos == null);
                assert(this.elderships == null);
                assert(this.fp_list == null);
                assert(my_naddr_pos.size == levels);
                assert(elderships.size == levels);
                assert(fp_list.size == levels);
                this.my_naddr_pos = new ArrayList<int>();
                this.my_naddr_pos.add_all(my_naddr_pos);
                this.elderships = new ArrayList<int>();
                this.elderships.add_all(elderships);
                this.fp_list = new ArrayList<int>();
                this.fp_list.add_all(fp_list);
            }
            else if (initialization) // && !main_id && !first_identity
            {
                // This is the beginning of a new identity from a previous non-main identity. It may happen
                //  for a migration or a enter_net.
                error("not implemented yet");
            }
            else // !initialization && !main_id && !first_identity
            {
                // This is related to the old identity during a migration. Because during a enter_net
                //  the old identity simply is dismissed after a little while.
                //  In this case the old identity was not the first identity.
                assert(!main_id);
                error("not implemented yet");
            }
        }

        public HashMap<int,HashMap<int,ArrayList<IdentityArc>>> gateways;
        // gateways[3][2][0] means the best gateway to (3,2).

        public ArrayList<IdentityArc> identity_arcs;
        public IdentityArc? identity_arcs_find(PseudoArc arc, NodeID peer_nodeid)
        {
            assert(identity_arcs != null);
            foreach (IdentityArc ia in identity_arcs)
                if (ia.arc == arc && ia.peer_nodeid.equals(peer_nodeid))
                return ia;
            return null;
        }

        // handle signals from HookingManager

        public void same_network(IIdentityArc ia)
        {
            per_identity_hooking_same_network(this, ia);
        }

        public void another_network(IIdentityArc ia, int64 network_id)
        {
            per_identity_hooking_another_network(this, ia, network_id);
        }

        public void do_prepare_enter(int enter_id)
        {
            per_identity_hooking_do_prepare_enter(this, enter_id);
        }

        public void do_finish_enter(int enter_id, int guest_gnode_level, EntryData entry_data, int go_connectivity_position)
        {
            per_identity_hooking_do_finish_enter(this, enter_id, guest_gnode_level, entry_data, go_connectivity_position);
        }

        public void do_prepare_migration(int migration_id)
        {
            per_identity_hooking_do_prepare_migration(this, migration_id);
        }

        public void do_finish_migration(int migration_id, int guest_gnode_level, EntryData migration_data, int go_connectivity_position)
        {
            per_identity_hooking_do_finish_migration(this, migration_id, guest_gnode_level, migration_data, go_connectivity_position);
        }

        public void failing_arc(IIdentityArc ia)
        {
            per_identity_hooking_failing_arc(this, ia);
        }
    }

    class IdentityArc : Object
    {
        private int local_identity_index;
        private IdentityData? _identity_data;
        public IdentityData identity_data {
            get {
                _identity_data = find_local_identity_by_index(local_identity_index);
                if (_identity_data == null) tasklet.exit_tasklet();
                return _identity_data;
            }
        }
        public PseudoArc arc;
        public NodeID peer_nodeid;

        public IdentityArc(int local_identity_index, PseudoArc arc, NodeID peer_nodeid)
        {
            this.local_identity_index = local_identity_index;
            this.arc = arc;
            this.peer_nodeid = peer_nodeid;
        }
    }

    string printabletime()
    {
        TimeVal now = TimeVal();
        now.get_current_time();
        string s_usec = @"$(now.tv_usec + 1000000)";
        s_usec = s_usec.substring(1);
        string s_sec = @"$(now.tv_sec)";
        s_sec = s_sec.substring(s_sec.length-3);
        return @"$(s_sec).$(s_usec)";
    }
}