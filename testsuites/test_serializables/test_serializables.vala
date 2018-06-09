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

class HookingTester : Object
{
    public void set_up ()
    {
    }

    public void tear_down ()
    {
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

    public static int main(string[] args)
    {
        GLib.Test.init(ref args);
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
        GLib.Test.run();
        return 0;
    }
}

