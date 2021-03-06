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

namespace Netsukuku.Hooking.ProxyCoord
{
    internal errordomain UnknownResultError {GENERIC}

    internal errordomain AskAgainError {GENERIC}
    internal errordomain IgnoreNetworkError {GENERIC}

    internal errordomain AlreadyEnteringError {GENERIC}

    internal class ProxyCoord : Object
    {
        private HookingManager mgr;
        private IHookingMapPaths map_paths;
        private ICoordinator coord;
        private int levels;
        private Gee.List<int> gsizes;
        private int subnetlevel;
        private bool lock_evaluate_enter;
        private int? _lock_hooking_memory;
        public ProxyCoord
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
            lock_evaluate_enter = false;
            _lock_hooking_memory = null;
        }

        internal int evaluate_enter(EvaluateEnterData evaluate_enter_data)
        throws AskAgainError, IgnoreNetworkError, CoordProxyError, UnknownResultError
        {
            Object _ret = coord.evaluate_enter(evaluate_enter_data);
            if (! (_ret is EvaluateEnterResult)) throw new UnknownResultError.GENERIC("");
            EvaluateEnterResult ret = (EvaluateEnterResult)_ret;
            if (ret.ask_again_error) throw new AskAgainError.GENERIC("");
            if (ret.ignore_network_error) throw new IgnoreNetworkError.GENERIC("");
            return ret.first_ask_lvl;
        }

        internal Object execute_proxy_evaluate_enter(Object evaluate_enter_data, Gee.List<int> client_address)
        {
            if (! (evaluate_enter_data is EvaluateEnterData)) tasklet.exit_tasklet(null);
            while (lock_evaluate_enter) tasklet.ms_wait(10);
            lock_evaluate_enter = true;
            int lock_id = lock_hooking_memory();
            var ret = new EvaluateEnterResult();
            try {
                int retval = execute_evaluate_enter(lock_id, (EvaluateEnterData)evaluate_enter_data, client_address);
                ret.first_ask_lvl = retval;
            } catch (AskAgainError e) {
                ret.ask_again_error = true;
            } catch (IgnoreNetworkError e) {
                ret.ignore_network_error = true;
            }
            unlock_hooking_memory(lock_id);
            lock_evaluate_enter = false;
            return ret;
        }

