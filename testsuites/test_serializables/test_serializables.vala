/*
 *  This file is part of Netsukuku.
 *  Copyright (C) 2018 Luca Dionisi aka lukisi <luca.dionisi@gmail.com>
 *
 *  Netsukuku is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  Netsukuku is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Netsukuku.  If not, see <http://www.gnu.org/licenses/>.
 */

using Gee;
using Netsukuku;
using Netsukuku.Hooking;

string json_string_object(Object obj)
{
    Json.Node n = Json.gobject_serialize(obj);
    Json.Generator g = new Json.Generator();
    g.root = n;
    g.pretty = true;
    string ret = g.to_data(null);
    return ret;
}

void print_object(Object obj)
{
    print(@"$(obj.get_type().name())\n");
    string t = json_string_object(obj);
    print(@"$(t)\n");
}

// fake
public interface Netsukuku.IEntryData : Object {}
public interface Netsukuku.ISearchMigrationPathRequest : Object {}
public interface Netsukuku.ISearchMigrationPathErrorPkt : Object {}
public interface Netsukuku.ISearchMigrationPathResponse : Object {}
public interface Netsukuku.IExploreGNodeRequest : Object {}
public interface Netsukuku.IExploreGNodeResponse : Object {}
public interface Netsukuku.IDeleteReservationRequest : Object {}
public interface Netsukuku.IRequestPacket : Object {}
public interface Netsukuku.IResponsePacket : Object {}
public interface Netsukuku.INetworkData : Object {}
public enum RequestPacketType
{
    PREPARE_MIGRATION=0,
    FINISH_MIGRATION
}
public enum EvaluationStatus
{
    PENDING=0,
    TO_BE_NOTIFIED,
    NOTIFIED
}

class HookingTester : Object
{
    public void set_up ()
    {
    }

    public void tear_down ()
    {
    }

    public void test_NetworkData()
    {
        NetworkData nd0;
        {
            Json.Node node;
            {
                NetworkData nd = new NetworkData();
                nd.neighbor_pos = new ArrayList<int>.wrap({1,0,0});
                nd.gsizes = new ArrayList<int>.wrap({2,2,4});
                nd.network_id = 482374327583758;
                nd.neighbor_min_level = 1;
                nd.neighbor_n_nodes = 1234;
                node = Json.gobject_serialize(nd);
            }
            nd0 = (NetworkData)Json.gobject_deserialize(typeof(NetworkData), node);
        }
        assert(nd0.neighbor_pos.size == 3);
        assert(nd0.neighbor_pos[0] == 1);
        assert(nd0.neighbor_pos[1] == 0);
        assert(nd0.neighbor_pos[2] == 0);
        assert(nd0.gsizes.size == 3);
        assert(nd0.gsizes[0] == 2);
        assert(nd0.gsizes[1] == 2);
        assert(nd0.gsizes[2] == 4);
        assert(nd0.network_id == 482374327583758);
        assert(nd0.neighbor_min_level == 1);
        assert(nd0.neighbor_n_nodes == 1234);
    }

    public void test_EvaluateEnterData()
    {
        EvaluateEnterData eed0;
        {
            Json.Node node;
            {
                EvaluateEnterData eed = new EvaluateEnterData();
                eed.network_id = 482374327583758;
                eed.neighbor_pos = new ArrayList<int>.wrap({1,0,0});
                eed.neighbor_min_lvl = 1;
                eed.min_lvl = 0;
                eed.evaluate_enter_id = 1234;
                node = Json.gobject_serialize(eed);
            }
            eed0 = (EvaluateEnterData)Json.gobject_deserialize(typeof(EvaluateEnterData), node);
        }
        assert(eed0.network_id == 482374327583758);
        assert(eed0.neighbor_pos.size == 3);
        assert(eed0.neighbor_pos[0] == 1);
        assert(eed0.neighbor_pos[1] == 0);
        assert(eed0.neighbor_pos[2] == 0);
        assert(eed0.neighbor_min_lvl == 1);
        assert(eed0.min_lvl == 0);
        assert(eed0.evaluate_enter_id == 1234);
    }

