using Gee;
using Netsukuku;
using Netsukuku.Hooking;
using TaskletSystem;

namespace SystemPeer
{
    bool schedule_task_update_n_nodes(string task)
    {
        if (task.has_prefix("update_n_nodes,"))
        {
            string remain = task.substring("update_n_nodes,".length);
            string[] args = remain.split(",");
            if (args.length != 3) error("bad args num in task 'update_n_nodes'");
            int64 ms_wait;
            if (! int64.try_parse(args[0], out ms_wait)) error("bad args ms_wait in task 'update_n_nodes'");
            int64 my_id;
            if (! int64.try_parse(args[1], out my_id)) error("bad args my_id in task 'update_n_nodes'");
            int64 n_nodes;
            if (! int64.try_parse(args[2], out n_nodes)) error("bad args n_nodes in task 'update_n_nodes'");
            print(@"INFO: in $(ms_wait) ms will update n_nodes=$(n_nodes) to identity #$(my_id).\n");
            UpdateNnodesTasklet s = new UpdateNnodesTasklet(
                (int)ms_wait,
                (int)my_id,
                (int)n_nodes);
            tasklet.spawn(s);
            return true;
        }
        else return false;
    }

    class UpdateNnodesTasklet : Object, ITaskletSpawnable
    {
        public UpdateNnodesTasklet(
            int ms_wait,
            int my_id,
            int n_nodes)
        {
            this.ms_wait = ms_wait;
            this.my_id = my_id;
            this.n_nodes = n_nodes;
        }
        private int ms_wait;
        private int my_id;
        private int n_nodes;

        public void * func()
        {
            tasklet.ms_wait(ms_wait);

            // find identity_data
            NodeID nodeid = fake_random_nodeid(pid, my_id);
            IdentityData identity_data = find_local_identity(nodeid);
            assert(identity_data != null);
            identity_data.circa_n_nodes = n_nodes;

            return null;
        }
    }
}