        internal int execute_evaluate_enter(int lock_id, EvaluateEnterData evaluate_enter_data, Gee.List<int> client_address)
        throws AskAgainError, IgnoreNetworkError
        {
            debug(@"ProxyCoord: as coordinator of the entire network, executing evaluate_enter.");
            // enable a redo_from_start
            while (true)
            {
                int global_timeout = get_global_timeout(map_paths.get_n_nodes());
                int64 network_id = evaluate_enter_data.network_id;
                // get memory
                HookingMemory memory = get_hooking_memory(lock_id, levels);
                if (memory.evaluate_enter_status == null)
                {
                    // first evaluation
                    debug(@"ProxyCoord.evaluate_enter: first evaluation.");
                    assert(memory.evaluate_enter_evaluation_list.is_empty);
                    int max_lvl = subnetlevel;
                    for (int i = subnetlevel; i < levels-1; i++)
                    {
                        bool some_one_of_level_i = false;
                        int my_pos_at_i = map_paths.get_my_pos(i);
                        for (int j = 0; j < gsizes[i]; j++) if (j != my_pos_at_i)
                        {
                            if (map_paths.exists(i,j))
                            {
                                some_one_of_level_i = true;
                                break;
                            }
                        }
                        if (some_one_of_level_i)
                        {
                            max_lvl = i + 1;
                        }
                    }
                    EvaluateEnterEvaluation v = new EvaluateEnterEvaluation();
                    v.client_address = new ArrayList<int>();
                    v.client_address.add_all(client_address);
                    v.evaluate_enter_data = evaluate_enter_data;
                    memory.evaluate_enter_evaluation_list.add(v);
                    memory.evaluate_enter_timeout = new SerTimer(global_timeout);
                    memory.evaluate_enter_status = EvaluationStatus.PENDING;
                    memory.evaluate_enter_first_ask_lvl = max_lvl;
                    // set memory
                    set_hooking_memory(lock_id, levels, memory);
                    // ask again
                    throw new AskAgainError.GENERIC("");
                }
                // not first evaluation
                int max_lvl = memory.evaluate_enter_first_ask_lvl;
                // if not same network in progress, then ignore network
                int64 prev_network_id = memory.evaluate_enter_evaluation_list[0].evaluate_enter_data.network_id;
                if (prev_network_id != network_id) throw new IgnoreNetworkError.GENERIC("");
                // did I already evaluate this?
                EvaluateEnterEvaluation? v = null;
                foreach (EvaluateEnterEvaluation v1 in memory.evaluate_enter_evaluation_list)
                {
                    if (v1.evaluate_enter_data.evaluate_enter_id == evaluate_enter_data.evaluate_enter_id)
                    {
                        v = v1;
                        break;
                    }
                }
                // or is it new?
                if (v == null)
                {
                    debug(@"ProxyCoord.evaluate_enter: another evaluation same network.");
                    v = new EvaluateEnterEvaluation();
                    v.client_address = new ArrayList<int>();
                    v.client_address.add_all(client_address);
                    v.evaluate_enter_data = evaluate_enter_data;
                    memory.evaluate_enter_evaluation_list.add(v);
                }
                if (memory.evaluate_enter_status == EvaluationStatus.PENDING &&
                    ! memory.evaluate_enter_timeout.is_expired())
                {
                    // set memory
                    debug(@"ProxyCoord.evaluate_enter: evaluation not yet expired.");
                    set_hooking_memory(lock_id, levels, memory);
                    // ask again
                    throw new AskAgainError.GENERIC("");
                }
                if (memory.evaluate_enter_status == EvaluationStatus.PENDING &&
                    memory.evaluate_enter_timeout.is_expired())
                {
                    // elect evaluation
                    debug(@"ProxyCoord.evaluate_enter: elect evaluation among $(memory.evaluate_enter_evaluation_list.size) candidates.");
                    Gee.List<EvaluateEnterEvaluation> candidates = new ArrayList<EvaluateEnterEvaluation>();
                    // if max_lvl < levels-1 then we should evaluate in which host gnode we could go.
                    if (max_lvl < levels-1)
                    {
                        // in particular how many arcs we'll have towards a certain host gnode.
                        int max_size = 0;
                        HashMap<string,ArrayList<EvaluateEnterEvaluation>> group_by_host = new HashMap<string,ArrayList<EvaluateEnterEvaluation>>();
                        foreach (EvaluateEnterEvaluation eev in memory.evaluate_enter_evaluation_list)
                        {
                            Gee.List<int> neighbor_pos = eev.evaluate_enter_data.neighbor_pos;
                            // compute host at max_lvl+1
                            string host = "";
                            for (int j = levels-1; j > max_lvl; j--) host += @"$(neighbor_pos[j]).";
                            if (! group_by_host.has_key(host)) group_by_host[host] = new ArrayList<EvaluateEnterEvaluation>();
                            group_by_host[host].add(eev);
                            if (max_size < group_by_host[host].size) max_size = group_by_host[host].size;
                        }
                        foreach (string host in group_by_host.keys) if (group_by_host[host].size == max_size)
                        {
                            candidates.add_all(group_by_host[host]);
                        }
                    } // otherwise, if max_lvl = levels-1, any arc will do.
                    else candidates.add_all(memory.evaluate_enter_evaluation_list);
                    debug(@"ProxyCoord.evaluate_enter: elect evaluation among $(candidates.size) candidates.");
                    assert(candidates.size > 0);
                    // choose the one with the lowest possible lvl.
                    int elected_i = -1;
                    int j = 0;
                    int min_lvl = levels;
                    int max_evaluate_enter_id = -1;
                    while (true)
                    {
                        EvaluateEnterEvaluation jj = candidates[j];
                        int jj_min_lvl = jj.evaluate_enter_data.min_lvl;
                        int jj_evaluate_enter_id = jj.evaluate_enter_data.evaluate_enter_id;
                        if (jj_min_lvl > jj.evaluate_enter_data.neighbor_min_lvl) jj_min_lvl = jj.evaluate_enter_data.neighbor_min_lvl;
                        if (jj_min_lvl < min_lvl ||
                            (jj_min_lvl == min_lvl && jj_evaluate_enter_id > max_evaluate_enter_id))
                        {
                            min_lvl = jj_min_lvl;
                            max_evaluate_enter_id = jj_evaluate_enter_id;
                            elected_i = j;
                        }
                        j++;
                        if (j >= candidates.size) break;
                    }
                    assert(elected_i >= 0);
                    debug(@"ProxyCoord.evaluate_enter: elected request #$(max_evaluate_enter_id).");
                    EvaluateEnterEvaluation elected = candidates[elected_i];
                    // update memory
                    memory.evaluate_enter_elected = elected;
                    memory.evaluate_enter_timeout = new SerTimer(global_timeout);
                    memory.evaluate_enter_status = EvaluationStatus.TO_BE_NOTIFIED;
                    if (elected == v)
                    {
                        debug(@"ProxyCoord.evaluate_enter: elected this request at level $(max_lvl).");
                        memory.evaluate_enter_evaluation_list.remove(v);
                        if (memory.evaluate_enter_evaluation_list.is_empty)
                        {
                            memory.evaluate_enter_timeout = null;
                            memory.evaluate_enter_elected = null;
                            memory.evaluate_enter_first_ask_lvl = -1;
                            memory.evaluate_enter_status = null;
                        }
                        else
                        {
                            memory.evaluate_enter_status = EvaluationStatus.NOTIFIED;
                        }
                        // set memory
                        set_hooking_memory(lock_id, levels, memory);
                        // return
                        debug(@"ProxyCoord.evaluate_enter: return max_lvl=$(max_lvl).");
                        return max_lvl;
                    }
                    else
                    {
                        debug(@"ProxyCoord.evaluate_enter: elected one request, but not this one.");
                        // set memory
                        set_hooking_memory(lock_id, levels, memory);
                        // ask again
                        debug(@"ProxyCoord.evaluate_enter: throw ask_again.");
                        throw new AskAgainError.GENERIC("");
                    }
                }
                if (memory.evaluate_enter_status == EvaluationStatus.TO_BE_NOTIFIED)
                {
                    if (memory.evaluate_enter_elected == v)
                    {
                        memory.evaluate_enter_evaluation_list.remove(v);
                        if (memory.evaluate_enter_evaluation_list.is_empty)
                        {
                            memory.evaluate_enter_timeout = null;
                            memory.evaluate_enter_elected = null;
                            memory.evaluate_enter_first_ask_lvl = -1;
                            memory.evaluate_enter_status = null;
                        }
                        else
                        {
                            memory.evaluate_enter_status = EvaluationStatus.NOTIFIED;
                        }
                        // set memory
                        set_hooking_memory(lock_id, levels, memory);
                        // return
                        debug(@"ProxyCoord.evaluate_enter.TO_BE_NOTIFIED: elected this request at level $(max_lvl).");
                        debug(@"ProxyCoord.evaluate_enter: return max_lvl=$(max_lvl).");
                        return max_lvl;
                    }
                    else if (memory.evaluate_enter_timeout.is_expired())
                    {
                        memory.evaluate_enter_evaluation_list.remove(memory.evaluate_enter_elected);
                        if (memory.evaluate_enter_evaluation_list.is_empty)
                        {
                            memory.evaluate_enter_timeout = null;
                            memory.evaluate_enter_elected = null;
                            memory.evaluate_enter_first_ask_lvl = -1;
                            memory.evaluate_enter_status = null;
                            // set memory
                            set_hooking_memory(lock_id, levels, memory);
                            // ignore network
                            debug(@"ProxyCoord.evaluate_enter.TO_BE_NOTIFIED: throw ignore_network.");
                            throw new IgnoreNetworkError.GENERIC("");
                        }
                        else
                        {
                            memory.evaluate_enter_elected = null;
                            memory.evaluate_enter_status = EvaluationStatus.PENDING;
                        }
                        // redo_from_start
                        debug(@"ProxyCoord.evaluate_enter.TO_BE_NOTIFIED: redo_from_start.");
                        continue;
                    }
                    else
                    {
                        // set memory
                        set_hooking_memory(lock_id, levels, memory);
                        // ask again
                        debug(@"ProxyCoord.evaluate_enter.TO_BE_NOTIFIED: throw ask_again.");
                        throw new AskAgainError.GENERIC("");
                    }
                }
                if (memory.evaluate_enter_status == EvaluationStatus.NOTIFIED)
                {
                    memory.evaluate_enter_evaluation_list.remove(v);
                    if (memory.evaluate_enter_evaluation_list.is_empty)
                    {
                        memory.evaluate_enter_timeout = null;
                        memory.evaluate_enter_elected = null;
                        memory.evaluate_enter_first_ask_lvl = -1;
                        memory.evaluate_enter_status = null;
                    }
                    else if (memory.evaluate_enter_timeout.is_expired())
                    {
                        memory.evaluate_enter_evaluation_list.clear();
                        memory.evaluate_enter_timeout = null;
                        memory.evaluate_enter_elected = null;
                        memory.evaluate_enter_first_ask_lvl = -1;
                        memory.evaluate_enter_status = null;
                    }
                    // set memory
                    set_hooking_memory(lock_id, levels, memory);
                    // ignore network
                    debug(@"ProxyCoord.evaluate_enter.NOTIFIED: throw ignore_network.");
                    throw new IgnoreNetworkError.GENERIC("");
                }
                assert_not_reached();
            }
        }