    public void test_EvaluateEnterResult()
    {
        EvaluateEnterResult eer0;
        {
            Json.Node node;
            {
                EvaluateEnterResult eer = new EvaluateEnterResult();
                eer.first_ask_lvl = 2;
                eer.ask_again_error = true;
                eer.ignore_network_error = false;
                node = Json.gobject_serialize(eer);
            }
            eer0 = (EvaluateEnterResult)Json.gobject_deserialize(typeof(EvaluateEnterResult), node);
        }
        assert(eer0.first_ask_lvl == 2);
        assert(eer0.ask_again_error == true);
        assert(eer0.ignore_network_error == false);
    }

    public void test_EvaluateEnterEvaluation()
    {
        EvaluateEnterEvaluation eee0;
        {
            Json.Node node;
            {
                EvaluateEnterEvaluation eee = new EvaluateEnterEvaluation();
                eee.client_address = new ArrayList<int>.wrap({1,0,0});
                eee.evaluate_enter_data = new EvaluateEnterData();
                eee.evaluate_enter_data.network_id = 482374327583758;
                eee.evaluate_enter_data.neighbor_pos = new ArrayList<int>.wrap({1,0,0});
                eee.evaluate_enter_data.neighbor_min_lvl = 1;
                eee.evaluate_enter_data.min_lvl = 0;
                eee.evaluate_enter_data.evaluate_enter_id = 1234;
                node = Json.gobject_serialize(eee);
            }
            eee0 = (EvaluateEnterEvaluation)Json.gobject_deserialize(typeof(EvaluateEnterEvaluation), node);
        }
        assert(eee0.client_address.size == 3);
        assert(eee0.client_address[0] == 1);
        assert(eee0.client_address[1] == 0);
        assert(eee0.client_address[2] == 0);
        assert(eee0.evaluate_enter_data.network_id == 482374327583758);
    }

