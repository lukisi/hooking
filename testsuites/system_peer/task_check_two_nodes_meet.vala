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
                HookingManager:0:StreamSystemCommStub:calling_evaluate_enter
                HookingManager:0:ICommSkeleton:executing_evaluate_enter
                ...
                HookingManager:0:call_search_migration_path(lvl=0)
                HookingManager:0:response_search_migration_path:ret={netid:79330,pos:[1,0,0],elderships:[1,0,0]}
                HookingManager:0:Signal:do_prepare_enter:777380291
                HookingManager:0:Signal:do_finish_enter:777380291
                Tester:Tag:5300
                HookingManager:1:enter_net:addr[1,0,0]:fp[54802,79330,79330,79330]
                HookingManager:1:call_retrieve_network_data(ask_coord=false)
                HookingManager:1:Signal:same_network:0+0
                */
                int create_net_0 = -1;
                int id0_ready = -1;
                int retrieve_no_coord = -1;
                int signal_another_network = -1;
                int retrieve_ask_coord = -1;
                int myid_calling_evaluate_enter = -1;
                int myid_executing_evaluate_enter = -1;
                int myid_calling_search_migration_path_0 = -1;
                int myid_search_migration_path_0_returns = -1;
                int signal_do_prepare_enter = -1;
                int signal_do_finish_enter = -1;
                for (int i = 0; i < tester_events.size; i++)
                {
                    if ("HookingManager:0:create_net" in tester_events[i]) create_net_0 = i;
                    if ("Tester:Tag" in tester_events[i] && "id0_ready" in tester_events[i]) id0_ready = i;
                    if ("HookingManager:0:call_retrieve_network_data(ask_coord=false)" in tester_events[i]) retrieve_no_coord = i;
                    if ("HookingManager:0:Signal:another_network:0+0," in tester_events[i]) signal_another_network = i;
                    if ("HookingManager:0:call_retrieve_network_data(ask_coord=true)" in tester_events[i]) retrieve_ask_coord = i;
                    if ("HookingManager:0:StreamSystemCommStub:calling_evaluate_enter" in tester_events[i] &&
                        myid_calling_evaluate_enter == -1 && signal_do_prepare_enter == -1) myid_calling_evaluate_enter = i;
                    if ("HookingManager:0:ICommSkeleton:executing_evaluate_enter" in tester_events[i] &&
                        myid_executing_evaluate_enter == -1 && signal_do_prepare_enter == -1) myid_executing_evaluate_enter = i;
                    if ("HookingManager:0:call_search_migration_path(lvl=0)" in tester_events[i] &&
                        myid_calling_search_migration_path_0 == -1) myid_calling_search_migration_path_0 = i;
                    if ("HookingManager:0:response_search_migration_path:ret={" in tester_events[i] &&
                        myid_search_migration_path_0_returns == -1) myid_search_migration_path_0_returns = i;
                    if ("HookingManager:0:Signal:do_prepare_enter" in tester_events[i]) signal_do_prepare_enter = i;
                    if ("HookingManager:0:Signal:do_finish_enter" in tester_events[i]) signal_do_finish_enter = i;
                }
                assert(create_net_0 >= 0);
                assert(id0_ready > create_net_0);
                assert(retrieve_no_coord > id0_ready);
                assert(signal_another_network > retrieve_no_coord);
                assert(retrieve_ask_coord > signal_another_network);
                assert(myid_calling_evaluate_enter > retrieve_ask_coord);
                assert(myid_executing_evaluate_enter > myid_calling_evaluate_enter);
                assert(myid_calling_search_migration_path_0 > myid_executing_evaluate_enter);
                assert(myid_search_migration_path_0_returns > myid_calling_search_migration_path_0);
                assert(signal_do_prepare_enter > myid_search_migration_path_0_returns);
                assert(signal_do_finish_enter > signal_do_prepare_enter);
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
                int retrieve_no_coord = -1;
                int signal_another_network = -1;
                int retrieve_ask_coord = -1;
                int myid_reserve = -1;
                for (int i = 0; i < tester_events.size; i++)
                {
                    if ("HookingManager:0:create_net" in tester_events[i]) create_net_0 = i;
                    if ("Tester:Tag" in tester_events[i] && "id0_ready" in tester_events[i]) id0_ready = i;
                    if ("HookingManager:0:call_retrieve_network_data(ask_coord=false)" in tester_events[i] &&
                        myid_reserve == -1) retrieve_no_coord = i;
                    if ("HookingManager:0:Signal:another_network:0+0," in tester_events[i]) signal_another_network = i;
                    if ("HookingManager:0:call_retrieve_network_data(ask_coord=true)" in tester_events[i] &&
                        myid_reserve == -1) retrieve_ask_coord = i;
                    if ("HookingCoordinator:0:reserve(1," in tester_events[i]) myid_reserve = i;
                }
                assert(create_net_0 >= 0);
                assert(id0_ready > create_net_0);
                assert(retrieve_no_coord > id0_ready);
                assert(signal_another_network > retrieve_no_coord);
                assert(retrieve_ask_coord > signal_another_network);
                assert(myid_reserve > retrieve_ask_coord);
                // TODO
            }

            return null;
        }
    }
}