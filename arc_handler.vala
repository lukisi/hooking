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

namespace Netsukuku.Hooking.ArcHandler
{
    internal class ArcHandler : Object
    {
        private HashMap<IIdentityArc, ITaskletHandle> arc_to_tasklet;
        private HookingManager mgr;

        public ArcHandler
        (HookingManager mgr)
        {
            this.mgr = mgr;
            arc_to_tasklet = new HashMap<IIdentityArc, ITaskletHandle>();
        }

        public void add_arc(IIdentityArc ia)
        {
            if (arc_to_tasklet.has_key(ia)) return;
            // spawn tasklet
            AddArcTasklet ts = new AddArcTasklet();
            ts.t = this;
            ts.ia = ia;
            ITaskletHandle th = tasklet.spawn(ts);
            arc_to_tasklet[ia] = th;
        }

        private class AddArcTasklet : Object, ITaskletSpawnable
        {
            public ArcHandler t;
            public IIdentityArc ia;
            public void * func()
            {
                t.add_arc_tasklet(ia);
                return null;
            }
        }
        private void add_arc_tasklet(IIdentityArc ia)
        {
            // TODO
        }

        public void remove_arc(IIdentityArc ia)
        {
            if (! arc_to_tasklet.has_key(ia)) return;
            ITaskletHandle th = arc_to_tasklet[ia];
            if (th.is_running()) th.kill();
            arc_to_tasklet.unset(ia);
        }
    }
}