    public void test_HookingMemory()
    {
        HookingMemory mm0;
        {
            Json.Node node;
            {
                HookingMemory mm = new HookingMemory();
                node = Json.gobject_serialize(mm);
            }
            mm0 = (HookingMemory)Json.gobject_deserialize(typeof(HookingMemory), node);
        }
        assert(mm0.evaluate_enter_evaluation_list.size == 0);
        assert(mm0.evaluate_enter_timeout == null);
        assert(mm0.evaluate_enter_status == null);
        assert(mm0.evaluate_enter_elected == null);
        assert(mm0.begin_enter_timeout == null);

        HookingMemory mm1;
        {
            Json.Node node;
            {
                HookingMemory mm = new HookingMemory();
                mm.evaluate_enter_evaluation_list.add(new EvaluateEnterEvaluation());
                mm.evaluate_enter_evaluation_list[0].client_address = new ArrayList<int>.wrap({1,0,0});
                mm.evaluate_enter_evaluation_list[0].evaluate_enter_data = new EvaluateEnterData();
                mm.evaluate_enter_evaluation_list[0].evaluate_enter_data.network_id = 482374327583758;
                mm.evaluate_enter_evaluation_list[0].evaluate_enter_data.neighbor_pos = new ArrayList<int>.wrap({1,0,0});
                mm.evaluate_enter_evaluation_list[0].evaluate_enter_data.neighbor_min_lvl = 1;
                mm.evaluate_enter_evaluation_list[0].evaluate_enter_data.min_lvl = 0;
                mm.evaluate_enter_evaluation_list[0].evaluate_enter_data.evaluate_enter_id = 1234;
                mm.evaluate_enter_first_ask_lvl = 2;
                node = Json.gobject_serialize(mm);
            }
            mm1 = (HookingMemory)Json.gobject_deserialize(typeof(HookingMemory), node);
        }
        assert(mm1.evaluate_enter_evaluation_list.size == 1);
        assert(mm1.evaluate_enter_evaluation_list[0].client_address.size == 3);
        assert(mm1.evaluate_enter_evaluation_list[0].client_address[0] == 1);
        assert(mm1.evaluate_enter_evaluation_list[0].client_address[1] == 0);
        assert(mm1.evaluate_enter_evaluation_list[0].client_address[2] == 0);
        assert(mm1.evaluate_enter_evaluation_list[0].evaluate_enter_data.network_id == 482374327583758);
        assert(mm1.evaluate_enter_evaluation_list[0].evaluate_enter_data.neighbor_pos.size == 3);
        assert(mm1.evaluate_enter_evaluation_list[0].evaluate_enter_data.neighbor_pos[0] == 1);
        assert(mm1.evaluate_enter_evaluation_list[0].evaluate_enter_data.neighbor_pos[1] == 0);
        assert(mm1.evaluate_enter_evaluation_list[0].evaluate_enter_data.neighbor_pos[2] == 0);
        assert(mm1.evaluate_enter_evaluation_list[0].evaluate_enter_data.neighbor_min_lvl == 1);
        assert(mm1.evaluate_enter_evaluation_list[0].evaluate_enter_data.min_lvl == 0);
        assert(mm1.evaluate_enter_evaluation_list[0].evaluate_enter_data.evaluate_enter_id == 1234);
        assert(mm1.evaluate_enter_first_ask_lvl == 2);

        HookingMemory mm2;
        {
            Json.Node node;
            {
                HookingMemory mm = new HookingMemory();
                mm.evaluate_enter_timeout = new SerTimer(20);
                node = Json.gobject_serialize(mm);
            }
            mm2 = (HookingMemory)Json.gobject_deserialize(typeof(HookingMemory), node);
        }
        assert(! mm2.evaluate_enter_timeout.is_expired());
        assert(mm2.begin_enter_timeout == null);

        HookingMemory mm3;
        {
            Json.Node node;
            {
                HookingMemory mm = new HookingMemory();
                mm.evaluate_enter_timeout = new SerTimer(20);
                node = Json.gobject_serialize(mm);
            }
            mm3 = (HookingMemory)Json.gobject_deserialize(typeof(HookingMemory), node);
        }
        Thread.usleep(30000);
        assert(mm3.evaluate_enter_timeout.is_expired());

        HookingMemory mm4;
        {
            Json.Node node;
            {
                HookingMemory mm = new HookingMemory();
                mm.evaluate_enter_status = EvaluationStatus.PENDING;
                node = Json.gobject_serialize(mm);
            }
            mm4 = (HookingMemory)Json.gobject_deserialize(typeof(HookingMemory), node);
        }
        assert(mm4.evaluate_enter_status == EvaluationStatus.PENDING);

        HookingMemory mm5;
        {
            Json.Node node;
            {
                HookingMemory mm = new HookingMemory();
                mm.evaluate_enter_status = EvaluationStatus.TO_BE_NOTIFIED;
                node = Json.gobject_serialize(mm);
            }
            mm5 = (HookingMemory)Json.gobject_deserialize(typeof(HookingMemory), node);
        }
        assert(mm5.evaluate_enter_status == EvaluationStatus.TO_BE_NOTIFIED);

        HookingMemory mm6;
        {
            Json.Node node;
            {
                HookingMemory mm = new HookingMemory();
                mm.evaluate_enter_status = EvaluationStatus.NOTIFIED;
                node = Json.gobject_serialize(mm);
            }
            mm6 = (HookingMemory)Json.gobject_deserialize(typeof(HookingMemory), node);
        }
        assert(mm6.evaluate_enter_status == EvaluationStatus.NOTIFIED);

        HookingMemory mm7;
        {
            Json.Node node;
            {
                HookingMemory mm = new HookingMemory();
                mm.evaluate_enter_elected = new EvaluateEnterEvaluation();
                node = Json.gobject_serialize(mm);
            }
            mm7 = (HookingMemory)Json.gobject_deserialize(typeof(HookingMemory), node);
        }
        assert(mm7.evaluate_enter_elected != null);
    }

    public void test_BeginEnterData()
    {
        BeginEnterData bed0;
        {
            Json.Node node;
            {
                BeginEnterData bed = new BeginEnterData();
                node = Json.gobject_serialize(bed);
            }
            bed0 = (BeginEnterData)Json.gobject_deserialize(typeof(BeginEnterData), node);
        }
    }

    public void test_BeginEnterResult()
    {
        BeginEnterResult ber0;
        {
            Json.Node node;
            {
                BeginEnterResult ber = new BeginEnterResult();
                ber.already_entering_error = true;
                node = Json.gobject_serialize(ber);
            }
            ber0 = (BeginEnterResult)Json.gobject_deserialize(typeof(BeginEnterResult), node);
        }
        assert(ber0.already_entering_error == true);

        BeginEnterResult ber1;
        {
            Json.Node node;
            {
                BeginEnterResult ber = new BeginEnterResult();
                node = Json.gobject_serialize(ber);
            }
            ber1 = (BeginEnterResult)Json.gobject_deserialize(typeof(BeginEnterResult), node);
        }
        assert(ber1.already_entering_error == false);
    }

