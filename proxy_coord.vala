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

    internal delegate Object ProxyEvaluateEnter(int lvl, Object evaluate_enter_data) throws CoordProxyError;

    internal errordomain UnknownResultError {GENERIC}
    internal int evaluate_enter(ProxyEvaluateEnter proxy_evaluate_enter, int levels, EvaluateEnterData evaluate_enter_data)
    throws AskAgainError, IgnoreNetworkError, CoordProxyError, UnknownResultError
    {
        int lvl = levels;
        Object _ret = proxy_evaluate_enter(lvl, evaluate_enter_data);
        if (! (_ret is EvaluateEnterResult)) throw new UnknownResultError.GENERIC("");
        EvaluateEnterResult ret = (EvaluateEnterResult)_ret;
        if (ret.ask_again_error) throw new AskAgainError.GENERIC("");
        if (ret.ignore_network_error) throw new IgnoreNetworkError.GENERIC("");
        return ret.first_ask_lvl;
    }
}
