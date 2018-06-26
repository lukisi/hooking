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

namespace Netsukuku.Hooking
{
    public class NetworkData : Object, Json.Serializable, INetworkData
    {
        public int64 network_id {get; set;}
        public int neighbor_n_nodes {get; set;}
        public int neighbor_min_level {get; set;}
        public Gee.List<int> gsizes {get; set;}
        public Gee.List<int> neighbor_pos {get; set;}

        public bool deserialize_property
        (string property_name,
         out GLib.Value @value,
         GLib.ParamSpec pspec,
         Json.Node property_node)
        {
            @value = 0;
            switch (property_name) {
            case "gsizes":
            case "neighbor_pos":
            case "neighbor-pos":
                try {
                    @value = deserialize_list_int(property_node);
                } catch (HelperDeserializeError e) {
                    return false;
                }
                break;
            case "network_id":
            case "network-id":
                try {
                    @value = deserialize_int64(property_node);
                } catch (HelperDeserializeError e) {
                    return false;
                }
                break;
            case "neighbor_n_nodes":
            case "neighbor-n-nodes":
            case "neighbor_min_level":
            case "neighbor-min-level":
                try {
                    @value = deserialize_int(property_node);
                } catch (HelperDeserializeError e) {
                    return false;
                }
                break;
            default:
                return false;
            }
            return true;
        }

        public unowned GLib.ParamSpec? find_property
        (string name)
        {
            return get_class().find_property(name);
        }

        public Json.Node serialize_property
        (string property_name,
         GLib.Value @value,
         GLib.ParamSpec pspec)
        {
            switch (property_name) {
            case "gsizes":
            case "neighbor_pos":
            case "neighbor-pos":
                return serialize_list_int((Gee.List<int>)@value);
            case "network_id":
            case "network-id":
                return serialize_int64((int64)@value);
            case "neighbor_n_nodes":
            case "neighbor-n-nodes":
            case "neighbor_min_level":
            case "neighbor-min-level":
                return serialize_int((int)@value);
            default:
                error(@"wrong param $(property_name)");
            }
        }
    }

    internal class EvaluateEnterData : Object, Json.Serializable
    {
        public int64 network_id {get; set;}
        public Gee.List<int> neighbor_pos {get; set;}
        public int neighbor_min_lvl {get; set;}
        public int min_lvl {get; set;}
        public int evaluate_enter_id {get; set;}

        public EvaluateEnterData()
        {
            neighbor_pos = new ArrayList<int>();
        }

        public bool deserialize_property
        (string property_name,
         out GLib.Value @value,
         GLib.ParamSpec pspec,
         Json.Node property_node)
        {
            @value = 0;
            switch (property_name) {
            case "neighbor_pos":
            case "neighbor-pos":
                try {
                    @value = deserialize_list_int(property_node);
                } catch (HelperDeserializeError e) {
                    return false;
                }
                break;
            case "network_id":
            case "network-id":
                try {
                    @value = deserialize_int64(property_node);
                } catch (HelperDeserializeError e) {
                    return false;
                }
                break;
            case "neighbor_min_lvl":
            case "neighbor-min-lvl":
            case "min_lvl":
            case "min-lvl":
            case "evaluate_enter_id":
            case "evaluate-enter-id":
                try {
                    @value = deserialize_int(property_node);
                } catch (HelperDeserializeError e) {
                    return false;
                }
                break;
            default:
                return false;
            }
            return true;
        }

        public unowned GLib.ParamSpec? find_property
        (string name)
        {
            return get_class().find_property(name);
        }

        public Json.Node serialize_property
        (string property_name,
         GLib.Value @value,
         GLib.ParamSpec pspec)
        {
            switch (property_name) {
            case "neighbor_pos":
            case "neighbor-pos":
                return serialize_list_int((Gee.List<int>)@value);
            case "network_id":
            case "network-id":
                return serialize_int64((int64)@value);
            case "neighbor_min_lvl":
            case "neighbor-min-lvl":
            case "min_lvl":
            case "min-lvl":
            case "evaluate_enter_id":
            case "evaluate-enter-id":
                return serialize_int((int)@value);
            default:
                error(@"wrong param $(property_name)");
            }
        }
    }

    internal class EvaluateEnterResult : Object
    {
        public int first_ask_lvl {get; set;}
        public bool ask_again_error {get; set;}
        public bool ignore_network_error {get; set;}
    }

    internal class EvaluateEnterEvaluation : Object, Json.Serializable
    {
        public Gee.List<int> client_address {get; set;}
        public EvaluateEnterData evaluate_enter_data {get; set;}

