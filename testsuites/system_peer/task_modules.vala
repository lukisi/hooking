using Gee;
using Netsukuku;
using Netsukuku.Hooking;
using TaskletSystem;

namespace SystemPeer
{
    bool schedule_task_enter_net(string task)
    {
        if (task.has_prefix("enter_net,"))
        {
            string remain = task.substring("enter_net,".length);
            string[] args = remain.split(",");
            if (args.length != 7) error("bad args num in task 'enter_net'");
            int64 ms_wait;
            if (! int64.try_parse(args[0], out ms_wait)) error("bad args ms_wait in task 'enter_net'");
            int64 my_old_id;
            if (! int64.try_parse(args[1], out my_old_id)) error("bad args my_old_id in task 'enter_net'");
            int64 my_new_id;
            if (! int64.try_parse(args[2], out my_new_id)) error("bad args my_new_id in task 'enter_net'");
            int64 guest_level;
            if (! int64.try_parse(args[3], out guest_level)) error("bad args guest_level in task 'enter_net'");
            ArrayList<int> in_g_naddr = new ArrayList<int>();
            int host_level;
            {
                string[] parts = args[4].split(":");
                host_level = levels - (parts.length - 1);
                if (host_level <= guest_level) error("bad parts num in in_g_naddr in task 'enter_net'");
                for (int i = 0; i < parts.length; i++)
                {
                    int64 element;
                    if (! int64.try_parse(parts[i], out element)) error("bad parts element in in_g_naddr in task 'enter_net'");
                    in_g_naddr.add((int)element);
                }
            }
            ArrayList<int> in_g_elderships = new ArrayList<int>();
            {
                string[] parts = args[5].split(":");
                if (host_level != levels - (parts.length - 1)) error("bad parts num in in_g_elderships in task 'enter_net'");
                for (int i = 0; i < parts.length; i++)
                {
                    int64 element;
                    if (! int64.try_parse(parts[i], out element)) error("bad parts element in in_g_elderships in task 'enter_net'");
                    in_g_elderships.add((int)element);
                }
            }
            ArrayList<int> in_g_fp_list = new ArrayList<int>();
            {
                string[] parts = args[6].split(":");
                if (host_level != levels - (parts.length - 1)) error("bad parts num in in_g_fp_list in task 'enter_net'");
                for (int i = 0; i < parts.length; i++)
                {
                    int64 element;
                    if (! int64.try_parse(parts[i], out element)) error("bad parts element in in_g_fp_list in task 'enter_net'");
                    in_g_fp_list.add(fake_random_fp((int)element));
                }
            }

            string addrnext = "";
            string addr = "";
            foreach (int pos in in_g_naddr)
            {
                addr = @"$(addr)$(addrnext)$(pos)";
                addrnext = ",";
            }
            string fp = @"$(fake_random_fp(pid))";
            foreach (int _fp in in_g_fp_list)
            {
                fp = @"$(fp),$(_fp)";
            }
            print(@"INFO: in $(ms_wait) msec my g-node of level $(guest_level) will enter new network as addr[$(addr)], fp[$(fp)].\n");
            EnterNetTasklet s = new EnterNetTasklet(
                (int)ms_wait,
                (int)my_old_id,
                (int)my_new_id,
                (int)guest_level,
                host_level,
                in_g_naddr,
                in_g_elderships,
                in_g_fp_list);
            tasklet.spawn(s);
            return true;
        }
        else return false;
    }

    class EnterNetTasklet : Object, ITaskletSpawnable
    {
        public EnterNetTasklet(
            int ms_wait,
            int my_old_id,
            int my_new_id,
            int guest_level,
            int host_level,
            ArrayList<int> in_g_naddr,
            ArrayList<int> in_g_elderships,
            ArrayList<int> in_g_fp_list)
        {
            this.ms_wait = ms_wait;
            this.my_old_id = my_old_id;
            this.my_new_id = my_new_id;
            this.guest_level = guest_level;
            this.host_level = host_level;
            this.in_g_naddr = in_g_naddr;
            this.in_g_elderships = in_g_elderships;
            this.in_g_fp_list = in_g_fp_list;
        }
        private int ms_wait;
        private int my_old_id;
        private int my_new_id;
        private int guest_level;
        private int host_level;
        private ArrayList<int> in_g_naddr;
        private ArrayList<int> in_g_elderships;
        private ArrayList<int> in_g_fp_list;

