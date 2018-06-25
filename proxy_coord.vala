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
    internal errordomain AskAgainError {GENERIC}
    internal errordomain IgnoreNetworkError {GENERIC}

    internal delegate Object ProxyEvaluateEnter(Object evaluate_enter_data) throws CoordProxyError;

    internal errordomain UnknownResultError {GENERIC}
    internal int evaluate_enter(ProxyEvaluateEnter proxy_evaluate_enter, EvaluateEnterData evaluate_enter_data)
    throws AskAgainError, IgnoreNetworkError, CoordProxyError, UnknownResultError
    {
        Object _ret = proxy_evaluate_enter(evaluate_enter_data);
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
}
