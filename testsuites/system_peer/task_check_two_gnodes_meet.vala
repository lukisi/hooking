using Gee;
using Netsukuku;
using Netsukuku.Hooking;
using TaskletSystem;

/*
   =====  100  =====    
HookingManager:0:create_net:addr[3,3,3]:fp[54802,54802,54802,54802]
Tester:Tag:300_id0_ready
Tester:Tag:400_identityarc_added
HookingManager:0:call_retrieve_network_data(ask_coord=false)
HookingManager:0:Signal:another_network:0+0,79330
HookingManager:0:call_retrieve_network_data(ask_coord=true)
HookingManager:0:StreamSystemCommStub:calling_evaluate_enter
HookingManager:0:ICommSkeleton:executing_evaluate_enter
HookingManager:0:StreamSystemCommStub:calling_evaluate_enter
HookingManager:0:ICommSkeleton:executing_evaluate_enter
HookingManager:0:StreamSystemCommStub:calling_evaluate_enter
HookingManager:0:ICommSkeleton:executing_evaluate_enter
HookingManager:0:StreamSystemCommStub:calling_evaluate_enter
HookingManager:0:ICommSkeleton:executing_evaluate_enter
HookingManager:0:StreamSystemCommStub:calling_evaluate_enter
HookingManager:0:ICommSkeleton:executing_evaluate_enter
HookingManager:0:call_search_migration_path(lvl=0)
HookingManager:0:response_search_migration_path:ret={netid:79330,pos:[1,0,0],elderships:[1,0,0]}
HookingManager:0:Signal:do_prepare_enter:777380291
HookingManager:0:Signal:do_finish_enter:enter_id=777380291:guest_gnode_level=0:entry_data={"network-id":79330,"pos":[1,0,0],"elderships":[1,0,0]}:go_connectivity_position=1290880946
Tester:Tag:2390
HookingManager:1:enter_net:addr[1,0,0]:fp[54802,79330,79330,79330]
HookingManager:1:call_retrieve_network_data(ask_coord=false)
HookingManager:1:Signal:same_network:0+0
Tester:Tag:2500_identityarc_added
HookingManager:1:call_retrieve_network_data(ask_coord=false)
HookingManager:1:Signal:another_network:1+0,57078
HookingManager:1:call_retrieve_network_data(ask_coord=true)
Tester:Tag:4390
HookingManager:1:call_retrieve_network_data(ask_coord=false)
HookingManager:1:Signal:same_network:1+1


   =====  200  =====    
HookingManager:0:create_net:addr[2,0,0]:fp[79330,79330,79330,79330]
Tester:Tag:300_id0_ready
Tester:Tag:400_identityarc_added
HookingManager:0:call_retrieve_network_data(ask_coord=false)
HookingManager:0:Signal:another_network:0+0,54802
HookingManager:0:call_retrieve_network_data(ask_coord=true)
HookingCoordinator:0:reserve(1,261318919):new_pos[1]:new_eldership[1]
Tester:Tag:2390
HookingManager:0:call_retrieve_network_data(ask_coord=false)
HookingManager:0:Signal:same_network:0+1
Tester:Tag:2500_identityarc_added
HookingManager:0:call_retrieve_network_data(ask_coord=false)
HookingManager:0:Signal:another_network:1+1,57078
HookingManager:0:call_retrieve_network_data(ask_coord=true)
HookingCoordinator:0:reserve(2,273603928):new_pos[1]:new_eldership[1]
Tester:Tag:4390
HookingManager:0:call_retrieve_network_data(ask_coord=false)
HookingManager:0:Signal:same_network:1+2


   =====  110  =====    
HookingManager:0:create_net:addr[1,3,3]:fp[57078,57078,57078,57078]
Tester:Tag:300_id0_ready
Tester:Tag:400_identityarc_added
HookingManager:0:call_retrieve_network_data(ask_coord=false)
HookingManager:0:Signal:another_network:0+0,39069
HookingManager:0:call_retrieve_network_data(ask_coord=true)
HookingCoordinator:0:reserve(1,557140888):new_pos[2]:new_eldership[1]
Tester:Tag:2390
HookingManager:0:call_retrieve_network_data(ask_coord=false)
Tester:Tag:2500_identityarc_added
HookingManager:0:Signal:same_network:0+1
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
HookingManager:0:ICommSkeleton:executing_begin_enter
HookingManager:0:ICommSkeleton:executing_completed_enter
HookingManager:0:ICommSkeleton:executing_prepare_enter
HookingManager:0:Signal:do_prepare_enter:595975495
HookingManager:0:ICommSkeleton:executing_finish_enter
HookingManager:0:Signal:do_finish_enter:enter_id=595975495:guest_gnode_level=1:entry_data={"network-id":79330,"pos":[1,0],"elderships":[1,0]}:go_connectivity_position=275004234
HookingManager:0:StreamSystemCommStub:calling_evaluate_enter
HookingManager:0:ICommSkeleton:executing_evaluate_enter
Tester:Tag:4390
HookingManager:1:enter_net:addr[1,1,0]:fp[57078,57078,79330,79330]
HookingManager:1:call_retrieve_network_data(ask_coord=false)
HookingManager:1:call_retrieve_network_data(ask_coord=false)
HookingManager:1:Signal:same_network:1+1
HookingManager:1:Signal:same_network:0+2


   =====  210  =====    
HookingManager:0:create_net:addr[2,0,0]:fp[39069,39069,39069,39069]
Tester:Tag:300_id0_ready
Tester:Tag:400_identityarc_added
HookingManager:0:call_retrieve_network_data(ask_coord=false)
HookingManager:0:Signal:another_network:0+0,57078
HookingManager:0:call_retrieve_network_data(ask_coord=true)
HookingManager:0:StreamSystemCommStub:calling_evaluate_enter
HookingManager:0:ICommSkeleton:executing_evaluate_enter
HookingManager:0:StreamSystemCommStub:calling_evaluate_enter
HookingManager:0:ICommSkeleton:executing_evaluate_enter
HookingManager:0:StreamSystemCommStub:calling_evaluate_enter
HookingManager:0:ICommSkeleton:executing_evaluate_enter
HookingManager:0:StreamSystemCommStub:calling_evaluate_enter
HookingManager:0:ICommSkeleton:executing_evaluate_enter
HookingManager:0:StreamSystemCommStub:calling_evaluate_enter
HookingManager:0:ICommSkeleton:executing_evaluate_enter
HookingManager:0:call_search_migration_path(lvl=0)
HookingManager:0:response_search_migration_path:ret={netid:57078,pos:[2,3,3],elderships:[1,0,0]}
HookingManager:0:Signal:do_prepare_enter:886713096
HookingManager:0:Signal:do_finish_enter:enter_id=886713096:guest_gnode_level=0:entry_data={"network-id":57078,"pos":[2,3,3],"elderships":[1,0,0]}:go_connectivity_position=1666093479
Tester:Tag:2390
HookingManager:1:enter_net:addr[2,3,3]:fp[39069,57078,57078,57078]
HookingManager:1:call_retrieve_network_data(ask_coord=false)
HookingManager:1:Signal:same_network:0+0
Tester:Tag:2500_identityarc_added
HookingManager:1:call_retrieve_network_data(ask_coord=false)
HookingManager:1:Signal:another_network:1+0,79330
HookingManager:1:call_retrieve_network_data(ask_coord=true)
HookingManager:1:StreamSystemCommStub:calling_evaluate_enter
HookingManager:1:StreamSystemCommStub:calling_evaluate_enter
HookingManager:1:StreamSystemCommStub:calling_evaluate_enter
HookingManager:1:StreamSystemCommStub:calling_evaluate_enter
HookingManager:1:StreamSystemCommStub:calling_evaluate_enter
HookingManager:1:StreamSystemCommStub:calling_begin_enter
HookingManager:1:call_search_migration_path(lvl=1)
HookingManager:1:response_search_migration_path:ret={netid:79330,pos:[1,0],elderships:[1,0]}
HookingManager:1:StreamSystemCommStub:calling_completed_enter
HookingManager:1:StreamSystemCommStub:calling_prepare_enter
HookingManager:1:Signal:do_prepare_enter:595975495
HookingManager:1:StreamSystemCommStub:calling_finish_enter
HookingManager:1:Signal:do_finish_enter:enter_id=595975495:guest_gnode_level=1:entry_data={"network-id":79330,"pos":[1,0],"elderships":[1,0]}:go_connectivity_position=275004234
Tester:Tag:4390
HookingManager:2:enter_net:addr[2,1,0]:fp[39069,57078,79330,79330]
HookingManager:2:call_retrieve_network_data(ask_coord=false)
HookingManager:2:call_retrieve_network_data(ask_coord=false)
HookingManager:2:Signal:same_network:0+1
HookingManager:2:Signal:same_network:1+0

*/

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
            }
            else if (pid == 200)
            {
            }
            else if (pid == 110)
            {
            }
            else if (pid == 210)
            {
            }

            return null;
        }
    }
}