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
        private IHookingMapPaths map_paths;
        private ICoordinator coord;
        private int levels;
        private Gee.List<int> gsizes;

        public ArcHandler
        (HookingManager mgr, IHookingMapPaths map_paths, ICoordinator coord)
        {
            this.mgr = mgr;
            this.map_paths = map_paths;
            levels = map_paths.get_levels();
            gsizes = new ArrayList<int>();
            for (int i = 0; i < levels; i++)
                gsizes.add(map_paths.get_gsize(i));
            this.coord = coord;
            arc_to_tasklet = new HashMap<IIdentityArc, ITaskletHandle>();
        }

        private bool i_am_real()
        {
            for (int i = 0; i < levels; i++)
                if (map_paths.get_my_pos(i) >= gsizes[i])
                    return false;
            return true;
        }

        private int get_global_timeout()
        {
            // based on size of my network
            int size = map_paths.get_n_nodes();
            // TODO
            return 10000;
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
            while (true)
            {
                if (! i_am_real())
                {
                    // I am connectivity. The tasklet terminates.
                    return;
                }
                IHookingManagerStub st = ia.get_stub();
                INetworkData resp;
                try {
                    resp = st.retrieve_network_data(false);
                } catch (StubError e) {
                    // TODO signal bad_arc
                    return;
                } catch (DeserializeError e) {
                    // TODO signal bad_arc
                    return;
                } catch (HookingNotPrincipalError e) {
                    // Peer is connectivity. The tasklet terminates.
                    return;
                }
                if (! (resp is NetworkData))
                {
                    // TODO signal bad_arc_response
                    return;
                }
                NetworkData network_data = (NetworkData)resp;
                if (network_data.network_id == map_paths.get_network_id())
                {
                    // signal same_network and tasklet terminates.
                    mgr.same_network(ia);
                    return;
                }
                // Another network. Check same topology.
                bool bad_topology = false;
                if (network_data.gsizes.size != levels) bad_topology = true;
                else
                {
                    for (int i = 0; i < levels; i++)
                    {
                        if (network_data.gsizes[i] != gsizes[i])
                        {
                            bad_topology = true;
                            break;
                        }
                    }
                }
                if (bad_topology)
                {
                    // The tasklet terminates.
                    return;
                }
                // signal another_network
                mgr.another_network(ia, network_data.network_id);
                // local evaluation
                bool proceed = false;
                bool ask_coord = false;
                int my_n_nodes = map_paths.get_n_nodes();
                if (network_data.neighbor_n_nodes == my_n_nodes) ask_coord = true;
                else if (network_data.neighbor_n_nodes > my_n_nodes)
                {
                    if (network_data.neighbor_n_nodes > my_n_nodes * 10)
                    {
                        proceed = true;
                    }
                    else
                    {
                        ask_coord = true;
                    }
                }
                else
                {
                    if (my_n_nodes > network_data.neighbor_n_nodes * 10)
                    {
                        // nop
                    }
                    else
                    {
                        ask_coord = true;
                    }
                }
                if (ask_coord)
                {
                    // local evaluation but ask the coordinator for getting size
                    proceed = false;
                    my_n_nodes = coord.get_n_nodes();
                    try {
                        resp = st.retrieve_network_data(true);
                    } catch (StubError e) {
                        // TODO signal bad_arc
                        return;
                    } catch (DeserializeError e) {
                        // TODO signal bad_arc
                        return;
                    } catch (HookingNotPrincipalError e) {
                        // Peer is connectivity. The tasklet terminates.
                        return;
                    }
                    if (! (resp is NetworkData))
                    {
                        // TODO signal bad_arc_response
                        return;
                    }
                    network_data = (NetworkData)resp;
                    if (network_data.neighbor_n_nodes > my_n_nodes) proceed = true;
                    else if (network_data.neighbor_n_nodes == my_n_nodes && network_data.network_id > map_paths.get_network_id()) proceed = true;
                }
                if (! proceed)
                {
                    // Wait a long time, then redo from start.
                    tasklet.ms_wait(600000); // 10 minutes
                    continue;
                }
                // network-wide evaluation
                EvaluateEnterData evaluate_enter_data = new EvaluateEnterData();
                evaluate_enter_data.min_lvl = map_paths.get_subnetlevel();
                evaluate_enter_data.evaluate_enter_id = PRNGen.int_range(0, int.MAX);
                // call evaluate_enter iteratively
                int ret = 0;
                bool redo_from_start  = false;
                while (true)
                {
                    try {
                        ret = ProxyCoord.evaluate_enter(coord.evaluate_enter, levels, evaluate_enter_data);
                    } catch (CoordProxyError e) {
                        warning("CoordProxyError in ProxyCoord.evaluate_enter. Abort arc_handler.");
                        return;
                    } catch (ProxyCoord.UnknownResultError e) {
                        warning("ProxyCoord.UnknownResultError in ProxyCoord.evaluate_enter. Abort arc_handler.");
                        return;
                    } catch (ProxyCoord.AskAgainError e) {
                        // Wait a little, then redo evaluate.
                        tasklet.ms_wait(get_global_timeout() / 4);
                        continue;
                    } catch (ProxyCoord.IgnoreNetworkError e) {
                        // Wait long time, the redo from start.
                        tasklet.ms_wait(get_global_timeout() / 4);
                        redo_from_start  = true;
                        break;
                    }
                    break;
                }
                if (redo_from_start) continue;
                // ret has been computed.
                // TODO begin_enter
            }
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