        public EvaluateEnterEvaluation()
        {
            client_address = new ArrayList<int>();
            evaluate_enter_data = new EvaluateEnterData();
        }

        public bool deserialize_property
        (string property_name,
         out GLib.Value @value,
         GLib.ParamSpec pspec,
         Json.Node property_node)
        {
            @value = 0;
            switch (property_name) {
            case "client_address":
            case "client-address":
                try {
                    @value = deserialize_list_int(property_node);
                } catch (HelperDeserializeError e) {
                    return false;
                }
                break;
            case "evaluate_enter_data":
            case "evaluate-enter-data":
                try {
                    @value = deserialize_evaluateenterdata(property_node);
                } catch (HelperDeserializeError e) {
                    return false;
                }
                break;
            default:
                return false;
            }
            return true;
        }

        public unowned GLib.ParamSpec? find_property
        (string name)
        {
            return get_class().find_property(name);
        }

        public Json.Node serialize_property
        (string property_name,
         GLib.Value @value,
         GLib.ParamSpec pspec)
        {
            switch (property_name) {
            case "client_address":
            case "client-address":
                return serialize_list_int((Gee.List<int>)@value);
            case "evaluate_enter_data":
            case "evaluate-enter-data":
                return serialize_evaluateenterdata((EvaluateEnterData)@value);
            default:
                error(@"wrong param $(property_name)");
            }
        }
    }

    internal class SerTimer : Object
    {
        public SerTimer(int msec_ttl)
        {
            this.msec_ttl = msec_ttl;
        }

        public int msec_ttl {
            get {
                TimeVal lap = TimeVal();
                lap.get_current_time();
                long sec = lap.tv_sec - start.tv_sec;
                long usec = lap.tv_usec - start.tv_usec;
                if (usec < 0)
                {
                    usec += 1000000;
                    sec--;
                }
                long usec_lap = sec*1000000 + usec;
                long usec_ttl_now = _msec_ttl*1000 - usec_lap;
                return (int)(usec_ttl_now / 1000);
            }
            set {
                start = TimeVal();
                start.get_current_time();
                this._msec_ttl = value;
            }
        }

        private TimeVal start;
        private int _msec_ttl;

        public bool is_expired()
        {
            return msec_ttl < 0;
        }
    }

    internal class HookingMemory : Object, Json.Serializable
    {
        public Gee.List<EvaluateEnterEvaluation> evaluate_enter_evaluation_list {get; set;}
        public SerTimer? evaluate_enter_timeout {get; set;}
        public EvaluateEnterEvaluation? evaluate_enter_elected {get; set;}
        public SerTimer? begin_enter_timeout {get; set;}

        public int? evaluate_enter_first_ask_lvl {
            get {
                if (internser_evaluate_enter_first_ask_lvl == -1) return null;
                else return internser_evaluate_enter_first_ask_lvl;
            }
            set {
                if (value == null) internser_evaluate_enter_first_ask_lvl = -1;
                else internser_evaluate_enter_first_ask_lvl = value;
            }
        }

        public EvaluationStatus? evaluate_enter_status {
            get {
                if (internser_evaluate_enter_status == -1) return null;
                else if (internser_evaluate_enter_status == 0) return EvaluationStatus.PENDING;
                else if (internser_evaluate_enter_status == 1) return EvaluationStatus.TO_BE_NOTIFIED;
                else if (internser_evaluate_enter_status == 2) return EvaluationStatus.NOTIFIED;
                else return null;
            }
            set {
                if (value == null) internser_evaluate_enter_status = -1;
                else if (value == EvaluationStatus.PENDING) internser_evaluate_enter_status = 0;
                else if (value == EvaluationStatus.TO_BE_NOTIFIED) internser_evaluate_enter_status = 1;
                else if (value == EvaluationStatus.NOTIFIED) internser_evaluate_enter_status = 2;
                else internser_evaluate_enter_status = -1;
            }
        }

        public int internser_evaluate_enter_first_ask_lvl {get; set;}
        public int internser_evaluate_enter_status {get; set;}

        public HookingMemory()
        {
            evaluate_enter_evaluation_list = new ArrayList<EvaluateEnterEvaluation>();
            evaluate_enter_first_ask_lvl = null;
            evaluate_enter_timeout = null;
            evaluate_enter_status = null;
            evaluate_enter_elected = null;
            begin_enter_timeout = null;
        }

