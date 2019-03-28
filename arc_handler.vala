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
        private int subnetlevel;
        private ProxyCoord.ProxyCoord proxy_coord;
        private PropagationCoord.PropagationCoord propagation_coord;

        public ArcHandler
        (HookingManager mgr, IHookingMapPaths map_paths, ICoordinator coord,
        ProxyCoord.ProxyCoord proxy_coord, PropagationCoord.PropagationCoord propagation_coord)
        {
            this.mgr = mgr;
            this.map_paths = map_paths;
            levels = map_paths.get_levels();
            gsizes = new ArrayList<int>();
            for (int i = 0; i < levels; i++)
                gsizes.add(map_paths.get_gsize(i));
            subnetlevel = map_paths.get_subnetlevel();
            this.coord = coord;
            this.proxy_coord = proxy_coord;
            this.propagation_coord = propagation_coord;
            arc_to_tasklet = new HashMap<IIdentityArc, ITaskletHandle>();
        }

        private bool i_am_real()
        {
            for (int i = 0; i < levels; i++)
                if (map_paths.get_my_pos(i) >= gsizes[i])
                    return false;
            return true;
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

        [NoReturn]
        private void signal_and_exit(IIdentityArc ia)
        {
            mgr.failing_arc(ia);
            if (arc_to_tasklet.has_key(ia)) arc_to_tasklet.unset(ia);
            tasklet.exit_tasklet();
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
                    warning(@"Hooking.ArcHandler.tasklet: StubError: bad arc. Terminating.");
                    signal_and_exit(ia);
                } catch (DeserializeError e) {
                    warning(@"Hooking.ArcHandler.tasklet: DeserializeError: bad arc. Terminating.");
                    signal_and_exit(ia);
                } catch (NotBootstrappedError e) {
                    // wait and redo
                    tasklet.ms_wait(1000);
                    continue;
                } catch (HookingNotPrincipalError e) {
                    // Peer is connectivity. The tasklet terminates.
                    return;
                }
                if (! (resp is NetworkData))
                {
                    warning(@"Hooking.ArcHandler.tasklet: Not instance of NetworkData: bad arc response. Terminating.");
                    signal_and_exit(ia);
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
                    warning(@"Hooking.ArcHandler.tasklet: Not same topology. Terminating.");
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
                        warning(@"Hooking.ArcHandler.tasklet: StubError: bad arc. Terminating.");
                        signal_and_exit(ia);
                    } catch (DeserializeError e) {
                        warning(@"Hooking.ArcHandler.tasklet: DeserializeError: bad arc. Terminating.");
                        signal_and_exit(ia);
                    } catch (NotBootstrappedError e) {
                        // should not happen already
                        warning(@"Hooking.ArcHandler.tasklet: NotBootstrappedError should not happen there: bad arc. Terminating.");
                        signal_and_exit(ia);
                    } catch (HookingNotPrincipalError e) {
                        // Peer is connectivity. The tasklet terminates.
                        return;
                    }
                    if (! (resp is NetworkData))
                    {
                        warning(@"Hooking.ArcHandler.tasklet: Not instance of NetworkData: bad arc response. Terminating.");
                        signal_and_exit(ia);
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
                evaluate_enter_data.network_id = network_data.network_id;
                evaluate_enter_data.neighbor_min_lvl = network_data.neighbor_min_level;
                evaluate_enter_data.neighbor_pos = new ArrayList<int>();
                evaluate_enter_data.neighbor_pos.add_all(network_data.neighbor_pos);
                // call evaluate_enter iteratively
                int ask_lvl = 0;
                bool redo_from_start  = false;
                while (true)
                {
                    try {
                        ask_lvl = proxy_coord.evaluate_enter(evaluate_enter_data);
                    } catch (CoordProxyError e) {
                        warning("CoordProxyError in ProxyCoord.evaluate_enter. Abort arc_handler.");
                        return;
                    } catch (ProxyCoord.UnknownResultError e) {
                        warning("ProxyCoord.UnknownResultError in ProxyCoord.evaluate_enter. Abort arc_handler.");
                        return;
                    } catch (ProxyCoord.AskAgainError e) {
                        // Wait a little, then redo evaluate.
                        tasklet.ms_wait(get_global_timeout(map_paths.get_n_nodes()) / 4);
                        continue;
                    } catch (ProxyCoord.IgnoreNetworkError e) {
                        // Wait long time, the redo from start.
                        tasklet.ms_wait(get_global_timeout(map_paths.get_n_nodes()) * 20);
                        redo_from_start  = true;
                        break;
                    }
                    break;
                }
                if (redo_from_start) continue;
                EntryData entry_data = null;
                while (true)
                {
                    bool redo_from_begin_enter = false;
                    // ask_lvl has been computed.
                    // ask to coordinator of g-node of level ask_lvl to begin enter
                    BeginEnterData begin_enter_data = new BeginEnterData();
                    // call begin_enter
                    try {
                        proxy_coord.begin_enter(ask_lvl, begin_enter_data);
                    } catch (CoordProxyError e) {
                        warning("CoordProxyError in ProxyCoord.begin_enter. Abort arc_handler.");
                        return;
                    } catch (ProxyCoord.UnknownResultError e) {
                        warning("ProxyCoord.UnknownResultError in ProxyCoord.begin_enter. Abort arc_handler.");
                        return;
                    } catch (ProxyCoord.AlreadyEnteringError e) {
                        // Wait long time, the redo from start.
                        tasklet.ms_wait(get_global_timeout(map_paths.get_n_nodes()) * 20);
                        redo_from_start = true;
                        break;
                    }
                    // try and enter
                    while (true)
                    {
                        IEntryData resp2;
                        try {
                            debug(@"ArcHandler.add_arc_tasklet: calling stub search_migration_path");
                            resp2 = st.search_migration_path(ask_lvl);
                            debug(@"ArcHandler.add_arc_tasklet: stub search_migration_path returns a IEntryData");
                        } catch (StubError e) {
                            warning(@"Hooking.ArcHandler.tasklet: StubError: bad arc. Terminating.");
                            signal_and_exit(ia);
                        } catch (DeserializeError e) {
                            warning(@"Hooking.ArcHandler.tasklet: DeserializeError: bad arc. Terminating.");
                            signal_and_exit(ia);
                        } catch (NotBootstrappedError e) {
                            // should not happen already
                            warning(@"Hooking.ArcHandler.tasklet: NotBootstrappedError should not happen there: bad arc. Terminating.");
                            signal_and_exit(ia);
                        } catch (NoMigrationPathFoundError e) {
                            debug(@"ArcHandler.add_arc_tasklet: stub search_migration_path returns a NoMigrationPathFoundError");
                            // ask to coordinator of g-node of level ask_lvl to abort enter
                            AbortEnterData abort_enter_data = new AbortEnterData();
                            // call abort_enter
                            try {
                                proxy_coord.abort_enter(ask_lvl, abort_enter_data);
                            } catch (CoordProxyError e) {
                                warning("CoordProxyError in ProxyCoord.abort_enter. Abort arc_handler.");
                                return;
                            } catch (ProxyCoord.UnknownResultError e) {
                                warning("ProxyCoord.UnknownResultError in ProxyCoord.abort_enter. Abort arc_handler.");
                                return;
                            }
                            if (ask_lvl == 0)
                            {
                                // network is full at level 0.
                                warning("Failed to find a migration-path for a single node in the network we just met.");
                                // Wait long time, the redo from start.
                                tasklet.ms_wait(get_global_timeout(map_paths.get_n_nodes()) * 20);
                                redo_from_start = true;
                                break;
                            }
                            else
                            {
                                // try at lower level.
                                ask_lvl--;
                                redo_from_begin_enter = true;
                                break;
                            }
                        } catch (MigrationPathExecuteFailureError e) {
                            debug(@"ArcHandler.add_arc_tasklet: stub search_migration_path returns a MigrationPathExecuteFailureError");
                            // retry immediately same lvl
                            continue;
                        }
                        if (! (resp2 is EntryData))
                        {
                            warning(@"Hooking.ArcHandler.tasklet: Not instance of EntryData: bad arc response. Terminating.");
                            signal_and_exit(ia);
                        }
                        entry_data = (EntryData)resp2;
                        break;
                    }
                    if (redo_from_begin_enter) continue;
                    break;
                }
                if (redo_from_start) continue;
                // entry_data has been obtained.
                // tell to coordinator of g-node of level ask_lvl we completed enter
                CompletedEnterData completed_enter_data = new CompletedEnterData();
                // call completed_enter
                try {
                    proxy_coord.completed_enter(ask_lvl, completed_enter_data);
                } catch (CoordProxyError e) {
                    warning("CoordProxyError in ProxyCoord.completed_enter. Abort arc_handler.");
                    return;
                } catch (ProxyCoord.UnknownResultError e) {
                    warning("ProxyCoord.UnknownResultError in ProxyCoord.completed_enter. Abort arc_handler.");
                    return;
                }
                // propagate prepare_enter
                int enter_id = PRNGen.int_range(1, int.MAX);
                PrepareEnterData prepare_enter_data = new PrepareEnterData(enter_id);
                propagation_coord.prepare_enter(ask_lvl, prepare_enter_data);
                // propagate finish_enter
                int go_connectivity_position = PRNGen.int_range(gsizes[ask_lvl], int.MAX);
                FinishEnterData finish_enter_data = new FinishEnterData(enter_id, entry_data, go_connectivity_position);
                propagation_coord.finish_enter(ask_lvl, finish_enter_data);
                return;
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