    public void test_CompletedEnterData()
    {
        CompletedEnterData ced0;
        {
            Json.Node node;
            {
                CompletedEnterData ced = new CompletedEnterData();
                node = Json.gobject_serialize(ced);
            }
            ced0 = (CompletedEnterData)Json.gobject_deserialize(typeof(CompletedEnterData), node);
        }
    }

    public void test_CompletedEnterResult()
    {
        CompletedEnterResult cer0;
        {
            Json.Node node;
            {
                CompletedEnterResult cer = new CompletedEnterResult();
                node = Json.gobject_serialize(cer);
            }
            cer0 = (CompletedEnterResult)Json.gobject_deserialize(typeof(CompletedEnterResult), node);
        }
    }

    public void test_AbortEnterData()
    {
        AbortEnterData aed0;
        {
            Json.Node node;
            {
                AbortEnterData aed = new AbortEnterData();
                node = Json.gobject_serialize(aed);
            }
            aed0 = (AbortEnterData)Json.gobject_deserialize(typeof(AbortEnterData), node);
        }
    }

    public void test_AbortEnterResult()
    {
        AbortEnterResult aer0;
        {
            Json.Node node;
            {
                AbortEnterResult aer = new AbortEnterResult();
                node = Json.gobject_serialize(aer);
            }
            aer0 = (AbortEnterResult)Json.gobject_deserialize(typeof(AbortEnterResult), node);
        }
    }

    public void test_entrydata()
    {
        EntryData ed0;
        {
            Json.Node node;
            {
                EntryData ed = new EntryData();
                ed.network_id = 123;
                ed.pos = new ArrayList<int>.wrap({1,0,0});
                ed.elderships = new ArrayList<int>.wrap({2,2,4});
                node = Json.gobject_serialize(ed);
            }
            ed0 = (EntryData)Json.gobject_deserialize(typeof(EntryData), node);
        }
        assert(ed0.network_id == 123);
        assert(ed0.pos.size == 3);
        assert(ed0.pos[0] == 1);
        assert(ed0.pos[1] == 0);
        assert(ed0.pos[2] == 0);
        assert(ed0.elderships.size == 3);
        assert(ed0.elderships[0] == 2);
        assert(ed0.elderships[1] == 2);
        assert(ed0.elderships[2] == 4);
    }

    TupleGNode make_tuplegnode()
    {
        return new TupleGNode(new ArrayList<int>.wrap({1,0,0}), new ArrayList<int>.wrap({2,2,4}));
    }

    void assert_tuplegnode(TupleGNode tg0)
    {
        assert(tg0.pos.size == 3);
        assert(tg0.pos[0] == 1);
        assert(tg0.pos[1] == 0);
        assert(tg0.pos[2] == 0);
        assert(tg0.eldership.size == 3);
        assert(tg0.eldership[0] == 2);
        assert(tg0.eldership[1] == 2);
        assert(tg0.eldership[2] == 4);
    }

    TupleGNode make_tuplegnode2()
    {
        return new TupleGNode(new ArrayList<int>.wrap({0,1,2,2}), new ArrayList<int>.wrap({2,2,4,4}));
    }

    void assert_tuplegnode2(TupleGNode tg0)
    {
        assert(tg0.pos.size == 4);
        assert(tg0.pos[0] == 0);
        assert(tg0.pos[1] == 1);
        assert(tg0.pos[2] == 2);
        assert(tg0.pos[3] == 2);
        assert(tg0.eldership.size == 4);
        assert(tg0.eldership[0] == 2);
        assert(tg0.eldership[1] == 2);
        assert(tg0.eldership[2] == 4);
        assert(tg0.eldership[3] == 4);
    }

    public void test_tuple()
    {
        TupleGNode tg0;
        {
            Json.Node node;
            {
                TupleGNode tg = make_tuplegnode();
                node = Json.gobject_serialize(tg);
            }
            tg0 = (TupleGNode)Json.gobject_deserialize(typeof(TupleGNode), node);
        }
        assert_tuplegnode(tg0);
    }