        public bool deserialize_property
        (string property_name,
         out GLib.Value @value,
         GLib.ParamSpec pspec,
         Json.Node property_node)
        {
            @value = 0;
            switch (property_name) {
            case "evaluate_enter_evaluation_list":
            case "evaluate-enter-evaluation-list":
                try {
                    @value = deserialize_list_evaluateenterevaluation(property_node);
                } catch (HelperDeserializeError e) {
                    return false;
                }
                break;
            case "internser_evaluate_enter_first_ask_lvl":
            case "internser-evaluate-enter-first-ask-lvl":
            case "internser_evaluate_enter_status":
            case "internser-evaluate-enter-status":
                try {
                    @value = deserialize_int(property_node);
                } catch (HelperDeserializeError e) {
                    return false;
                }
                break;
            case "evaluate_enter_status":
            case "evaluate-enter-status":
                // dynamic property
                return false;
            case "evaluate_enter_timeout":
            case "evaluate-enter-timeout":
            case "begin_enter_timeout":
            case "begin-enter-timeout":
                try {
                    @value = deserialize_nullable_sertimer(property_node);
                } catch (HelperDeserializeError e) {
                    return false;
                }
                break;
            case "evaluate_enter_elected":
            case "evaluate-enter-elected":
                try {
                    @value = deserialize_nullable_evaluateenterevaluation(property_node);
                } catch (HelperDeserializeError e) {
                    return false;
                }
                break;
            default:
                return false;
            }
            return true;
        }

        public unowned GLib.ParamSpec? find_property
        (string name)
        {
            return get_class().find_property(name);
        }

        public Json.Node serialize_property
        (string property_name,
         GLib.Value @value,
         GLib.ParamSpec pspec)
        {
            switch (property_name) {
            case "evaluate_enter_evaluation_list":
            case "evaluate-enter-evaluation-list":
                return serialize_list_evaluateenterevaluation((Gee.List<EvaluateEnterEvaluation>)@value);
            case "internser_evaluate_enter_first_ask_lvl":
            case "internser-evaluate-enter-first-ask-lvl":
            case "internser_evaluate_enter_status":
            case "internser-evaluate-enter-status":
                return serialize_int((int)@value);
            case "evaluate_enter_status":
            case "evaluate-enter-status":
                return serialize_int(0); // dynamic property
            case "evaluate_enter_timeout":
            case "evaluate-enter-timeout":
            case "begin_enter_timeout":
            case "begin-enter-timeout":
                return serialize_nullable_sertimer((SerTimer?)@value);
            case "evaluate_enter_elected":
            case "evaluate-enter-elected":
                return serialize_nullable_evaluateenterevaluation((EvaluateEnterEvaluation?)@value);
            default:
                error(@"wrong param $(property_name)");
            }
        }
    }

    internal class BeginEnterData : Object
    {
    }

    internal class BeginEnterResult : Object
    {
        public bool already_entering_error {get; set;}
    }

    /* TODO
    serializable class CompletedEnterData:
    */

    /* TODO
    serializable class CompletedEnterResult:
    */

    /* TODO
    serializable class AbortEnterData:
    */

    /* TODO
    serializable class AbortEnterResult:
    */

    public class EntryData : Object, Json.Serializable, IEntryData
    {
        public int64 network_id {get; set;}
        public Gee.List<int> pos {get; set;}
        public Gee.List<int> elderships {get; set;}

        public bool deserialize_property
        (string property_name,
         out GLib.Value @value,
         GLib.ParamSpec pspec,
         Json.Node property_node)
        {
            @value = 0;
            switch (property_name) {
            case "pos":
            case "elderships":
                try {
                    @value = deserialize_list_int(property_node);
                } catch (HelperDeserializeError e) {
                    return false;
                }
                break;
            case "network_id":
            case "network-id":
                try {
                    @value = deserialize_int64(property_node);
                } catch (HelperDeserializeError e) {
                    return false;
                }
                break;
            default:
                return false;
            }
            return true;
        }

        public unowned GLib.ParamSpec? find_property
        (string name)
        {
            return get_class().find_property(name);
        }

        public Json.Node serialize_property
        (string property_name,
         GLib.Value @value,
         GLib.ParamSpec pspec)
        {
            switch (property_name) {
            case "pos":
            case "elderships":
                return serialize_list_int((Gee.List<int>)@value);
            case "network_id":
            case "network-id":
                return serialize_int64((int64)@value);
            default:
                error(@"wrong param $(property_name)");
            }
        }
    }

    /* TODO
    serializable class PrepareEnterData:
        int enter_id
    */

    /* TODO
    serializable class FinishEnterData:
        int enter_id
        EntryData entry_data
        int go_connectivity_position
    */

    /* TODO
    serializable class PrepareMigrationData:
        int migration_id
    */

    /* TODO
    serializable class FinishMigrationData:
        int migration_id
        ... TODO
    */

