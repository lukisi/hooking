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
using TaskletSystem;
using Netsukuku.Hooking;

namespace Netsukuku.Hooking.PropagationCoord
{
    internal class PropagationCoord : Object
    {
        private HookingManager mgr;
        private IHookingMapPaths map_paths;
        private ICoordinator coord;
        private int levels;
        private Gee.List<int> gsizes;
        private int subnetlevel;
        public PropagationCoord
        (HookingManager mgr, IHookingMapPaths map_paths, ICoordinator coord)
        {
            this.mgr = mgr;
            this.map_paths = map_paths;
            levels = map_paths.get_levels();
            gsizes = new ArrayList<int>();
            for (int i = 0; i < levels; i++)
                gsizes.add(map_paths.get_gsize(i));
            subnetlevel = map_paths.get_subnetlevel();
            this.coord = coord;
        }

        internal void prepare_enter(int lvl, PrepareEnterData prepare_enter_data)
        {
            debug(@"PropagationCoord: as the initiator, to all the members of g-node of level $(lvl): execute prepare_enter!");
            coord.prepare_enter(lvl, prepare_enter_data);
            // This will return only when all the nodes in the cluster have completed.
            debug(@"PropagationCoord: as the initiator, to my knowledge all the members of g-node of level $(lvl) have executed prepare_enter.");
        }

        internal void execute_propagate_prepare_enter(int lvl, Object prepare_enter_data)
        {
            if (! (prepare_enter_data is PrepareEnterData)) tasklet.exit_tasklet(null);
            execute_prepare_enter(lvl, (PrepareEnterData)prepare_enter_data);
        }

        internal void execute_prepare_enter(int lvl, PrepareEnterData prepare_enter_data)
        {
            debug(@"PropagationCoord: as member of g-node of level $(lvl), executing prepare_enter.");
            mgr.do_prepare_enter(prepare_enter_data.enter_id);
        }

        internal void finish_enter(int lvl, FinishEnterData finish_enter_data)
        {
            debug(@"PropagationCoord: as the initiator, to all the members of g-node of level $(lvl): execute finish_enter!");
            coord.finish_enter(lvl, finish_enter_data);
            // This will return quite soon, cause the real stuff is done in a tasklet by the Coord.
            debug(@"PropagationCoord: as the initiator, the propagation started to all the members of g-node of level $(lvl) to execute finish_enter.");
        }

        internal void execute_propagate_finish_enter(int lvl, Object finish_enter_data)
        {
            if (! (finish_enter_data is FinishEnterData)) tasklet.exit_tasklet(null);
            execute_finish_enter(lvl, (FinishEnterData)finish_enter_data);
        }

        internal void execute_finish_enter(int lvl, FinishEnterData finish_enter_data)
        {
            debug(@"PropagationCoord: as member of g-node of level $(lvl), executing finish_enter.");
            mgr.do_finish_enter
                (finish_enter_data.enter_id, lvl /*guest_gnode_level*/,
                finish_enter_data.entry_data, finish_enter_data.go_connectivity_position);
        }

        internal void prepare_migration(int lvl, PrepareMigrationData prepare_migration_data)
        {
            debug(@"PropagationCoord: as the initiator, to all the members of g-node of level $(lvl): execute prepare_migration!");
            coord.prepare_migration(lvl, prepare_migration_data);
            // This will return only when all the nodes in the cluster have completed.
            debug(@"PropagationCoord: as the initiator, to my knowledge all the members of g-node of level $(lvl) have executed prepare_migration.");
        }

        internal void execute_propagate_prepare_migration(int lvl, Object prepare_migration_data)
        {
            if (! (prepare_migration_data is PrepareMigrationData)) tasklet.exit_tasklet(null);
            execute_prepare_migration(lvl, (PrepareMigrationData)prepare_migration_data);
        }

        internal void execute_prepare_migration(int lvl, PrepareMigrationData prepare_migration_data)
        {
            debug(@"PropagationCoord: as member of g-node of level $(lvl), executing prepare_migration.");
            mgr.do_prepare_migration(prepare_migration_data.migration_id);
        }

        internal void finish_migration(int lvl, FinishMigrationData finish_migration_data)
        {
            debug(@"PropagationCoord: as the initiator, to all the members of g-node of level $(lvl): execute finish_migration!");
            coord.finish_migration(lvl, finish_migration_data);
            // This will return quite soon, cause the real stuff is done in a tasklet by the Coord.
            debug(@"PropagationCoord: as the initiator, the propagation started to all the members of g-node of level $(lvl) to execute finish_migration.");
        }

        internal void execute_propagate_finish_migration(int lvl, Object finish_migration_data)
        {
            if (! (finish_migration_data is FinishMigrationData)) tasklet.exit_tasklet(null);
            execute_finish_migration(lvl, (FinishMigrationData)finish_migration_data);
        }

        internal void execute_finish_migration(int lvl, FinishMigrationData finish_migration_data)
        {
            debug(@"PropagationCoord: as member of g-node of level $(lvl), executing finish_migration.");
            mgr.do_finish_migration
                (finish_migration_data.migration_id, lvl /*guest_gnode_level*/,
                finish_migration_data.migration_data, finish_migration_data.go_connectivity_position);
        }
    }
}