        public void * func()
        {
            tasklet.ms_wait(ms_wait);

            // find old_id
            NodeID old_nodeid = fake_random_nodeid(pid, my_old_id);
            IdentityData old_identity_data = find_local_identity(old_nodeid);
            assert(old_identity_data != null);

            // find new_id
            NodeID new_nodeid = fake_random_nodeid(pid, my_new_id);
            IdentityData new_identity_data = find_local_identity(new_nodeid);
            assert(new_identity_data != null);

            ArrayList<int> my_naddr_pos = new ArrayList<int>();
            ArrayList<int> elderships = new ArrayList<int>();
            ArrayList<int> fp_list = new ArrayList<int>();

            for (int i = 0; i < host_level-1; i++)
                my_naddr_pos.add(old_identity_data.get_my_naddr_pos(i));
            for (int i = host_level-1; i < levels; i++)
                my_naddr_pos.add(in_g_naddr[i-(host_level-1)]);

            for (int i = 0; i < guest_level; i++) elderships.add(old_identity_data.get_eldership_of_my_gnode(i));
            for (int i = guest_level; i < host_level-1; i++)  elderships.add(0);
            for (int i = host_level-1; i < levels; i++) elderships.add(in_g_elderships[i-(host_level-1)]);

            int prev_level_fp = fake_random_fp(pid);
            for (int i = 0; i < guest_level; i++)
            {
                fp_list.add(old_identity_data.get_fp_of_my_gnode(i));
                prev_level_fp = old_identity_data.get_fp_of_my_gnode(i);
            }
            for (int i = guest_level; i < host_level-1; i++)
            {
                fp_list.add(prev_level_fp);
            }
            for (int i = host_level-1; i < levels; i++)
            {
                fp_list.add(in_g_fp_list[i-(host_level-1)]);
            }

            new_identity_data.update_my_naddr_pos_fp_list(my_naddr_pos, elderships, fp_list);

            // Another hooking manager
            new_identity_data.hook_mgr = new HookingManager(
                new HookingMapPaths(new_identity_data.local_identity_index),
                new HookingCoordinator(new_identity_data.local_identity_index));

            string addr = ""; string addrnext = "";
            for (int i = 0; i < levels; i++)
            {
                addr = @"$(addr)$(addrnext)$(new_identity_data.get_my_naddr_pos(i))";
                addrnext = ",";
            }
            string fp = @"$(fake_random_fp(pid))";
            for (int i = 0; i < levels; i++)
            {
                fp = @"$(fp),$(new_identity_data.get_fp_of_my_gnode(i))";
            }
            tester_events.add(@"PeersManager:$(new_identity_data.local_identity_index):enter_net:addr[$(addr)]:fp[$(fp)]");
            // immediately after creation, connect to signals.
            new_identity_data.hook_mgr.same_network.connect(new_identity_data.same_network);
            new_identity_data.hook_mgr.another_network.connect(new_identity_data.another_network);
            new_identity_data.hook_mgr.do_prepare_enter.connect(new_identity_data.do_prepare_enter);
            new_identity_data.hook_mgr.do_finish_enter.connect(new_identity_data.do_finish_enter);
            new_identity_data.hook_mgr.do_prepare_migration.connect(new_identity_data.do_prepare_migration);
            new_identity_data.hook_mgr.do_finish_migration.connect(new_identity_data.do_finish_migration);
            new_identity_data.hook_mgr.failing_arc.connect(new_identity_data.failing_arc);

            print(@"INFO: New identity $(new_nodeid.id) entered with address $(addr).\n");

            // Assume bootstrapped immediately
            ArrayList<IIdentityArc> initial_arcs = new ArrayList<IIdentityArc>();
            foreach (IdentityArc ia in new_identity_data.identity_arcs)
                initial_arcs.add(new HookingIdentityArc(new_identity_data.local_identity_index, ia));
            new_identity_data.hook_mgr.bootstrapped(initial_arcs);

            new_identity_data = null;

            // Since this is a enter_net (not migrate) there's no need to do qspn.make_connectivity
            // and related old_identity_data.update_my_naddr_pos_fp_list(...).
            // The instances of modules related to old_identity_data should be (soon) dismissed and
            // the instance old_identity_data should be removed from the set local_identities.

            // wait to safely remove old_identity_data
            old_identity_data = null;
            tasklet.ms_wait(2000);
            old_identity_data = find_local_identity(old_nodeid);
            assert(old_identity_data != null);

            // remove old identity.
            old_identity_data.hook_mgr.same_network.disconnect(old_identity_data.same_network);
            old_identity_data.hook_mgr.another_network.disconnect(old_identity_data.another_network);
            old_identity_data.hook_mgr.do_prepare_enter.disconnect(old_identity_data.do_prepare_enter);
            old_identity_data.hook_mgr.do_finish_enter.disconnect(old_identity_data.do_finish_enter);
            old_identity_data.hook_mgr.do_prepare_migration.disconnect(old_identity_data.do_prepare_migration);
            old_identity_data.hook_mgr.do_finish_migration.disconnect(old_identity_data.do_finish_migration);
            old_identity_data.hook_mgr.failing_arc.disconnect(old_identity_data.failing_arc);

            remove_local_identity(old_identity_data.nodeid);

            return null;
        }
    }

    bool schedule_task_migrate(string task)
    {
        if (task.has_prefix("migrate,"))
        {
            error("not implemented yet");
        }
        else return false;
    }

    class MigrateTasklet : Object, ITaskletSpawnable
    {
        public MigrateTasklet(
            int ms_wait,
            int my_old_id,
            int my_new_id,
            int guest_level)
        {
            this.ms_wait = ms_wait;
            this.my_old_id = my_old_id;
            this.my_new_id = my_new_id;
            this.guest_level = guest_level;
        }
        private int ms_wait;
        private int my_old_id;
        private int my_new_id;
        private int guest_level;

        public void * func()
        {
            tasklet.ms_wait(ms_wait);

            // TODO

            return null;
        }
    }

    void execute_task_add_identityarc_to_module(int my_id, int arc_num, int peer_id)
    {
        // find identity_data
        NodeID nodeid = fake_random_nodeid(pid, my_id);
        IdentityData identity_data = find_local_identity(nodeid);
        assert(identity_data != null);

        // find ia
        PseudoArc pseudoarc = arc_list[arc_num];
        NodeID peer_nodeid = fake_random_nodeid(pseudoarc.peer_pid, peer_id);
        IdentityArc? ia = identity_data.identity_arcs_find(pseudoarc, peer_nodeid);
        if (ia == null) error(@"not found IdentityArc for $(arc_num)+$(peer_id)");

        identity_data.hook_mgr.add_arc(new HookingIdentityArc(identity_data.local_identity_index, ia));
    }
}