    internal class TupleGNode : Object, Json.Serializable
    {
        public Gee.List<int> pos {get; set;}
        public Gee.List<int> eldership {get; set;}
        public TupleGNode(Gee.List<int> pos, Gee.List<int> eldership)
        {
            this.pos = new ArrayList<int>();
            this.pos.add_all(pos);
            this.eldership = new ArrayList<int>();
            this.eldership.add_all(eldership);
        }

        public bool deserialize_property
        (string property_name,
         out GLib.Value @value,
         GLib.ParamSpec pspec,
         Json.Node property_node)
        {
            @value = 0;
            switch (property_name) {
            case "pos":
            case "eldership":
                try {
                    @value = deserialize_list_int(property_node);
                } catch (HelperDeserializeError e) {
                    return false;
                }
                break;
            default:
                return false;
            }
            return true;
        }

        public unowned GLib.ParamSpec? find_property
        (string name)
        {
            return get_class().find_property(name);
        }

        public Json.Node serialize_property
        (string property_name,
         GLib.Value @value,
         GLib.ParamSpec pspec)
        {
            switch (property_name) {
            case "pos":
            case "eldership":
                return serialize_list_int((Gee.List<int>)@value);
            default:
                error(@"wrong param $(property_name)");
            }
        }
    }

    internal class PathHop : Object, Json.Serializable
    {
        public TupleGNode visiting_gnode {get; set;}
        public TupleGNode? previous_migrating_gnode {get; set;}

        public bool deserialize_property
        (string property_name,
         out GLib.Value @value,
         GLib.ParamSpec pspec,
         Json.Node property_node)
        {
            @value = 0;
            switch (property_name) {
            case "visiting_gnode":
            case "visiting-gnode":
                try {
                    @value = deserialize_tuplegnode(property_node);
                } catch (HelperDeserializeError e) {
                    return false;
                }
                break;
            case "previous_migrating_gnode":
            case "previous-migrating-gnode":
                try {
                    @value = deserialize_nullable_tuplegnode(property_node);
                } catch (HelperDeserializeError e) {
                    return false;
                }
                break;
            default:
                return false;
            }
            return true;
        }

        public unowned GLib.ParamSpec? find_property
        (string name)
        {
            return get_class().find_property(name);
        }

        public Json.Node serialize_property
        (string property_name,
         GLib.Value @value,
         GLib.ParamSpec pspec)
        {
            switch (property_name) {
            case "visiting_gnode":
            case "visiting-gnode":
                return serialize_tuplegnode((TupleGNode)@value);
            case "previous_migrating_gnode":
            case "previous-migrating-gnode":
                return serialize_nullable_tuplegnode((TupleGNode?)@value);
            default:
                error(@"wrong param $(property_name)");
            }
        }
    }

    internal class SearchMigrationPathRequest : Object, Json.Serializable, ISearchMigrationPathRequest
    {
        public int pkt_id {get; set;}
        public TupleGNode origin {get; set;}
        public TupleGNode caller {get; set;}
        public Gee.List<PathHop> path_hops {get; set;}
        public int max_host_lvl {get; set;}
        public int reserve_request_id {get; set;}

        public SearchMigrationPathRequest(Gee.List<PathHop> path_hops, int max_host_lvl, int reserve_request_id)
        {
            this.path_hops = new ArrayList<PathHop>();
            this.path_hops.add_all(path_hops);
            this.max_host_lvl = max_host_lvl;
            this.reserve_request_id = reserve_request_id;
        }

        public bool deserialize_property
        (string property_name,
         out GLib.Value @value,
         GLib.ParamSpec pspec,
         Json.Node property_node)
        {
            @value = 0;
            switch (property_name) {
            case "origin":
            case "caller":
                try {
                    @value = deserialize_tuplegnode(property_node);
                } catch (HelperDeserializeError e) {
                    return false;
                }
                break;
            case "pkt_id":
            case "pkt-id":
            case "max_host_lvl":
            case "max-host-lvl":
            case "reserve_request_id":
            case "reserve-request-id":
                try {
                    @value = deserialize_int(property_node);
                } catch (HelperDeserializeError e) {
                    return false;
                }
                break;
            case "path_hops":
            case "path-hops":
                try {
                    @value = deserialize_list_pathhop(property_node);
                } catch (HelperDeserializeError e) {
                    return false;
                }
                break;
            default:
                return false;
            }
            return true;
        }

        public unowned GLib.ParamSpec? find_property
        (string name)
        {
            return get_class().find_property(name);
        }

