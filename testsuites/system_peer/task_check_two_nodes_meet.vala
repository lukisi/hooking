using Gee;
using Netsukuku;
using Netsukuku.Hooking;
using TaskletSystem;

namespace SystemPeer
{
    bool schedule_task_check_two_nodes_meet(string task)
    {
        if (task.has_prefix("check_two_nodes_meet,"))
        {
            string remain = task.substring("check_two_nodes_meet,".length);
            string[] args = remain.split(",");
            if (args.length != 1) error("bad args num in task 'check_two_nodes_meet'");
            int64 ms_wait;
            if (! int64.try_parse(args[0], out ms_wait)) error("bad args ms_wait in task 'check_two_nodes_meet'");
            print(@"INFO: in $(ms_wait) ms will do check two_nodes_meet for pid #$(pid).\n");
            CheckTwoNodesMeetTasklet s = new CheckTwoNodesMeetTasklet(
                (int)ms_wait);
            tasklet.spawn(s);
            return true;
        }
        else return false;
    }

    class CheckTwoNodesMeetTasklet : Object, ITaskletSpawnable
    {
        public CheckTwoNodesMeetTasklet(
            int ms_wait)
        {
            this.ms_wait = ms_wait;
        }
        private int ms_wait;

        public void * func()
        {
            tasklet.ms_wait(ms_wait);

            print(@"Doing check two_nodes_meet for node $(pid).\n");

            if (pid == 100)
            {
                /*
                HookingManager:0:create_net:addr[3,3,3]:fp[54802,54802,54802,54802]
                Tester:Tag:300_id0_ready
                Tester:Tag:400_identityarc_added
                HookingManager:0:call_retrieve_network_data(ask_coord=false)
                HookingManager:0:Signal:another_network:0+0,79330
                HookingManager:0:call_retrieve_network_data(ask_coord=true)
                HookingManager:0:Signal:do_prepare_enter:777380291
                HookingManager:0:Signal:do_finish_enter:777380291
                */
                int create_net_0 = -1;
                int id0_ready = -1;
                for (int i = 0; i < tester_events.size; i++)
                {
                    if ("HookingManager:0:create_net" in tester_events[i]) create_net_0 = i;
                    if ("Tester:Tag" in tester_events[i] && "id0_ready" in tester_events[i]) id0_ready = i;
                }
                assert(create_net_0 >= 0);
                assert(id0_ready > create_net_0);
                // TODO
            }
            else if (pid == 200)
            {
                /*
                HookingManager:0:create_net:addr[2,0,0]:fp[79330,79330,79330,79330]
                Tester:Tag:300_id0_ready
                Tester:Tag:400_identityarc_added
                HookingManager:0:call_retrieve_network_data(ask_coord=false)
                HookingManager:0:Signal:another_network:0+0,54802
                HookingManager:0:call_retrieve_network_data(ask_coord=true)
                HookingCoordinator:0:reserve(1,261318919):new_pos[1]:new_eldership[1]
                Tester:Tag:5300
                HookingManager:0:call_retrieve_network_data(ask_coord=false)
                HookingManager:0:Signal:same_network:0+1
                */
                int create_net_0 = -1;
                int id0_ready = -1;
                for (int i = 0; i < tester_events.size; i++)
                {
                    if ("HookingManager:0:create_net" in tester_events[i]) create_net_0 = i;
                    if ("Tester:Tag" in tester_events[i] && "id0_ready" in tester_events[i]) id0_ready = i;
                }
                assert(create_net_0 >= 0);
                assert(id0_ready > create_net_0);
                // TODO
            }

            return null;
        }
    }
}