        internal void begin_enter(int lvl, BeginEnterData begin_enter_data)
        throws AlreadyEnteringError, CoordProxyError, UnknownResultError
        {
            if (lvl == 0)
            {
                mgr.begin_enter(lvl, begin_enter_data, new ArrayList<int>());
                return;
            }
            Object _ret = coord.begin_enter(lvl, begin_enter_data);
            if (! (_ret is BeginEnterResult)) throw new UnknownResultError.GENERIC("");
            BeginEnterResult ret = (BeginEnterResult)_ret;
            if (ret.already_entering_error) throw new AlreadyEnteringError.GENERIC("");
        }

        internal Object execute_proxy_begin_enter(int lvl, Object begin_enter_data, Gee.List<int> client_address)
        {
            if (! (begin_enter_data is BeginEnterData)) tasklet.exit_tasklet(null);
            int lock_id = lock_hooking_memory();
            var ret = new BeginEnterResult();
            try {
                execute_begin_enter(lock_id, lvl, (BeginEnterData)begin_enter_data, client_address);
            } catch (AlreadyEnteringError e) {
                ret.already_entering_error = true;
            }
            unlock_hooking_memory(lock_id);
            return ret;
        }

        internal void execute_begin_enter(int lock_id, int lvl, BeginEnterData begin_enter_data, Gee.List<int> client_address)
        throws AlreadyEnteringError
        {
            debug(@"ProxyCoord: as coordinator of g-node of level $(lvl), executing begin_enter.");
            // get memory
            HookingMemory memory = get_hooking_memory(lock_id, lvl);
            if (memory.begin_enter_timeout == null || memory.begin_enter_timeout.is_expired())
            {
                memory.begin_enter_timeout = new SerTimer(5*60*1000); // TODO verify this time is suited.
                // set memory
                set_hooking_memory(lock_id, lvl, memory);
                debug(@"ProxyCoord.begin_enter: return ok.");
            }
            else
            {
                debug(@"ProxyCoord.begin_enter: throw already_entering.");
                throw new AlreadyEnteringError.GENERIC("");
            }
        }

