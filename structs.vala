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

namespace Netsukuku.Hooking
{
    internal class SolutionStep : Object
    {
        public SolutionStep
        (TupleGNode visiting_gnode,
        TupleGNode? previous_migrating_gnode=null,
        int? previous_gnode_new_conn_vir_pos=null,
        int? previous_gnode_new_eldership=null,
        SolutionStep? parent=null)
        {
            this.visiting_gnode = visiting_gnode;
            this.previous_migrating_gnode = previous_migrating_gnode;
            this.previous_gnode_new_conn_vir_pos = previous_gnode_new_conn_vir_pos;
            this.previous_gnode_new_eldership = previous_gnode_new_eldership;
            this.parent = parent;
        }

        public TupleGNode visiting_gnode;
        public TupleGNode? previous_migrating_gnode;
        public int? previous_gnode_new_conn_vir_pos;
        public int? previous_gnode_new_eldership;
        public SolutionStep? parent;

        public int get_distance()
        {
            int ret = 0;
            SolutionStep v = this;
            while (v.parent != null)
            {
                ret++;
                v = v.parent;
            }
            return ret;
        }
    }

    internal class Solution : Object
    {
        public Solution(SolutionStep leaf, int final_host_lvl, int real_new_pos, int real_new_eldership)
        {
            this.leaf = leaf;
            this.final_host_lvl = final_host_lvl;
            this.real_new_pos = real_new_pos;
            this.real_new_eldership = real_new_eldership;
        }

        public SolutionStep leaf;
        public int final_host_lvl;
        public int real_new_pos;
        public int real_new_eldership;
    }

    // TupleGNode is in file serializables

    internal TupleGNode make_tuple_from_level(int l, IHookingMapPaths map_paths)
    {
        int levels = map_paths.get_levels();
        ArrayList<int> pos = new ArrayList<int>();
        ArrayList<int> eldership = new ArrayList<int>();
        for (int i = l; i < levels; i++)
        {
            pos.add(map_paths.get_my_pos(i));
            eldership.add(map_paths.get_my_eldership(i));
        }
        return new TupleGNode(pos, eldership);
    }

    internal TupleGNode make_tuple_from_hc(HCoord hc, IHookingMapPaths map_paths)
    {
        int levels = map_paths.get_levels();
        ArrayList<int> pos = new ArrayList<int>();
        ArrayList<int> eldership = new ArrayList<int>();
        pos.add(hc.pos);
        eldership.add(map_paths.get_eldership(hc.lvl, hc.pos));
        for (int i = hc.lvl+1; i < levels; i++)
        {
            pos.add(map_paths.get_my_pos(i));
            eldership.add(map_paths.get_my_eldership(i));
        }
        return new TupleGNode(pos, eldership);
    }

    internal TupleGNode make_tuple_up_to_level(TupleGNode tuple, int l, IHookingMapPaths map_paths)
    {
        int levels = map_paths.get_levels();
        TupleGNode ret = (TupleGNode)dup_object(tuple);
        assert(levels > l);
        int posnum = levels - l;
        assert(ret.pos.size >= posnum);
        int todel = ret.pos.size - posnum;
        for (int i = 0; i < todel; i++)
        {
            ret.pos.remove_at(0);
            ret.eldership.remove_at(0);
        }
        return ret;
    }

    internal int level(TupleGNode tuple, IHookingMapPaths map_paths)
    {
        int levels = map_paths.get_levels();
        return levels - tuple.pos.size;
    }

    internal bool i_am_inside(TupleGNode tuple, IHookingMapPaths map_paths)
    {
        return tuple_contains(make_tuple_from_level(0, map_paths), tuple);
    }

    internal bool positions_equal(TupleGNode a, TupleGNode b)
    {
        if (a.pos.size != b.pos.size) return false;
        for (int i = 0; i < a.pos.size; i++)
            if (a.pos[i] != b.pos[i]) return false;
        return true;
    }

    internal bool tuple_contains(TupleGNode inside, TupleGNode outside)
    {
        if (inside.pos.size < outside.pos.size) return false;
        int d = inside.pos.size - outside.pos.size;
        for (int i = 0; i < outside.pos.size; i++)
            if (outside.pos[i] != inside.pos[i+d]) return false;
        return true;
    }

    internal HCoord tuple_to_hc(TupleGNode a, IHookingMapPaths map_paths)
    {
        int levels = map_paths.get_levels();
        int i = levels;
        int j = a.pos.size;
        assert(i >= j);
        while (true)
        {
            i--;
            j--;
            assert(i >= 0);
            assert(j >= 0);
            int my_pos = map_paths.get_my_pos(i);
            int a_pos = a.pos[j];
            if (my_pos != a_pos) return new HCoord(i, a_pos);
        }
    }

    internal IHookingManagerStub best_gw_to(TupleGNode a, IHookingMapPaths map_paths)
    {
        HCoord hc = tuple_to_hc(a, map_paths);
        return map_paths.gateway(hc.lvl, hc.pos);
    }

    // PathHop is in file serializables

    internal Gee.List<PathHop> get_path_hops(SolutionStep current)
    {
        Gee.List<PathHop> path_hops = new ArrayList<PathHop>();
        SolutionStep? hop = current;
        while (hop != null)
        {
            PathHop path_hop = new PathHop();
            path_hop.visiting_gnode = (TupleGNode)dup_object(hop.visiting_gnode);
            path_hop.previous_migrating_gnode = null;
            if (hop.previous_migrating_gnode != null)
            {
                path_hop.previous_migrating_gnode = (TupleGNode)dup_object(hop.previous_migrating_gnode);
            }
            path_hops.insert(0,path_hop);
            hop = hop.parent;
        }
        return path_hops;
    }
}

