using Gee;
using Netsukuku;
using Netsukuku.Hooking;
using TaskletSystem;

namespace SystemPeer
{
    bool schedule_task_check_graph1(string task)
    {
        if (task.has_prefix("check_graph1,"))
        {
            string remain = task.substring("check_graph1,".length);
            string[] args = remain.split(",");
            if (args.length != 1) error("bad args num in task 'check_graph1'");
            int64 ms_wait;
            if (! int64.try_parse(args[0], out ms_wait)) error("bad args ms_wait in task 'check_graph1'");
            print(@"INFO: in $(ms_wait) ms will do check graph1 for pid #$(pid).\n");
            CheckGraph1Tasklet s = new CheckGraph1Tasklet(
                (int)ms_wait);
            tasklet.spawn(s);
            return true;
        }
        else return false;
    }

    class CheckGraph1Tasklet : Object, ITaskletSpawnable
    {
        public CheckGraph1Tasklet(
            int ms_wait)
        {
            this.ms_wait = ms_wait;
        }
        private int ms_wait;

        public void * func()
        {
            tasklet.ms_wait(ms_wait);

            print(@"Doing check graph1 for node $(pid).\n");

            if (pid == 1133)
            {
                /*
                HookingManager:0:create_net:addr[1,1,3,3]:fp[96119,96119,96119,96119,96119]
                HookingManager:1:enter_net:addr[1,1,3,3]:fp[96119,94648,52893,52893,52893]
                HookingManager:1:call_retrieve_network_data(ask_coord=false)
                HookingManager:1:Signal:same_network:0+1
                **HookingManager:1:ICommSkeleton:executing_evaluate_enter
                HookingManager:1:ICommSkeleton:executing_evaluate_enter
                HookingManager:1:ICommSkeleton:executing_evaluate_enter
                HookingManager:1:ICommSkeleton:executing_evaluate_enter
                HookingManager:1:ICommSkeleton:executing_evaluate_enter
                HookingManager:1:ICommSkeleton:executing_evaluate_enter
                HookingManager:1:ICommSkeleton:executing_evaluate_enter
                HookingManager:1:ICommSkeleton:executing_evaluate_enter
                HookingManager:1:ICommSkeleton:executing_evaluate_enter
                HookingManager:1:ICommSkeleton:executing_evaluate_enter
                HookingManager:1:ICommSkeleton:executing_evaluate_enter
                HookingManager:1:ICommSkeleton:executing_evaluate_enter
                HookingManager:1:ICommSkeleton:executing_evaluate_enter
                HookingManager:1:ICommSkeleton:executing_evaluate_enter
                HookingManager:1:ICommSkeleton:executing_evaluate_enter
                **HookingManager:1:ICommSkeleton:executing_begin_enter
                **HookingManager:1:ICommSkeleton:executing_abort_enter
                HookingManager:1:ICommSkeleton:executing_evaluate_enter
                */
                int first_evaluate = -1;
                int one_begin = -1;
                int one_abort = -1;
                for (int i = 0; i < tester_events.size; i++)
                {
                    if ("HookingManager:1:ICommSkeleton:executing_evaluate_enter" in tester_events[i] && first_evaluate < 0) first_evaluate = i;
                    if ("HookingManager:1:ICommSkeleton:executing_begin_enter" in tester_events[i]) one_begin = i;
                    if ("HookingManager:1:ICommSkeleton:executing_abort_enter" in tester_events[i]) one_abort = i;
                }
                assert(first_evaluate >= 0);
                assert(one_begin > first_evaluate);
                assert(one_abort > one_begin);
            }
            else if (pid == 1233)
            {
                /*
                HookingManager:0:create_net:addr[1,2,3,3]:fp[19009,19009,19009,19009,19009]
                HookingManager:1:enter_net:addr[1,2,3,3]:fp[19009,18705,52893,52893,52893]
                HookingManager:1:call_retrieve_network_data(ask_coord=false)
                HookingManager:1:Signal:same_network:0+1
                HookingManager:1:call_retrieve_network_data(ask_coord=false)
                HookingManager:1:Signal:same_network:1+1
                HookingManager:1:call_retrieve_network_data(ask_coord=false)
                HookingManager:1:Signal:another_network:2+1,34566
                **HookingManager:1:StreamSystemCommStub:calling_evaluate_enter
                HookingManager:1:StreamSystemCommStub:calling_evaluate_enter
                HookingManager:1:StreamSystemCommStub:calling_evaluate_enter
                HookingManager:1:StreamSystemCommStub:calling_evaluate_enter
                HookingManager:1:StreamSystemCommStub:calling_evaluate_enter
                */
                int first_call_evaluate = -1;
                for (int i = 0; i < tester_events.size; i++)
                {
                    if ("HookingManager:1:StreamSystemCommStub:calling_evaluate_enter" in tester_events[i] && first_call_evaluate < 0) first_call_evaluate = i;
                }
                assert(first_call_evaluate >= 0);
            }
            else if (pid == 1333)
            {
                /*
                HookingManager:0:create_net:addr[1,3,3,3]:fp[52893,52893,52893,52893,52893]
                HookingManager:0:call_retrieve_network_data(ask_coord=false)
                HookingManager:0:Signal:same_network:0+1
                HookingManager:0:call_retrieve_network_data(ask_coord=false)
                HookingManager:0:Signal:another_network:1+1,34566
                **HookingManager:0:StreamSystemCommStub:calling_evaluate_enter
                HookingManager:0:call_retrieve_network_data(ask_coord=false)
                HookingManager:0:Signal:another_network:2+1,34566
                HookingManager:0:StreamSystemCommStub:calling_evaluate_enter
                HookingManager:0:StreamSystemCommStub:calling_evaluate_enter
                HookingManager:0:StreamSystemCommStub:calling_evaluate_enter
                HookingManager:0:StreamSystemCommStub:calling_evaluate_enter
                HookingManager:0:StreamSystemCommStub:calling_evaluate_enter
                HookingManager:0:StreamSystemCommStub:calling_evaluate_enter
                HookingManager:0:StreamSystemCommStub:calling_evaluate_enter
                HookingManager:0:StreamSystemCommStub:calling_evaluate_enter
                HookingManager:0:StreamSystemCommStub:calling_evaluate_enter
                **HookingManager:0:StreamSystemCommStub:calling_begin_enter
                **HookingManager:0:call_search_migration_path(lvl=2)
                **HookingManager:0:response_search_migration_path:NoMigrationPathFoundError:You might try at lower level.
                **HookingManager:0:StreamSystemCommStub:calling_abort_enter
                **HookingManager:0:StreamSystemCommStub:calling_begin_enter
                **HookingManager:0:ICommSkeleton:executing_begin_enter
                **HookingManager:0:call_search_migration_path(lvl=1)
                **HookingManager:0:response_search_migration_path:ret={netid:34566,pos:[3,1,2],elderships:[2,2,0]}
                **HookingManager:0:StreamSystemCommStub:calling_completed_enter
                **HookingManager:0:ICommSkeleton:executing_completed_enter
                **HookingManager:0:Signal:do_prepare_enter:488810623
                **HookingManager:0:Signal:do_finish_enter:enter_id=488810623:guest_gnode_level=1:entry_data={"network-id":34566,"pos":[3,1,2],"elderships":[2,2,0]}:go_connectivity_position=2014185773
                HookingManager:0:StreamSystemCommStub:calling_evaluate_enter
                */
                int first_call_evaluate = -1;
                int first_call_begin = -1;
                int call_search_migration_path_lvl_2 = -1;
                int response_search_migration_path_none = -1;
                int call_abort = -1;
                int second_call_begin = -1;
                int call_search_migration_path_lvl_1 = -1;
                int response_search_migration_path_one = -1;
                int do_prepare_enter = -1;
                int do_finish_enter = -1;
                for (int i = 0; i < tester_events.size; i++)
                {
                    if ("HookingManager:0:StreamSystemCommStub:calling_evaluate_enter" in tester_events[i] && first_call_evaluate < 0) first_call_evaluate = i;
                    if ("HookingManager:0:StreamSystemCommStub:calling_begin_enter" in tester_events[i])
                    {
                        if (first_call_begin < 0) first_call_begin = i;
                        else second_call_begin = i;
                    }
                    if ("HookingManager:0:call_search_migration_path(lvl=2)" in tester_events[i]) call_search_migration_path_lvl_2 = i;
                    if ("HookingManager:0:response_search_migration_path:NoMigrationPathFoundError" in tester_events[i]) response_search_migration_path_none = i;
                    if ("HookingManager:0:StreamSystemCommStub:calling_abort_enter" in tester_events[i]) call_abort = i;
                    if ("HookingManager:0:call_search_migration_path(lvl=1)" in tester_events[i]) call_search_migration_path_lvl_1 = i;
                    if ("HookingManager:0:response_search_migration_path:ret={netid:34566,pos:[3,1,2],elderships:[2,2,0]}" in tester_events[i]) response_search_migration_path_one = i;
                    if ("HookingManager:0:Signal:do_prepare_enter" in tester_events[i]) do_prepare_enter = i;
                    if ("HookingManager:0:Signal:do_finish_enter" in tester_events[i]) do_finish_enter = i;
                }
                assert(first_call_evaluate >= 0);
                assert(first_call_begin > first_call_evaluate);
                assert(call_search_migration_path_lvl_2 > first_call_begin);
                assert(response_search_migration_path_none > call_search_migration_path_lvl_2);
                assert(call_abort > response_search_migration_path_none);
                assert(second_call_begin > call_abort);
                assert(call_search_migration_path_lvl_1 > second_call_begin);
                assert(response_search_migration_path_one > call_search_migration_path_lvl_1);
                assert(do_prepare_enter > response_search_migration_path_one);
                assert(do_finish_enter > do_prepare_enter);
            }
            else if (pid == 3312)
            {
                /*
                HookingManager:0:create_net:addr[3,3,1,2]:fp[49059,49059,49059,49059,49059]
                HookingManager:1:enter_net:addr[3,3,1,2]:fp[49059,49059,66158,34566,34566]
                HookingManager:1:call_retrieve_network_data(ask_coord=false)
                HookingManager:1:Signal:same_network:0+1
                HookingManager:1:call_retrieve_network_data(ask_coord=false)
                HookingManager:1:Signal:same_network:1+1
                HookingManager:1:call_retrieve_network_data(ask_coord=false)
                HookingManager:1:call_retrieve_network_data(ask_coord=false)
                HookingManager:1:Signal:another_network:2+0,52893
                HookingManager:1:Signal:another_network:3+1,52893
                **HookingCoordinator:1:reserve(3,496456035):new_pos[5]:new_eldership[3]
                **HookingCoordinator:1:reserve(4,496456035):new_pos[5]:new_eldership[1]
                **HookingMapPaths:1:adjacent_to_my_gnode(level_adjacent_gnodes=3,level_my_gnode=3):size[0]
                **HookingCoordinator:1:reserve(2,876684063):new_pos[5]:new_eldership[2]
                **HookingCoordinator:1:reserve(3,876684063):new_pos[6]:new_eldership[4]
                **HookingCoordinator:1:reserve(4,876684063):new_pos[6]:new_eldership[2]
                **HookingMapPaths:1:adjacent_to_my_gnode(level_adjacent_gnodes=2,level_my_gnode=2):size[1]
                **HookingMapPaths:1:adjacent_to_my_gnode(level_adjacent_gnodes=3,level_my_gnode=2):size[0]
                **HookingManager:1:StreamSystemCommStub:calling_prepare_migration
                **HookingManager:1:Signal:do_prepare_migration:458527707
                **HookingManager:1:StreamSystemCommStub:calling_finish_migration
                **HookingManager:1:Signal:do_finish_migration:migration_id=458527707:guest_gnode_level=1:migration_data={"network-id":0,"pos":[1,2,2],"elderships":[2,1,0]}:go_connectivity_position=5
                */
                int do_prepare_migration = -1;
                int do_finish_migration = -1;
                for (int i = 0; i < tester_events.size; i++)
                {
                    if ("HookingManager:1:Signal:do_prepare_migration:" in tester_events[i]) do_prepare_migration = i;
                    if ("HookingManager:1:Signal:do_finish_migration:" in tester_events[i]) do_finish_migration = i;
                }
                assert(do_prepare_migration >= 0);
                assert(do_finish_migration > do_prepare_migration);
            }
            else if (pid == 2122)
            {
                /*
                HookingManager:0:create_net:addr[2,1,2,2]:fp[87164,87164,87164,87164,87164]
                HookingManager:1:enter_net:addr[2,1,2,2]:fp[87164,52236,52236,34566,34566]
                HookingManager:1:call_retrieve_network_data(ask_coord=false)
                HookingManager:1:Signal:same_network:0+1
                HookingManager:1:call_retrieve_network_data(ask_coord=false)
                HookingManager:1:Signal:same_network:1+1
                **HookingCoordinator:1:reserve(2,876684063):new_pos[5]:new_eldership[2]
                **HookingCoordinator:1:reserve(3,876684063):new_pos[7]:new_eldership[5]
                **HookingCoordinator:1:reserve(4,876684063):new_pos[7]:new_eldership[3]
                **HookingMapPaths:1:adjacent_to_my_gnode(level_adjacent_gnodes=2,level_my_gnode=2):size[2]
                **HookingMapPaths:1:adjacent_to_my_gnode(level_adjacent_gnodes=3,level_my_gnode=2):size[0]
                **HookingManager:1:StreamSystemCommStub:calling_prepare_migration
                **HookingManager:1:Signal:do_prepare_migration:1576175413
                **HookingManager:1:StreamSystemCommStub:calling_finish_migration
                **HookingManager:1:Signal:do_finish_migration:migration_id=1576175413:guest_gnode_level=1:migration_data={"network-id":0,"pos":[3,3,2],"elderships":[1,0,0]}:go_connectivity_position=5
                */
                int do_prepare_migration = -1;
                int do_finish_migration = -1;
                for (int i = 0; i < tester_events.size; i++)
                {
                    if ("HookingManager:1:Signal:do_prepare_migration:" in tester_events[i]) do_prepare_migration = i;
                    if ("HookingManager:1:Signal:do_finish_migration:" in tester_events[i]) do_finish_migration = i;
                }
                assert(do_prepare_migration >= 0);
                assert(do_finish_migration > do_prepare_migration);
            }
            else if (pid == 2232)
            {
                /*
                HookingManager:0:create_net:addr[2,2,3,2]:fp[34566,34566,34566,34566,34566]
                HookingManager:0:call_retrieve_network_data(ask_coord=false)
                HookingManager:0:Signal:same_network:0+1
                HookingManager:0:call_retrieve_network_data(ask_coord=false)
                HookingManager:0:Signal:same_network:1+1
                **HookingCoordinator:0:reserve(2,876684063):new_pos[3]:new_eldership[1]
                */
                int reserve = -1;
                for (int i = 0; i < tester_events.size; i++)
                {
                    if ("HookingCoordinator:0:reserve(2,876684063):new_pos[3]:new_eldership[1]" in tester_events[i]) reserve = i;
                }
                assert(reserve >= 0);
            }
            else if (pid == 3122)
            {
                /*
                HookingManager:0:create_net:addr[3,1,2,2]:fp[52236,52236,52236,52236,52236]
                HookingManager:1:enter_net:addr[3,1,2,2]:fp[52236,52236,52236,34566,34566]
                HookingManager:1:call_retrieve_network_data(ask_coord=false)
                HookingManager:1:Signal:same_network:0+0
                HookingManager:1:call_retrieve_network_data(ask_coord=false)
                HookingManager:1:Signal:same_network:1+1
                HookingManager:1:call_retrieve_network_data(ask_coord=false)
                HookingManager:1:call_retrieve_network_data(ask_coord=false)
                HookingManager:1:Signal:same_network:2+1
                HookingManager:1:Signal:same_network:3+1
                **HookingManager:1:ICommSkeleton:executing_prepare_migration
                **HookingManager:1:Signal:do_prepare_migration:1576175413
                **HookingManager:1:ICommSkeleton:executing_finish_migration
                **HookingManager:1:Signal:do_finish_migration:migration_id=1576175413:guest_gnode_level=1:migration_data={"network-id":0,"pos":[3,3,2],"elderships":[1,0,0]}:go_connectivity_position=5
                */
                int do_prepare_migration = -1;
                int do_finish_migration = -1;
                for (int i = 0; i < tester_events.size; i++)
                {
                    if ("HookingManager:1:Signal:do_prepare_migration:" in tester_events[i]) do_prepare_migration = i;
                    if ("HookingManager:1:Signal:do_finish_migration:" in tester_events[i]) do_finish_migration = i;
                }
                assert(do_prepare_migration >= 0);
                assert(do_finish_migration > do_prepare_migration);
            }
            else if (pid == 2312)
            {
                /*
                HookingManager:0:create_net:addr[2,3,1,2]:fp[54715,54715,54715,54715,54715]
                HookingManager:1:enter_net:addr[2,3,1,2]:fp[54715,49059,66158,34566,34566]
                HookingManager:1:call_retrieve_network_data(ask_coord=false)
                HookingManager:1:call_retrieve_network_data(ask_coord=false)
                HookingManager:1:Signal:same_network:0+1
                HookingManager:1:Signal:same_network:1+1
                HookingManager:1:call_retrieve_network_data(ask_coord=false)
                HookingManager:1:Signal:another_network:2+0,52893
                **HookingManager:1:ICommSkeleton:executing_prepare_migration
                **HookingManager:1:Signal:do_prepare_migration:458527707
                **HookingManager:1:ICommSkeleton:executing_finish_migration
                **HookingManager:1:Signal:do_finish_migration:migration_id=458527707:guest_gnode_level=1:migration_data={"network-id":0,"pos":[1,2,2],"elderships":[2,1,0]}:go_connectivity_position=5
                */
                int do_prepare_migration = -1;
                int do_finish_migration = -1;
                for (int i = 0; i < tester_events.size; i++)
                {
                    if ("HookingManager:1:Signal:do_prepare_migration:" in tester_events[i]) do_prepare_migration = i;
                    if ("HookingManager:1:Signal:do_finish_migration:" in tester_events[i]) do_finish_migration = i;
                }
                assert(do_prepare_migration >= 0);
                assert(do_finish_migration > do_prepare_migration);
            }

            return null;
        }
    }
}