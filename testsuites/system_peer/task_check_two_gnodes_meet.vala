using Gee;
using Netsukuku;
using Netsukuku.Hooking;
using TaskletSystem;

namespace SystemPeer
{
    bool schedule_task_check_two_gnodes_meet(string task)
    {
        if (task.has_prefix("check_two_gnodes_meet,"))
        {
            string remain = task.substring("check_two_gnodes_meet,".length);
            string[] args = remain.split(",");
            if (args.length != 1) error("bad args num in task 'check_two_gnodes_meet'");
            int64 ms_wait;
            if (! int64.try_parse(args[0], out ms_wait)) error("bad args ms_wait in task 'check_two_gnodes_meet'");
            print(@"INFO: in $(ms_wait) ms will do check two_gnodes_meet for pid #$(pid).\n");
            CheckTwoGnodesMeetTasklet s = new CheckTwoGnodesMeetTasklet(
                (int)ms_wait);
            tasklet.spawn(s);
            return true;
        }
        else return false;
    }

    class CheckTwoGnodesMeetTasklet : Object, ITaskletSpawnable
    {
        public CheckTwoGnodesMeetTasklet(
            int ms_wait)
        {
            this.ms_wait = ms_wait;
        }
        private int ms_wait;

        public void * func()
        {
            tasklet.ms_wait(ms_wait);

            print(@"Doing check two_gnodes_meet for node $(pid).\n");

            if (pid == 100)
            {
                /*
                HookingManager:1:call_retrieve_network_data(ask_coord=false)
                HookingManager:1:Signal:another_network:1+0,57078
                HookingManager:1:call_retrieve_network_data(ask_coord=true)
                HookingCoordinator:1:reserve(2,1025745897):new_pos[1]:new_eldership[1]
                Tester:Tag:3390
                HookingManager:1:call_retrieve_network_data(ask_coord=false)
                HookingManager:1:Signal:same_network:1+1
                Tester:Tag:4000
                */
                int another_network = -1;
                int reserve_request = -1;
                int same_network = -1;
                for (int i = 0; i < tester_events.size; i++)
                {
                    if ("HookingManager:1:Signal:another_network:1+0" in tester_events[i]) another_network = i;
                    if ("HookingCoordinator:1:reserve(2," in tester_events[i]) reserve_request = i;
                    if ("HookingManager:1:Signal:same_network:1+1" in tester_events[i]) same_network = i;
                }
                assert(another_network >= 0);
                assert(reserve_request > another_network);
                assert(same_network > reserve_request);
            }
            else if (pid == 200)
            {
                /*
                HookingManager:0:call_retrieve_network_data(ask_coord=false)
                HookingManager:0:Signal:another_network:1+1,57078
                HookingManager:0:call_retrieve_network_data(ask_coord=true)
                Tester:Tag:3390
                HookingManager:0:call_retrieve_network_data(ask_coord=false)
                HookingManager:0:Signal:same_network:1+2
                Tester:Tag:4000
                */
                int another_network = -1;
                int same_network = -1;
                for (int i = 0; i < tester_events.size; i++)
                {
                    if ("HookingManager:0:Signal:another_network:1+1" in tester_events[i]) another_network = i;
                    if ("HookingManager:0:Signal:same_network:1+2" in tester_events[i]) same_network = i;
                }
                assert(another_network >= 0);
                assert(same_network > another_network);
            }
            else if (pid == 110)
            {
                /*
                HookingManager:0:call_retrieve_network_data(ask_coord=false)
                HookingManager:0:Signal:another_network:1+1,79330
                HookingManager:0:call_retrieve_network_data(ask_coord=true)
                HookingManager:0:StreamSystemCommStub:calling_evaluate_enter
                HookingManager:0:ICommSkeleton:executing_evaluate_enter
                HookingManager:0:ICommSkeleton:executing_evaluate_enter
                HookingManager:0:StreamSystemCommStub:calling_evaluate_enter
                HookingManager:0:ICommSkeleton:executing_evaluate_enter
                HookingManager:0:ICommSkeleton:executing_evaluate_enter
                HookingManager:0:StreamSystemCommStub:calling_evaluate_enter
                HookingManager:0:ICommSkeleton:executing_evaluate_enter
                HookingManager:0:ICommSkeleton:executing_evaluate_enter
                HookingManager:0:StreamSystemCommStub:calling_evaluate_enter
                HookingManager:0:ICommSkeleton:executing_evaluate_enter
                HookingManager:0:ICommSkeleton:executing_evaluate_enter
                HookingManager:0:StreamSystemCommStub:calling_evaluate_enter
                HookingManager:0:ICommSkeleton:executing_evaluate_enter
                HookingManager:0:ICommSkeleton:executing_evaluate_enter
                HookingManager:0:StreamSystemCommStub:calling_begin_enter
                HookingManager:0:ICommSkeleton:executing_begin_enter
                HookingManager:0:call_search_migration_path(lvl=1)
                HookingManager:0:response_search_migration_path:ret={netid:79330,pos:[1,0],elderships:[1,0]}
                HookingManager:0:StreamSystemCommStub:calling_completed_enter
                HookingManager:0:ICommSkeleton:executing_completed_enter
                HookingManager:0:StreamSystemCommStub:calling_prepare_enter
                HookingManager:0:Signal:do_prepare_enter:424110174
                HookingManager:0:StreamSystemCommStub:calling_finish_enter
                HookingManager:0:Signal:do_finish_enter:enter_id=424110174:guest_gnode_level=1:entry_data={"network-id":79330,"pos":[1,0],"elderships":[1,0]}:go_connectivity_position=1282238096
                Tester:Tag:3390
                HookingManager:1:enter_net:addr[1,1,0]:fp[57078,57078,79330,79330]
                HookingManager:1:call_retrieve_network_data(ask_coord=false)
                HookingManager:1:call_retrieve_network_data(ask_coord=false)
                HookingManager:1:Signal:same_network:0+2
                HookingManager:1:Signal:same_network:1+1
                Tester:Tag:4000
                */
                int another_network = -1;
                int do_finish_enter = -1;
                int same_network = -1;
                for (int i = 0; i < tester_events.size; i++)
                {
                    if ("HookingManager:0:Signal:another_network:1+1" in tester_events[i]) another_network = i;
                    if ("HookingManager:0:Signal:do_finish_enter" in tester_events[i]) do_finish_enter = i;
                    if ("HookingManager:1:Signal:same_network:1+1" in tester_events[i]) same_network = i;
                }
                assert(another_network >= 0);
                assert(do_finish_enter > another_network);
                assert(same_network > do_finish_enter);
            }
            else if (pid == 210)
            {
                /*
                HookingManager:1:call_retrieve_network_data(ask_coord=false)
                HookingManager:1:Signal:another_network:1+0,79330
                HookingManager:1:call_retrieve_network_data(ask_coord=true)
                HookingManager:1:StreamSystemCommStub:calling_evaluate_enter
                HookingManager:1:StreamSystemCommStub:calling_evaluate_enter
                HookingManager:1:StreamSystemCommStub:calling_evaluate_enter
                HookingManager:1:StreamSystemCommStub:calling_evaluate_enter
                HookingManager:1:StreamSystemCommStub:calling_evaluate_enter
                HookingManager:1:ICommSkeleton:executing_prepare_enter
                HookingManager:1:Signal:do_prepare_enter:424110174
                HookingManager:1:ICommSkeleton:executing_finish_enter
                HookingManager:1:Signal:do_finish_enter:enter_id=424110174:guest_gnode_level=1:entry_data={"network-id":79330,"pos":[1,0],"elderships":[1,0]}:go_connectivity_position=1282238096
                Tester:Tag:3390
                HookingManager:2:enter_net:addr[2,1,0]:fp[39069,57078,79330,79330]
                HookingManager:2:call_retrieve_network_data(ask_coord=false)
                HookingManager:2:call_retrieve_network_data(ask_coord=false)
                HookingManager:2:Signal:same_network:0+1
                HookingManager:2:Signal:same_network:1+0
                Tester:Tag:4000
                */
                int another_network = -1;
                int do_finish_enter = -1;
                int same_network = -1;
                for (int i = 0; i < tester_events.size; i++)
                {
                    if ("HookingManager:1:Signal:another_network:1+0" in tester_events[i]) another_network = i;
                    if ("HookingManager:1:Signal:do_finish_enter" in tester_events[i]) do_finish_enter = i;
                    if ("HookingManager:2:Signal:same_network:1+0" in tester_events[i]) same_network = i;
                }
                assert(another_network >= 0);
                assert(do_finish_enter > another_network);
                assert(same_network > do_finish_enter);
            }

            return null;
        }
    }
}