    public void test_pathhop()
    {
        PathHop ph0;
        {
            Json.Node node;
            {
                PathHop ph = new PathHop();
                ph.visiting_gnode = make_tuplegnode();
                ph.previous_migrating_gnode = null;
                node = Json.gobject_serialize(ph);
            }
            ph0 = (PathHop)Json.gobject_deserialize(typeof(PathHop), node);
        }
        assert_tuplegnode(ph0.visiting_gnode);
        assert(ph0.previous_migrating_gnode == null);

        PathHop ph1;
        {
            Json.Node node;
            {
                PathHop ph = new PathHop();
                ph.visiting_gnode = make_tuplegnode();
                ph.previous_migrating_gnode = make_tuplegnode2();
                node = Json.gobject_serialize(ph);
            }
            ph1 = (PathHop)Json.gobject_deserialize(typeof(PathHop), node);
        }
        assert_tuplegnode(ph1.visiting_gnode);
        assert_tuplegnode2(ph1.previous_migrating_gnode);
    }

    public void test_SearchMigrationPathRequest()
    {
        SearchMigrationPathRequest pk0;
        {
            Json.Node node;
            {
                PathHop ph0 = new PathHop();
                ph0.visiting_gnode = make_tuplegnode();
                ph0.previous_migrating_gnode = null;
                PathHop ph1 = new PathHop();
                ph1.visiting_gnode = make_tuplegnode();
                ph1.previous_migrating_gnode = make_tuplegnode2();
                Gee.List<PathHop> path_hops = new ArrayList<PathHop>.wrap({ph0, ph1});
                int max_host_lvl = 4;
                int reserve_request_id = 1234;
                SearchMigrationPathRequest pk = new SearchMigrationPathRequest(path_hops, max_host_lvl, reserve_request_id);
                pk.origin = make_tuplegnode();
                pk.caller = make_tuplegnode();
                pk.pkt_id = 567;
                node = Json.gobject_serialize(pk);
            }
            pk0 = (SearchMigrationPathRequest)Json.gobject_deserialize(typeof(SearchMigrationPathRequest), node);
        }
        assert(pk0.path_hops.size == 2);
        assert_tuplegnode(pk0.path_hops[0].visiting_gnode);
        assert(pk0.path_hops[0].previous_migrating_gnode == null);
        assert_tuplegnode(pk0.path_hops[1].visiting_gnode);
        assert_tuplegnode2(pk0.path_hops[1].previous_migrating_gnode);
        assert(pk0.max_host_lvl == 4);
        assert(pk0.reserve_request_id == 1234);
        assert_tuplegnode(pk0.origin);
        assert_tuplegnode(pk0.caller);
        assert(pk0.pkt_id == 567);

        SearchMigrationPathRequest pk1;
        {
            Json.Node node;
            {
                SearchMigrationPathRequest pk = pk0;
                pk.caller = make_tuplegnode2();
                pk.path_hops.remove_at(0);
                node = Json.gobject_serialize(pk);
            }
            pk1 = (SearchMigrationPathRequest)Json.gobject_deserialize(typeof(SearchMigrationPathRequest), node);
        }
        assert(pk1.path_hops.size == 1);
        assert_tuplegnode(pk1.path_hops[0].visiting_gnode);
        assert_tuplegnode2(pk1.path_hops[0].previous_migrating_gnode);
        assert(pk1.max_host_lvl == 4);
        assert(pk1.reserve_request_id == 1234);
        assert_tuplegnode(pk1.origin);
        assert_tuplegnode2(pk1.caller);
        assert(pk1.pkt_id == 567);
    }

    public void test_SearchMigrationPathErrorPkt()
    {
        SearchMigrationPathErrorPkt pk0;
        {
            Json.Node node;
            {
                SearchMigrationPathErrorPkt pk = new SearchMigrationPathErrorPkt();
                pk.origin = make_tuplegnode();
                pk.pkt_id = 567;
                node = Json.gobject_serialize(pk);
            }
            pk0 = (SearchMigrationPathErrorPkt)Json.gobject_deserialize(typeof(SearchMigrationPathErrorPkt), node);
        }
        assert_tuplegnode(pk0.origin);
        assert(pk0.pkt_id == 567);
    }