        public Json.Node serialize_property
        (string property_name,
         GLib.Value @value,
         GLib.ParamSpec pspec)
        {
            switch (property_name) {
            case "origin":
            case "caller":
                return serialize_tuplegnode((TupleGNode)@value);
            case "pkt_id":
            case "pkt-id":
            case "max_host_lvl":
            case "max-host-lvl":
            case "reserve_request_id":
            case "reserve-request-id":
                return serialize_int((int)@value);
            case "path_hops":
            case "path-hops":
                return serialize_list_pathhop((Gee.List<PathHop>)@value);
            default:
                error(@"wrong param $(property_name)");
            }
        }
    }

    internal class SearchMigrationPathErrorPkt : Object, ISearchMigrationPathErrorPkt
    {
        public int pkt_id {get; set;}
        public TupleGNode origin {get; set;}
    }

    internal class PairTupleGNodeInt : Object
    {
        public PairTupleGNodeInt(TupleGNode t, int i)
        {
            this.t = t;
            this.i = i;
        }

        public TupleGNode t {get; set;}
        public int i {get; set;}
    }

    internal class SearchMigrationPathResponse : Object, Json.Serializable, ISearchMigrationPathResponse
    {
        public int pkt_id {get; set;}
        public TupleGNode origin {get; set;}
        public int min_host_lvl {get; set;}
        public Gee.List<PairTupleGNodeInt> set_adjacent {get; set;}

        public int? final_host_lvl {
            get {
                if (internser_final_host_lvl == -1) return null;
                else return internser_final_host_lvl;
            }
            set {
                if (value == null) internser_final_host_lvl = -1;
                else internser_final_host_lvl = value;
            }
        }

        public int? real_new_pos {
            get {
                if (internser_real_new_pos == -1) return null;
                else return internser_real_new_pos;
            }
            set {
                if (value == null) internser_real_new_pos = -1;
                else internser_real_new_pos = value;
            }
        }

        public int? real_new_eldership {
            get {
                if (internser_real_new_eldership == -1) return null;
                else return internser_real_new_eldership;
            }
            set {
                if (value == null) internser_real_new_eldership = -1;
                else internser_real_new_eldership = value;
            }
        }

        public int? new_conn_vir_pos {
            get {
                if (internser_new_conn_vir_pos == -1) return null;
                else return internser_new_conn_vir_pos;
            }
            set {
                if (value == null) internser_new_conn_vir_pos = -1;
                else internser_new_conn_vir_pos = value;
            }
        }

        public int? new_eldership {
            get {
                if (internser_new_eldership == -1) return null;
                else return internser_new_eldership;
            }
            set {
                if (value == null) internser_new_eldership = -1;
                else internser_new_eldership = value;
            }
        }

        public int internser_final_host_lvl {get; set;}
        public int internser_real_new_pos {get; set;}
        public int internser_real_new_eldership {get; set;}
        public int internser_new_conn_vir_pos {get; set;}
        public int internser_new_eldership {get; set;}

        public SearchMigrationPathResponse()
        {
            set_adjacent = new ArrayList<PairTupleGNodeInt>();
            final_host_lvl = null;
            real_new_pos = null;
            real_new_eldership = null;
            new_conn_vir_pos = null;
            new_eldership = null;
        }

        public bool deserialize_property
        (string property_name,
         out GLib.Value @value,
         GLib.ParamSpec pspec,
         Json.Node property_node)
        {
            @value = 0;
            switch (property_name) {
            case "origin":
                try {
                    @value = deserialize_tuplegnode(property_node);
                } catch (HelperDeserializeError e) {
                    return false;
                }
                break;
            case "pkt_id":
            case "pkt-id":
            case "min_host_lvl":
            case "min-host-lvl":
            case "internser_final_host_lvl":
            case "internser-final-host-lvl":
            case "internser_real_new_pos":
            case "internser-real-new-pos":
            case "internser_real_new_eldership":
            case "internser-real-new-eldership":
            case "internser_new_conn_vir_pos":
            case "internser-new-conn-vir-pos":
            case "internser_new_eldership":
            case "internser-new-eldership":
                try {
                    @value = deserialize_int(property_node);
                } catch (HelperDeserializeError e) {
                    return false;
                }
                break;
            case "set_adjacent":
            case "set-adjacent":
                try {
                    @value = deserialize_list_pairtupleint(property_node);
                } catch (HelperDeserializeError e) {
                    return false;
                }
                break;
            default:
                return false;
            }
            return true;
        }

        public unowned GLib.ParamSpec? find_property
        (string name)
        {
            return get_class().find_property(name);
        }

