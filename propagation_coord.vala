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
            coord.prepare_enter(lvl, prepare_enter_data);
        }

        internal void execute_propagate_prepare_enter(int lvl, Object prepare_enter_data)
        {
            if (! (prepare_enter_data is PrepareEnterData)) tasklet.exit_tasklet(null);
            execute_prepare_enter(lvl, (PrepareEnterData)prepare_enter_data);
        }

        internal void execute_prepare_enter(int lvl, PrepareEnterData prepare_enter_data)
        {
            mgr.do_prepare_enter(prepare_enter_data.enter_id);
        }

        internal void finish_enter(int lvl, FinishEnterData finish_enter_data)
        {
            coord.finish_enter(lvl, finish_enter_data);
        }

        internal void execute_propagate_finish_enter(int lvl, Object finish_enter_data)
        {
            if (! (finish_enter_data is FinishEnterData)) tasklet.exit_tasklet(null);
            execute_finish_enter(lvl, (FinishEnterData)finish_enter_data);
        }

        internal void execute_finish_enter(int lvl, FinishEnterData finish_enter_data)
        {
            mgr.do_finish_enter(finish_enter_data.enter_id, lvl /*guest_gnode_level*/, finish_enter_data.entry_data, finish_enter_data.go_connectivity_position);
        }
    }
}