    public void test_SearchMigrationPathResponse()
    {
        SearchMigrationPathResponse pk0;
        {
            Json.Node node;
            {
                SearchMigrationPathResponse pk = new SearchMigrationPathResponse();
                pk.pkt_id = 567;
                pk.origin = make_tuplegnode();
                pk.min_host_lvl = 2;
                pk.new_conn_vir_pos = 34534;
                pk.new_eldership = 3;
                pk.final_host_lvl = 5;
                pk.set_adjacent.add(new PairTupleGNodeInt(make_tuplegnode(), 1));
                pk.set_adjacent.add(new PairTupleGNodeInt(make_tuplegnode2(), 2));
                node = Json.gobject_serialize(pk);
            }
            pk0 = (SearchMigrationPathResponse)Json.gobject_deserialize(typeof(SearchMigrationPathResponse), node);
        }
        assert(pk0.set_adjacent.size == 2);
        assert_tuplegnode(pk0.set_adjacent[0].t);
        assert(pk0.set_adjacent[0].i == 1);
        assert_tuplegnode2(pk0.set_adjacent[1].t);
        assert(pk0.set_adjacent[1].i == 2);
        assert(pk0.pkt_id == 567);
        assert_tuplegnode(pk0.origin);
        assert(pk0.min_host_lvl == 2);
        assert(pk0.new_conn_vir_pos == 34534);
        assert(pk0.new_eldership == 3);
        assert(pk0.final_host_lvl == 5);
        assert(pk0.real_new_pos == null);
        assert(pk0.real_new_eldership == null);

        SearchMigrationPathResponse pk1;
        {
            Json.Node node;
            {
                SearchMigrationPathResponse pk = new SearchMigrationPathResponse();
                pk.pkt_id = 567;
                pk.origin = make_tuplegnode();
                pk.min_host_lvl = 2;
                node = Json.gobject_serialize(pk);
            }
            pk1 = (SearchMigrationPathResponse)Json.gobject_deserialize(typeof(SearchMigrationPathResponse), node);
        }
        assert(pk1.set_adjacent.size == 0);
    }

    public void test_ExploreGNodeRequest()
    {
        ExploreGNodeRequest pk0;
        {
            Json.Node node;
            {
                PathHop ph0 = new PathHop();
                ph0.visiting_gnode = make_tuplegnode();
                ph0.previous_migrating_gnode = null;
                PathHop ph1 = new PathHop();
                ph1.visiting_gnode = make_tuplegnode();
                ph1.previous_migrating_gnode = make_tuplegnode2();
                Gee.List<PathHop> path_hops = new ArrayList<PathHop>.wrap({ph0, ph1});
                int requested_lvl = 4;
                ExploreGNodeRequest pk = new ExploreGNodeRequest(path_hops, requested_lvl);
                pk.origin = make_tuplegnode();
                pk.pkt_id = 567;
                node = Json.gobject_serialize(pk);
            }
            pk0 = (ExploreGNodeRequest)Json.gobject_deserialize(typeof(ExploreGNodeRequest), node);
        }
        assert(pk0.path_hops.size == 2);
        assert_tuplegnode(pk0.path_hops[0].visiting_gnode);
        assert(pk0.path_hops[0].previous_migrating_gnode == null);
        assert_tuplegnode(pk0.path_hops[1].visiting_gnode);
        assert_tuplegnode2(pk0.path_hops[1].previous_migrating_gnode);
        assert(pk0.requested_lvl == 4);
        assert_tuplegnode(pk0.origin);
        assert(pk0.pkt_id == 567);

        ExploreGNodeRequest pk1;
        {
            Json.Node node;
            {
                ExploreGNodeRequest pk = pk0;
                pk.path_hops.remove_at(0);
                node = Json.gobject_serialize(pk);
            }
            pk1 = (ExploreGNodeRequest)Json.gobject_deserialize(typeof(ExploreGNodeRequest), node);
        }
        assert(pk1.path_hops.size == 1);
        assert_tuplegnode(pk1.path_hops[0].visiting_gnode);
        assert_tuplegnode2(pk1.path_hops[0].previous_migrating_gnode);
        assert(pk1.requested_lvl == 4);
        assert_tuplegnode(pk1.origin);
        assert(pk1.pkt_id == 567);
    }

