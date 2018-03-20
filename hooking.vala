/*
 *  This file is part of Netsukuku.
 *  Copyright (C) 2017-2018 Luca Dionisi aka lukisi <luca.dionisi@gmail.com>
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
using TaskletSystem;

namespace Netsukuku.Hooking
{
    internal ITasklet tasklet;
    public class HookingManager : Object //, IHookingManagerSkeleton
    {
        public static void init(ITasklet _tasklet)
        {
            // Register serializable types
            typeof(EntryData).class_peek();
            tasklet = _tasklet;
        }

        public static void init_rngen(IRandomNumberGenerator? rngen=null, uint32? seed=null)
        {
            PRNGen.init_rngen(rngen, seed);
        }

        public Gee.List<IIdentityArc> arc_list;

        public signal void same_network(IIdentityArc ia);
        public signal void another_network(IIdentityArc ia, int64 network_id);
        public signal void do_prepare_enter(int enter_id);
        public signal void do_finish_enter(int enter_id, int guest_gnode_level, EntryData entry_data, int go_connectivity_position);
        public signal void do_prepare_migration(/* TODO */);
        public signal void do_finish_migration(/* TODO */);

        public void add_arc(IIdentityArc ia)
        {
            // TODO
            arc_list.add(ia);
        }

        public void remove_arc(IIdentityArc ia)
        {
            // TODO
        }
    }
}
