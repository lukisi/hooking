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
    public interface IHookingMapPaths : Object
    {
        public abstract int get_levels();
        public abstract int get_gsize(int level);
        public abstract int get_my_pos(int level);
        public abstract int get_my_eldership(int level);
        public abstract bool exists(int level, int pos);
        public abstract int get_eldership(int level, int pos);
        public abstract IHookingManagerStub gateway(int level, int pos);
    }

    public interface IIdentityArc : Object
    {
    }

    // TODO delegates or a interface?
    public errordomain CoordReserveError {GENERIC}
    public delegate void CoordReserve(int host_lvl, int reserve_request_id, out int new_pos, out int new_eldership) throws CoordReserveError;

    public class PairHCoordInt : Object
    {
        public int level_my_gnode;
        public int pos_my_border_gnode;
        public HCoord hc_adjacent;
    }
    public delegate Gee.List<PairHCoordInt> AdjacentToMyGnode(int level_adjacent_gnodes, int level_my_gnode);
}