        public Json.Node serialize_property
        (string property_name,
         GLib.Value @value,
         GLib.ParamSpec pspec)
        {
            switch (property_name) {
            case "origin":
                return serialize_tuplegnode((TupleGNode)@value);
            case "pkt_id":
            case "pkt-id":
            case "min_host_lvl":
            case "min-host-lvl":
            case "internser_final_host_lvl":
            case "internser-final-host-lvl":
            case "internser_real_new_pos":
            case "internser-real-new-pos":
            case "internser_real_new_eldership":
            case "internser-real-new-eldership":
            case "internser_new_conn_vir_pos":
            case "internser-new-conn-vir-pos":
            case "internser_new_eldership":
            case "internser-new-eldership":
                return serialize_int((int)@value);
            case "set_adjacent":
            case "set-adjacent":
                return serialize_list_pairtupleint((Gee.List<PairTupleGNodeInt>)@value);
            default:
                error(@"wrong param $(property_name)");
            }
        }
    }

    internal class ExploreGNodeRequest : Object, Json.Serializable, IExploreGNodeRequest
    {
        public int pkt_id {get; set;}
        public TupleGNode origin {get; set;}
        public Gee.List<PathHop> path_hops {get; set;}
        public int requested_lvl {get; set;}

        public ExploreGNodeRequest(Gee.List<PathHop> path_hops, int requested_lvl)
        {
            this.path_hops = new ArrayList<PathHop>();
            this.path_hops.add_all(path_hops);
            this.requested_lvl = requested_lvl;
        }

        public bool deserialize_property
        (string property_name,
         out GLib.Value @value,
         GLib.ParamSpec pspec,
         Json.Node property_node)
        {
            @value = 0;
            switch (property_name) {
            case "origin":
                try {
                    @value = deserialize_tuplegnode(property_node);
                } catch (HelperDeserializeError e) {
                    return false;
                }
                break;
            case "pkt_id":
            case "pkt-id":
            case "requested_lvl":
            case "requested-lvl":
                try {
                    @value = deserialize_int(property_node);
                } catch (HelperDeserializeError e) {
                    return false;
                }
                break;
            case "path_hops":
            case "path-hops":
                try {
                    @value = deserialize_list_pathhop(property_node);
                } catch (HelperDeserializeError e) {
                    return false;
                }
                break;
            default:
                return false;
            }
            return true;
        }

        public unowned GLib.ParamSpec? find_property
        (string name)
        {
            return get_class().find_property(name);
        }

        public Json.Node serialize_property
        (string property_name,
         GLib.Value @value,
         GLib.ParamSpec pspec)
        {
            switch (property_name) {
            case "origin":
                return serialize_tuplegnode((TupleGNode)@value);
            case "pkt_id":
            case "pkt-id":
            case "requested_lvl":
            case "requested-lvl":
                return serialize_int((int)@value);
            case "path_hops":
            case "path-hops":
                return serialize_list_pathhop((Gee.List<PathHop>)@value);
            default:
                error(@"wrong param $(property_name)");
            }
        }
    }

    internal class ExploreGNodeResponse : Object, IExploreGNodeResponse
    {
        public int pkt_id {get; set;}
        public TupleGNode origin {get; set;}
        public TupleGNode result {get; set;}
    }

    internal class DeleteReservationRequest : Object, IDeleteReservationRequest
    {
        public TupleGNode dest_gnode {get; set;}
        public int reserve_request_id {get; set;}
    }

    internal class RequestPacket : Object, IRequestPacket
    {
        public int pkt_id {get; set;}
        public TupleGNode dest {get; set;}
        public TupleGNode src {get; set;}
        public RequestPacketType operation {get; set;}
        public int migration_id {get; set;}
        public int conn_gnode_pos {get; set;}
        public TupleGNode host_gnode {get; set;}
        public int real_new_pos {get; set;}
        public int real_new_eldership {get; set;}
    }

    internal class ResponsePacket : Object, IResponsePacket
    {
        public int pkt_id {get; set;}
        public TupleGNode dest {get; set;}
    }

    internal errordomain HelperDeserializeError {
        GENERIC
    }

    internal Object? deserialize_object(Type expected_type, bool nullable, Json.Node property_node)
    throws HelperDeserializeError
    {
        Json.Reader r = new Json.Reader(property_node.copy());
        if (r.get_null_value())
        {
            if (!nullable)
                throw new HelperDeserializeError.GENERIC("element is not nullable");
            return null;
        }
        if (!r.is_object())
            throw new HelperDeserializeError.GENERIC("element must be an object");
        string typename;
        if (!r.read_member("typename"))
            throw new HelperDeserializeError.GENERIC("element must have typename");
        if (!r.is_value())
            throw new HelperDeserializeError.GENERIC("typename must be a string");
        if (r.get_value().get_value_type() != typeof(string))
            throw new HelperDeserializeError.GENERIC("typename must be a string");
        typename = r.get_string_value();
        r.end_member();
        Type type = Type.from_name(typename);
        if (type == 0)
            throw new HelperDeserializeError.GENERIC(@"typename '$(typename)' unknown class");
        if (!type.is_a(expected_type))
            throw new HelperDeserializeError.GENERIC(@"typename '$(typename)' is not a '$(expected_type.name())'");
        if (!r.read_member("value"))
            throw new HelperDeserializeError.GENERIC("element must have value");
        r.end_member();
        unowned Json.Node p_value = property_node.get_object().get_member("value");
        Json.Node cp_value = p_value.copy();
        return Json.gobject_deserialize(type, cp_value);
    }