    public void test_ExploreGNodeResponse()
    {
        ExploreGNodeResponse pk0;
        {
            Json.Node node;
            {
                ExploreGNodeResponse pk = new ExploreGNodeResponse();
                pk.pkt_id = 567;
                pk.origin = make_tuplegnode();
                pk.result = make_tuplegnode2();
                node = Json.gobject_serialize(pk);
            }
            pk0 = (ExploreGNodeResponse)Json.gobject_deserialize(typeof(ExploreGNodeResponse), node);
        }
        assert(pk0.pkt_id == 567);
        assert_tuplegnode(pk0.origin);
        assert_tuplegnode2(pk0.result);
    }

    public void test_DeleteReservationRequest()
    {
        DeleteReservationRequest pk0;
        {
            Json.Node node;
            {
                DeleteReservationRequest pk = new DeleteReservationRequest();
                pk.reserve_request_id = 567;
                pk.dest_gnode = make_tuplegnode();
                node = Json.gobject_serialize(pk);
            }
            pk0 = (DeleteReservationRequest)Json.gobject_deserialize(typeof(DeleteReservationRequest), node);
        }
        assert(pk0.reserve_request_id == 567);
        assert_tuplegnode(pk0.dest_gnode);
    }

    public void test_RequestPacket_prepare()
    {
        RequestPacket pk0;
        {
            Json.Node node;
            {
                RequestPacket pk = new RequestPacket();
                pk.pkt_id = 567;
                pk.dest = make_tuplegnode();
                pk.src = make_tuplegnode2();
                pk.operation = RequestPacketType.PREPARE_MIGRATION;
                pk.migration_id = 890;
                node = Json.gobject_serialize(pk);
            }
            pk0 = (RequestPacket)Json.gobject_deserialize(typeof(RequestPacket), node);
        }
        assert(pk0.pkt_id == 567);
        assert_tuplegnode(pk0.dest);
        assert_tuplegnode2(pk0.src);
        assert(pk0.operation == RequestPacketType.PREPARE_MIGRATION);
        assert(pk0.migration_id == 890);
    }

    public void test_RequestPacket_finish()
    {
        RequestPacket pk0;
        {
            Json.Node node;
            {
                RequestPacket pk = new RequestPacket();
                pk.pkt_id = 567;
                pk.dest = make_tuplegnode();
                pk.src = make_tuplegnode2();
                pk.operation = RequestPacketType.FINISH_MIGRATION;
                pk.migration_id = 890;
                pk.conn_gnode_pos = 5;
                pk.host_gnode = make_tuplegnode();
                pk.real_new_pos = 1;
                pk.real_new_eldership = 3;
                node = Json.gobject_serialize(pk);
            }
            pk0 = (RequestPacket)Json.gobject_deserialize(typeof(RequestPacket), node);
        }
        assert(pk0.pkt_id == 567);
        assert_tuplegnode(pk0.dest);
        assert_tuplegnode2(pk0.src);
        assert(pk0.operation == RequestPacketType.FINISH_MIGRATION);
        assert(pk0.migration_id == 890);
        assert(pk0.conn_gnode_pos == 5);
        assert_tuplegnode(pk0.host_gnode);
        assert(pk0.real_new_pos == 1);
        assert(pk0.real_new_eldership == 3);
    }

    public void test_ResponsePacket()
    {
        ResponsePacket pk0;
        {
            Json.Node node;
            {
                ResponsePacket pk = new ResponsePacket();
                pk.pkt_id = 567;
                pk.dest = make_tuplegnode();
                node = Json.gobject_serialize(pk);
            }
            pk0 = (ResponsePacket)Json.gobject_deserialize(typeof(ResponsePacket), node);
        }
        assert(pk0.pkt_id == 567);
        assert_tuplegnode(pk0.dest);
    }

