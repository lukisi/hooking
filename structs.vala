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
        public TupleGNode visiting_gnode;
        public TupleGNode? previous_migrating_gnode;
        public int? previous_gnode_new_conn_vir_pos;
        public int? previous_gnode_new_eldership;
        public SolutionStep? parent;
    }

    internal class Solution : Object
    {
        public SolutionStep leaf;
        public int final_host_lvl;
        public int real_new_pos;
        public int real_new_eldership;
    }

    // TupleGNode is in file serializables

    internal int level(TupleGNode tuple, int levels)
    {
        return levels - tuple.pos.size;
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