    internal Json.Node serialize_object(Object? obj)
    {
        if (obj == null) return new Json.Node(Json.NodeType.NULL);
        Json.Builder b = new Json.Builder();
        b.begin_object();
        b.set_member_name("typename");
        b.add_string_value(obj.get_type().name());
        b.set_member_name("value");
        Json.Node * obj_n = Json.gobject_serialize(obj);
        // json_builder_add_value docs says: The builder will take ownership of the #JsonNode.
        // but the vapi does not specify that the formal parameter is owned.
        // So I try and handle myself the unref of obj_n
        b.add_value(obj_n);
        b.end_object();
        return b.get_root();
    }

    internal class ListDeserializer<T> : Object
    {
        internal Gee.List<T> deserialize_list_object(Json.Node property_node)
        throws HelperDeserializeError
        {
            ArrayList<T> ret = new ArrayList<T>();
            Json.Reader r = new Json.Reader(property_node.copy());
            if (r.get_null_value())
                throw new HelperDeserializeError.GENERIC("element is not nullable");
            if (!r.is_array())
                throw new HelperDeserializeError.GENERIC("element must be an array");
            int l = r.count_elements();
            for (uint j = 0; j < l; j++)
            {
                unowned Json.Node p_value = property_node.get_array().get_element(j);
                Json.Node cp_value = p_value.copy();
                ret.add(deserialize_object(typeof(T), false, cp_value));
            }
            return ret;
        }
    }

    internal Json.Node serialize_list_object(Gee.List<Object> lst)
    {
        Json.Builder b = new Json.Builder();
        b.begin_array();
        foreach (Object obj in lst)
        {
            b.begin_object();
            b.set_member_name("typename");
            b.add_string_value(obj.get_type().name());
            b.set_member_name("value");
            Json.Node * obj_n = Json.gobject_serialize(obj);
            // json_builder_add_value docs says: The builder will take ownership of the #JsonNode.
            // but the vapi does not specify that the formal parameter is owned.
            // So I try and handle myself the unref of obj_n
            b.add_value(obj_n);
            b.end_object();
        }
        b.end_array();
        return b.get_root();
    }

    internal int deserialize_int(Json.Node property_node)
    throws HelperDeserializeError
    {
        Json.Reader r = new Json.Reader(property_node.copy());
        if (r.get_null_value())
            throw new HelperDeserializeError.GENERIC("element is not nullable");
        if (!r.is_value())
            throw new HelperDeserializeError.GENERIC("element must be a int");
        if (r.get_value().get_value_type() != typeof(int64))
            throw new HelperDeserializeError.GENERIC("element must be a int");
        int64 val = r.get_int_value();
        if (val > int.MAX || val < int.MIN)
            throw new HelperDeserializeError.GENERIC("element overflows size of int");
        return (int)val;
    }

    internal Json.Node serialize_int(int i)
    {
        Json.Node ret = new Json.Node(Json.NodeType.VALUE);
        ret.set_int(i);
        return ret;
    }

    internal int64 deserialize_int64(Json.Node property_node)
    throws HelperDeserializeError
    {
        Json.Reader r = new Json.Reader(property_node.copy());
        if (r.get_null_value())
            throw new HelperDeserializeError.GENERIC("element is not nullable");
        if (!r.is_value())
            throw new HelperDeserializeError.GENERIC("element must be a int");
        if (r.get_value().get_value_type() != typeof(int64))
            throw new HelperDeserializeError.GENERIC("element must be a int");
        return r.get_int_value();
    }

    internal Json.Node serialize_int64(int64 i)
    {
        Json.Node ret = new Json.Node(Json.NodeType.VALUE);
        ret.set_int(i);
        return ret;
    }

