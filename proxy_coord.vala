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
            try {
                if (! (evaluate_enter_data is EvaluateEnterData)) tasklet.exit_tasklet(null);
                int retval = execute_evaluate_enter((EvaluateEnterData)evaluate_enter_data, client_address);
                var ret = new EvaluateEnterResult();
                ret.first_ask_lvl = retval;
                return ret;
            } catch (AskAgainError e) {
                var ret = new EvaluateEnterResult();
                ret.ask_again_error = true;
                return ret;
            } catch (IgnoreNetworkError e) {
                var ret = new EvaluateEnterResult();
                ret.ignore_network_error = true;
                return ret;
            }
        }

        internal int execute_evaluate_enter(EvaluateEnterData evaluate_enter_data, Gee.List<int> client_address)
        throws AskAgainError, IgnoreNetworkError
        {
            error("not implemented yet");
        }

        internal void begin_enter(int lvl, BeginEnterData begin_enter_data)
        throws AlreadyEnteringError, CoordProxyError, UnknownResultError
        {
            Object _ret = coord.begin_enter(lvl, begin_enter_data);
            if (! (_ret is BeginEnterResult)) throw new UnknownResultError.GENERIC("");
            BeginEnterResult ret = (BeginEnterResult)_ret;
            if (ret.already_entering_error) throw new AlreadyEnteringError.GENERIC("");
        }

        internal Object execute_proxy_begin_enter(int lvl, Object begin_enter_data, Gee.List<int> client_address)
        {
            try {
                if (! (begin_enter_data is BeginEnterData)) tasklet.exit_tasklet(null);
                execute_begin_enter(lvl, (BeginEnterData)begin_enter_data, client_address);
                var ret = new BeginEnterResult();
                return ret;
            } catch (AlreadyEnteringError e) {
                var ret = new BeginEnterResult();
                ret.already_entering_error = true;
                return ret;
            }
        }

        internal void execute_begin_enter(int lvl, BeginEnterData begin_enter_data, Gee.List<int> client_address)
        throws AlreadyEnteringError
        {
            error("not implemented yet");
        }

        internal void completed_enter(int lvl, CompletedEnterData completed_enter_data)
        throws CoordProxyError, UnknownResultError
        {
            Object _ret = coord.completed_enter(lvl, completed_enter_data);
            if (! (_ret is CompletedEnterResult)) throw new UnknownResultError.GENERIC("");
        }

        internal Object execute_proxy_completed_enter(int lvl, Object completed_enter_data, Gee.List<int> client_address)
        {
            if (! (completed_enter_data is CompletedEnterData)) tasklet.exit_tasklet(null);
            execute_completed_enter(lvl, (CompletedEnterData)completed_enter_data, client_address);
            var ret = new CompletedEnterResult();
            return ret;
        }

        internal void execute_completed_enter(int lvl, CompletedEnterData completed_enter_data, Gee.List<int> client_address)
        {
            error("not implemented yet");
        }

        internal void abort_enter(int lvl, AbortEnterData abort_enter_data)
        throws CoordProxyError, UnknownResultError
        {
            Object _ret = coord.abort_enter(lvl, abort_enter_data);
            if (! (_ret is AbortEnterResult)) throw new UnknownResultError.GENERIC("");
        }

        internal Object execute_proxy_abort_enter(int lvl, Object abort_enter_data, Gee.List<int> client_address)
        {
            if (! (abort_enter_data is AbortEnterData)) tasklet.exit_tasklet(null);
            execute_abort_enter(lvl, (AbortEnterData)abort_enter_data, client_address);
            var ret = new AbortEnterResult();
            return ret;
        }

        internal void execute_abort_enter(int lvl, AbortEnterData abort_enter_data, Gee.List<int> client_address)
        {
            error("not implemented yet");
        }
    }
}