        internal void completed_enter(int lvl, CompletedEnterData completed_enter_data)
        throws CoordProxyError, UnknownResultError
        {
            if (lvl == 0)
            {
                mgr.completed_enter(lvl, completed_enter_data, new ArrayList<int>());
                return;
            }
            Object _ret = coord.completed_enter(lvl, completed_enter_data);
            if (! (_ret is CompletedEnterResult)) throw new UnknownResultError.GENERIC("");
        }

        internal Object execute_proxy_completed_enter(int lvl, Object completed_enter_data, Gee.List<int> client_address)
        {
            if (! (completed_enter_data is CompletedEnterData)) tasklet.exit_tasklet(null);
            int lock_id = lock_hooking_memory();
            var ret = new CompletedEnterResult();
            execute_completed_enter(lock_id, lvl, (CompletedEnterData)completed_enter_data, client_address);
            unlock_hooking_memory(lock_id);
            return ret;
        }

        internal void execute_completed_enter(int lock_id, int lvl, CompletedEnterData completed_enter_data, Gee.List<int> client_address)
        {
            debug(@"ProxyCoord: as coordinator of g-node of level $(lvl), executing completed_enter.");
            // get memory
            HookingMemory memory = get_hooking_memory(lock_id, lvl);
            memory.begin_enter_timeout = null;
            // set memory
            set_hooking_memory(lock_id, lvl, memory);
        }

