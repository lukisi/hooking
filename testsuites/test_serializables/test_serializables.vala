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

    public void test_tuple()
    {
        TupleGNode tg0;
        {
            Json.Node node;
            {
                TupleGNode tg = new TupleGNode(new ArrayList<int>.wrap({1,0,0}), new ArrayList<int>.wrap({2,2,4}));
                node = Json.gobject_serialize(tg);
            }
            tg0 = (TupleGNode)Json.gobject_deserialize(typeof(TupleGNode), node);
        }
        assert(tg0.pos.size == 3);
        assert(tg0.pos[0] == 1);
        assert(tg0.pos[1] == 0);
        assert(tg0.pos[2] == 0);
        assert(tg0.eldership.size == 3);
        assert(tg0.eldership[0] == 2);
        assert(tg0.eldership[1] == 2);
        assert(tg0.eldership[2] == 4);
    }

    public static int main(string[] args)
    {
        GLib.Test.init(ref args);
        GLib.Test.add_func ("/Serializables/TupleGNode", () => {
            var x = new HookingTester();
            x.set_up();
            x.test_tuple();
            x.tear_down();
        });
        GLib.Test.run();
        return 0;
    }
}

