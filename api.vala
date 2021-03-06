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
        // Network ID
        public abstract int64 get_network_id();

        // Network Topology
        public abstract int get_levels();
        public abstract int get_gsize(int level);
        public abstract int get_epsilon(int level);

        // Network Size
        public abstract int get_n_nodes();

        // My Position
        public abstract int get_my_pos(int level);
        public abstract int get_my_eldership(int level);
        public abstract int get_subnetlevel();

        // My Map
        public abstract bool exists(int level, int pos);
        public abstract int get_eldership(int level, int pos);
        public abstract Gee.List<IPairHCoordInt> adjacent_to_my_gnode(int level_adjacent_gnodes, int level_my_gnode);

        // My Gateways
        public abstract IHookingManagerStub? gateway(int level, int pos,
            CallerInfo? received_from=null,
            IHookingManagerStub? failed=null);
    }

    public interface IPairHCoordInt : Object
    {
        public abstract int get_level_my_gnode();
        public abstract int get_pos_my_border_gnode();
        public abstract HCoord get_hc_adjacent();
    }

    public interface ICoordinator : Object
    {
        public abstract int get_n_nodes();

        // This is going to be proxied to the coordinator of the whole network: lvl=levels
        public abstract Object evaluate_enter(Object evaluate_enter_data) throws CoordProxyError;

        public abstract Object? get_hooking_memory(int lvl) throws CoordProxyError;
        public abstract void set_hooking_memory(int lvl, Object memory) throws CoordProxyError;

        public abstract Object begin_enter(int lvl, Object begin_enter_data) throws CoordProxyError;
        public abstract Object completed_enter(int lvl, Object completed_enter_data) throws CoordProxyError;
        public abstract Object abort_enter(int lvl, Object abort_enter_data) throws CoordProxyError;

        public abstract void prepare_enter(int lvl, Object prepare_enter_data);
        public abstract void finish_enter(int lvl, Object finish_enter_data);

        public abstract void reserve(int host_lvl, int reserve_request_id, out int new_pos, out int new_eldership) throws CoordReserveError;
        public abstract void delete_reserve(int host_lvl, int reserve_request_id);

        public abstract void prepare_migration(int lvl, Object prepare_migration_data);
        public abstract void finish_migration(int lvl, Object finish_migration_data);
    }

    public errordomain CoordProxyError {GENERIC}
    public errordomain CoordReserveError {GENERIC}

    public interface IIdentityArc : Object
    {
        public abstract IHookingManagerStub get_stub();
    }
}