    public static int main(string[] args)
    {
        GLib.Test.init(ref args);
        GLib.Test.add_func ("/Serializables/NetworkData", () => {
            var x = new HookingTester();
            x.set_up();
            x.test_NetworkData();
            x.tear_down();
        });
        GLib.Test.add_func ("/Serializables/EvaluateEnterData", () => {
            var x = new HookingTester();
            x.set_up();
            x.test_EvaluateEnterData();
            x.tear_down();
        });
        GLib.Test.add_func ("/Serializables/EvaluateEnterResult", () => {
            var x = new HookingTester();
            x.set_up();
            x.test_EvaluateEnterResult();
            x.tear_down();
        });
        GLib.Test.add_func ("/Serializables/EvaluateEnterEvaluation", () => {
            var x = new HookingTester();
            x.set_up();
            x.test_EvaluateEnterEvaluation();
            x.tear_down();
        });
        GLib.Test.add_func ("/Serializables/HookingMemory", () => {
            var x = new HookingTester();
            x.set_up();
            x.test_HookingMemory();
            x.tear_down();
        });
        GLib.Test.add_func ("/Serializables/BeginEnterData", () => {
            var x = new HookingTester();
            x.set_up();
            x.test_BeginEnterData();
            x.tear_down();
        });
        GLib.Test.add_func ("/Serializables/BeginEnterResult", () => {
            var x = new HookingTester();
            x.set_up();
            x.test_BeginEnterResult();
            x.tear_down();
        });
        GLib.Test.add_func ("/Serializables/CompletedEnterData", () => {
            var x = new HookingTester();
            x.set_up();
            x.test_CompletedEnterData();
            x.tear_down();
        });
        GLib.Test.add_func ("/Serializables/CompletedEnterResult", () => {
            var x = new HookingTester();
            x.set_up();
            x.test_CompletedEnterResult();
            x.tear_down();
        });
        GLib.Test.add_func ("/Serializables/AbortEnterData", () => {
            var x = new HookingTester();
            x.set_up();
            x.test_AbortEnterData();
            x.tear_down();
        });
        GLib.Test.add_func ("/Serializables/AbortEnterResult", () => {
            var x = new HookingTester();
            x.set_up();
            x.test_AbortEnterResult();
            x.tear_down();
        });
        GLib.Test.add_func ("/Serializables/EntryData", () => {
            var x = new HookingTester();
            x.set_up();
            x.test_entrydata();
            x.tear_down();
        });
        GLib.Test.add_func ("/Serializables/TupleGNode", () => {
            var x = new HookingTester();
            x.set_up();
            x.test_tuple();
            x.tear_down();
        });
        GLib.Test.add_func ("/Serializables/PathHop", () => {
            var x = new HookingTester();
            x.set_up();
            x.test_pathhop();
            x.tear_down();
        });
        GLib.Test.add_func ("/Serializables/SearchMigrationPathRequest", () => {
            var x = new HookingTester();
            x.set_up();
            x.test_SearchMigrationPathRequest();
            x.tear_down();
        });
        GLib.Test.add_func ("/Serializables/SearchMigrationPathErrorPkt", () => {
            var x = new HookingTester();
            x.set_up();
            x.test_SearchMigrationPathErrorPkt();
            x.tear_down();
        });
        GLib.Test.add_func ("/Serializables/SearchMigrationPathResponse", () => {
            var x = new HookingTester();
            x.set_up();
            x.test_SearchMigrationPathResponse();
            x.tear_down();
        });
        GLib.Test.add_func ("/Serializables/ExploreGNodeRequest", () => {
            var x = new HookingTester();
            x.set_up();
            x.test_ExploreGNodeRequest();
            x.tear_down();
        });
        GLib.Test.add_func ("/Serializables/ExploreGNodeResponse", () => {
            var x = new HookingTester();
            x.set_up();
            x.test_ExploreGNodeResponse();
            x.tear_down();
        });
        GLib.Test.add_func ("/Serializables/DeleteReservationRequest", () => {
            var x = new HookingTester();
            x.set_up();
            x.test_DeleteReservationRequest();
            x.tear_down();
        });
        GLib.Test.add_func ("/Serializables/RequestPacket:PREPARE_MIGRATION", () => {
            var x = new HookingTester();
            x.set_up();
            x.test_RequestPacket_prepare();
            x.tear_down();
        });
        GLib.Test.add_func ("/Serializables/RequestPacket:FINISH_MIGRATION", () => {
            var x = new HookingTester();
            x.set_up();
            x.test_RequestPacket_finish();
            x.tear_down();
        });
        GLib.Test.add_func ("/Serializables/ResponsePacket", () => {
            var x = new HookingTester();
            x.set_up();
            x.test_ResponsePacket();
            x.tear_down();
        });
        GLib.Test.run();
        return 0;
    }
}