        internal void abort_enter(int lvl, AbortEnterData abort_enter_data)
        throws CoordProxyError, UnknownResultError
        {
            if (lvl == 0)
            {
                mgr.abort_enter(lvl, abort_enter_data, new ArrayList<int>());
                return;
            }
            Object _ret = coord.abort_enter(lvl, abort_enter_data);
            if (! (_ret is AbortEnterResult)) throw new UnknownResultError.GENERIC("");
        }

        internal Object execute_proxy_abort_enter(int lvl, Object abort_enter_data, Gee.List<int> client_address)
        {
            if (! (abort_enter_data is AbortEnterData)) tasklet.exit_tasklet(null);
            int lock_id = lock_hooking_memory();
            var ret = new AbortEnterResult();
            execute_abort_enter(lock_id, lvl, (AbortEnterData)abort_enter_data, client_address);
            unlock_hooking_memory(lock_id);
            return ret;
        }

        internal void execute_abort_enter(int lock_id, int lvl, AbortEnterData abort_enter_data, Gee.List<int> client_address)
        {
            debug(@"ProxyCoord: as coordinator of g-node of level $(lvl), executing abort_enter.");
            // get memory
            HookingMemory memory = get_hooking_memory(lock_id, lvl);
            memory.begin_enter_timeout = null;
            // set memory
            set_hooking_memory(lock_id, lvl, memory);
        }

        internal int lock_hooking_memory()
        {
            while (_lock_hooking_memory != null) tasklet.ms_wait(10);
            _lock_hooking_memory = PRNGen.int_range(0, int.MAX);
            return _lock_hooking_memory;
        }

        internal HookingMemory get_hooking_memory(int lock_id, int lvl)
        {
            assert(_lock_hooking_memory == lock_id);
            try {
                Object _ret = coord.get_hooking_memory(lvl);
                if (_ret == null)
                {
                    debug(@"ProxyCoord: get_hooking_memory from coord($(lvl)) returned null. We return a new HookingMemory().");
                    return new HookingMemory();
                }
                if (! (_ret is HookingMemory))
                {
                    critical(@"Hooking.ProxyCoord.get_hooking_memory: bad result class $(_ret.get_type().name())");
                    tasklet.exit_tasklet(null);
                }
                return (HookingMemory)_ret;
            } catch (CoordProxyError e) {
                critical(@"Hooking.ProxyCoord.get_hooking_memory: CoordProxyError $(e.message)");
                tasklet.exit_tasklet(null);
            }
        }

        internal void set_hooking_memory(int lock_id, int lvl, HookingMemory memory)
        {
            assert(_lock_hooking_memory == lock_id);
            try {
                coord.set_hooking_memory(lvl, memory);
            } catch (CoordProxyError e) {
                critical(@"Hooking.ProxyCoord.set_hooking_memory: CoordProxyError $(e.message)");
                tasklet.exit_tasklet(null);
            }
        }

        internal void unlock_hooking_memory(int lock_id)
        {
            assert(_lock_hooking_memory == lock_id);
            _lock_hooking_memory = null;
        }
    }
}