    internal Gee.List<int> deserialize_list_int(Json.Node property_node)
    throws HelperDeserializeError
    {
        ArrayList<int> ret = new ArrayList<int>();
        Json.Reader r = new Json.Reader(property_node.copy());
        if (r.get_null_value())
            throw new HelperDeserializeError.GENERIC("element is not nullable");
        if (!r.is_array())
            throw new HelperDeserializeError.GENERIC("element must be an array");
        int l = r.count_elements();
        for (int j = 0; j < l; j++)
        {
            r.read_element(j);
            if (r.get_null_value())
                throw new HelperDeserializeError.GENERIC("element is not nullable");
            if (!r.is_value())
                throw new HelperDeserializeError.GENERIC("element must be a int");
            if (r.get_value().get_value_type() != typeof(int64))
                throw new HelperDeserializeError.GENERIC("element must be a int");
            int64 val = r.get_int_value();
            if (val > int.MAX || val < int.MIN)
                throw new HelperDeserializeError.GENERIC("element overflows size of int");
            ret.add((int)val);
            r.end_element();
        }
        return ret;
    }

    internal Json.Node serialize_list_int(Gee.List<int> lst)
    {
        Json.Builder b = new Json.Builder();
        b.begin_array();
        foreach (int i in lst)
        {
            b.add_int_value(i);
        }
        b.end_array();
        return b.get_root();
    }

    internal TupleGNode? deserialize_nullable_tuplegnode(Json.Node property_node)
    throws HelperDeserializeError
    {
        return (TupleGNode?)deserialize_object(typeof(TupleGNode), true, property_node);
    }

    internal Json.Node serialize_nullable_tuplegnode(TupleGNode? n)
    {
        return serialize_object(n);
    }

    internal EvaluateEnterEvaluation? deserialize_nullable_evaluateenterevaluation(Json.Node property_node)
    throws HelperDeserializeError
    {
        return (EvaluateEnterEvaluation?)deserialize_object(typeof(EvaluateEnterEvaluation), true, property_node);
    }

    internal Json.Node serialize_nullable_evaluateenterevaluation(EvaluateEnterEvaluation? n)
    {
        return serialize_object(n);
    }

    internal EvaluateEnterData deserialize_evaluateenterdata(Json.Node property_node)
    throws HelperDeserializeError
    {
        return (EvaluateEnterData)deserialize_object(typeof(EvaluateEnterData), false, property_node);
    }

    internal Json.Node serialize_evaluateenterdata(EvaluateEnterData n)
    {
        return serialize_object(n);
    }

    internal SerTimer deserialize_sertimer(Json.Node property_node)
    throws HelperDeserializeError
    {
        return (SerTimer)deserialize_object(typeof(SerTimer), false, property_node);
    }

    internal Json.Node serialize_sertimer(SerTimer n)
    {
        return serialize_object(n);
    }

    internal SerTimer? deserialize_nullable_sertimer(Json.Node property_node)
    throws HelperDeserializeError
    {
        return (SerTimer?)deserialize_object(typeof(SerTimer), true, property_node);
    }

    internal Json.Node serialize_nullable_sertimer(SerTimer? n)
    {
        return serialize_object(n);
    }

    internal TupleGNode deserialize_tuplegnode(Json.Node property_node)
    throws HelperDeserializeError
    {
        return (TupleGNode)deserialize_object(typeof(TupleGNode), false, property_node);
    }

    internal Json.Node serialize_tuplegnode(TupleGNode n)
    {
        return serialize_object(n);
    }

    internal Gee.List<PathHop> deserialize_list_pathhop(Json.Node property_node)
    throws HelperDeserializeError
    {
        ListDeserializer<PathHop> c = new ListDeserializer<PathHop>();
        return c.deserialize_list_object(property_node);
    }

    internal Json.Node serialize_list_pathhop(Gee.List<PathHop> lst)
    {
        return serialize_list_object(lst);
    }

    internal Gee.List<PairTupleGNodeInt> deserialize_list_pairtupleint(Json.Node property_node)
    throws HelperDeserializeError
    {
        ListDeserializer<PairTupleGNodeInt> c = new ListDeserializer<PairTupleGNodeInt>();
        return c.deserialize_list_object(property_node);
    }

    internal Json.Node serialize_list_pairtupleint(Gee.List<PairTupleGNodeInt> lst)
    {
        return serialize_list_object(lst);
    }

    internal Gee.List<EvaluateEnterEvaluation> deserialize_list_evaluateenterevaluation(Json.Node property_node)
    throws HelperDeserializeError
    {
        ListDeserializer<EvaluateEnterEvaluation> c = new ListDeserializer<EvaluateEnterEvaluation>();
        return c.deserialize_list_object(property_node);
    }

    internal Json.Node serialize_list_evaluateenterevaluation(Gee.List<EvaluateEnterEvaluation> lst)
    {
        return serialize_list_object(lst);
    }
}
