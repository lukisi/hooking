using Gee;
using TaskletSystem;
using Netsukuku;

namespace SystemPeer
{
    /* API */

    public errordomain CommDeserializeError {
        GENERIC
    }

    public errordomain HelperNotJsonError {
        GENERIC
    }

    //...

    /* Internals */

    //...

    internal interface IJsonBuilderElement : Object {
        public abstract void execute(Json.Builder b);
    }

    internal interface IJsonReaderElement : Object {
        public abstract void execute(Json.Reader r) throws CommDeserializeError;
    }

    internal delegate unowned Json.Node JsonExecPath(Json.Node root);

    internal delegate void JsonReadElement(Json.Reader r, int index) throws CommDeserializeError;

    internal class JsonBuilderObject : Object, IJsonBuilderElement
    {
        private Object obj;
        public JsonBuilderObject(Object obj) {
            this.obj = obj;
        }
        public void execute(Json.Builder b) {
            b.begin_object();
            b.set_member_name("typename");
            b.add_string_value(obj.get_type().name());
            b.set_member_name("value");
            Json.Node* obj_n = Json.gobject_serialize(obj);
            // json_builder_add_value docs says: The builder will take ownership of the #JsonNode.
            // but the vapi does not specify that the formal parameter is owned.
            // So I try and handle myself the unref of obj_n
            b.add_value(obj_n);
            b.end_object();
        }
    }

    internal class JsonReaderObject : Object, IJsonReaderElement
    {
        public bool ret_ok;
        public Type expected_type;
        public bool nullable;
        private bool is_null;
        private Type type;
        public JsonReaderObject(Type expected_type, bool nullable) {
            ret_ok = false;
            this.expected_type = expected_type;
            this.nullable = nullable;
        }
        public void execute(Json.Reader r) throws CommDeserializeError {
            if (r.get_null_value())
            {
                if (!nullable)
                    throw new CommDeserializeError.GENERIC("element is not nullable");
                is_null = true;
                ret_ok = true;
                return;
            }
            if (!r.is_object())
                throw new CommDeserializeError.GENERIC("element must be an object");
            string typename;
            if (!r.read_member("typename"))
                throw new CommDeserializeError.GENERIC("element must have typename");
            if (!r.is_value())
                throw new CommDeserializeError.GENERIC("typename must be a string");
            if (r.get_value().get_value_type() != typeof(string))
                throw new CommDeserializeError.GENERIC("typename must be a string");
            typename = r.get_string_value();
            r.end_member();
            type = Type.from_name(typename);
            if (type == 0)
                throw new CommDeserializeError.GENERIC(@"typename '$(typename)' unknown class");
            if (!type.is_a(expected_type))
                throw new CommDeserializeError.GENERIC(@"typename '$(typename)' is not a '$(expected_type.name())'");
            if (!r.read_member("value"))
                throw new CommDeserializeError.GENERIC("element must have value");
            r.end_member();
            is_null = false;
            ret_ok = true;
        }
        public Object? deserialize_or_null(string js, JsonExecPath exec_path) throws CommDeserializeError
        {
            assert(ret_ok);
            if (is_null) return null;
            // find node, copy tree, deserialize
            Json.Parser p = new Json.Parser();
            try {
                p.load_from_data(js);
            } catch (Error e) {
                error(@"Parser error: This string should have been already parsed: $(e.message) - '$(js)'");
            }
            unowned Json.Node p_root = p.get_root();
            unowned Json.Node p_value = exec_path(p_root).get_object().get_member("value");
            Json.Node cp_value = p_value.copy();
            return Json.gobject_deserialize(type, cp_value);
        }
    }

    public class CommSerialization : Object
    {
        /* API */

        public string prepare_argument_object(Object obj)
        {
            return prepare_argument(new JsonBuilderObject(obj));
        }

        public Object read_argument_object_notnull(Type expected_type, string js) throws CommDeserializeError, HelperNotJsonError
        {
            return read_argument_object(expected_type, js, false);
        }

        public string prepare_return_value_object(Object obj)
        {
            return prepare_return_value(new JsonBuilderObject(obj));
        }

        public Object read_return_value_object_notnull
            (Type expected_type, string js)
            throws CommDeserializeError, HelperNotJsonError
        {
            return read_return_value_object(expected_type, js, false);
        }

        //...

        /* Internals */

        //...

        internal string prepare_argument(IJsonBuilderElement cb)
        {
            var b = new Json.Builder();
            b.begin_object();
            b.set_member_name("argument");
            cb.execute(b);
            b.end_object();
            var g = new Json.Generator();
            g.pretty = false;
            g.root = b.get_root();
            return g.to_data(null);
        }

        internal void read_argument(string js, IJsonReaderElement cb) throws CommDeserializeError, HelperNotJsonError
        {
            Json.Parser p = new Json.Parser();
            try {
                p.load_from_data(js);
            } catch (Error e) {
                throw new HelperNotJsonError.GENERIC(e.message);
            }
            Json.Reader r = new Json.Reader(p.get_root());
            if (!r.is_object())
                throw new CommDeserializeError.GENERIC(@"root JSON node must be an object");
            if (!r.read_member("argument"))
                throw new CommDeserializeError.GENERIC(@"root JSON node must have argument");
            cb.execute(r);
            r.end_member();
        }

        internal Object? read_argument_object
         (Type expected_type, string js, bool nullable)
         throws CommDeserializeError, HelperNotJsonError
        {
            JsonReaderObject cb = new JsonReaderObject(expected_type, nullable);
            read_argument(js, cb);
            assert(cb.ret_ok);
            return cb.deserialize_or_null(js, (root) => {
                return root.get_object().get_member("argument");
            });
        }

        internal string prepare_return_value(IJsonBuilderElement cb)
        {
            var b = new Json.Builder();
            b.begin_object();
            b.set_member_name("return-value");
            cb.execute(b);
            b.end_object();
            var g = new Json.Generator();
            g.pretty = false;
            g.root = b.get_root();
            return g.to_data(null);
        }

        internal void read_return_value
         (string js, IJsonReaderElement cb)
         throws CommDeserializeError, HelperNotJsonError
        {
            Json.Parser p = new Json.Parser();
            try {
                p.load_from_data(js);
            } catch (Error e) {
                throw new HelperNotJsonError.GENERIC(e.message);
            }
            Json.Reader r = new Json.Reader(p.get_root());
            if (!r.is_object())
                throw new CommDeserializeError.GENERIC(@"root JSON node must be an object");
            string[] members = r.list_members();
            if ("return-value" in members)
            {
                r.read_member("return-value");
                cb.execute(r);
                r.end_member();
            }
            else
            {
                throw new CommDeserializeError.GENERIC(@"root JSON node must have return-value");
            }
        }

        internal Object? read_return_value_object
            (Type expected_type, string js, bool nullable)
            throws CommDeserializeError, HelperNotJsonError
        {
            JsonReaderObject cb = new JsonReaderObject(expected_type, nullable);
            read_return_value(js, cb);
            assert(cb.ret_ok);
            return cb.deserialize_or_null(js, (root) => {
                return root.get_object().get_member("return-value");
            });
        }


        /* Helper functions to build JSON sourceid, unicastid and broadcastid */

        public string prepare_direct_object(Object obj)
        {
            IJsonBuilderElement cb = new JsonBuilderObject(obj);
            var b = new Json.Builder();
            cb.execute(b);
            var g = new Json.Generator();
            g.pretty = false;
            g.root = b.get_root();
            return g.to_data(null);
        }

        /* Helper functions to read JSON sourceid, unicastid and broadcastid */

        internal void read_direct(string js, IJsonReaderElement cb) throws CommDeserializeError, HelperNotJsonError
        {
            Json.Parser p = new Json.Parser();
            try {
                p.load_from_data(js);
            } catch (Error e) {
                throw new HelperNotJsonError.GENERIC(e.message);
            }
            Json.Reader r = new Json.Reader(p.get_root());
            cb.execute(r);
        }

        public Object read_direct_object_notnull(Type expected_type, string js) throws CommDeserializeError, HelperNotJsonError
        {
            JsonReaderObject cb = new JsonReaderObject(expected_type, false);
            read_direct(js, cb);
            assert(cb.ret_ok);
            return cb.deserialize_or_null(js, (root) => {
                return root;
            });
        }

    }

    public interface ICommStub : Object
    {
        public abstract Object evaluate_enter(Object arg0) throws StubError, StreamSystemError, DeserializeError;
        // ... TODO
    }

    public ICommStub get_comm_stream_system(
        string send_pathname,
        ISourceID source_id, IUnicastID unicast_id, ISrcNic src_nic,
        bool wait_reply)
    {
        return new StreamSystemCommStub(send_pathname,
            source_id, unicast_id, src_nic,
            wait_reply);
    }

    internal class StreamSystemCommStub : Object, ICommStub
    {
        private CommSerialization com_ser;
        private CommSockets com_soc;
        private string s_source_id;
        private string s_unicast_id;
        private string s_src_nic;
        private string send_pathname;
        private bool wait_reply;
        public StreamSystemCommStub(
            string send_pathname,
            ISourceID source_id, IUnicastID unicast_id, ISrcNic src_nic,
            bool wait_reply)
        {
            com_ser = new CommSerialization();
            com_soc = new CommSockets();
            s_source_id = com_ser.prepare_direct_object(source_id);
            s_unicast_id = com_ser.prepare_direct_object(unicast_id);
            s_src_nic = com_ser.prepare_direct_object(src_nic);
            this.send_pathname = send_pathname;
            this.wait_reply = wait_reply;
        }

        private string call(string m_name, string arg) throws StubError, StreamSystemError
        {
            string ret =
                com_soc.send_stream_system(
                send_pathname,
                s_source_id, s_src_nic, s_unicast_id, m_name, arg,
                wait_reply);
            if (!wait_reply) throw new StubError.DID_NOT_WAIT_REPLY(@"Didn't wait reply for a call to $(m_name)");
            return ret;
        }

        public Object evaluate_enter(Object arg0) throws StubError, StreamSystemError, DeserializeError
        {
            string m_name = "comm.evaluate_enter";
            string arg = com_ser.prepare_argument_object(arg0);

            string resp = this.call(m_name, arg);

            // deserialize response
            string doing = @"Reading return-value of $(m_name)";
            Object ret;
            try {
                ret = com_ser.read_return_value_object_notnull(typeof(Object), resp);
            } catch (HelperNotJsonError e) {
                error(@"Error parsing JSON for return-value of $(m_name): $(e.message)");
            } catch (CommDeserializeError e) {
                throw new DeserializeError.GENERIC(@"$(doing): $(e.message)");
            }
            if (ret is ISerializable)
                if (!((ISerializable)ret).check_deserialization())
                    throw new DeserializeError.GENERIC(@"$(doing): instance of $(ret.get_type().name()) has not been fully deserialized");
            return ret;
        }
    }

    public interface ICommSkeleton : Object
    {
        public abstract Object evaluate_enter(Object arg0);
        // ... TODO
    }

    internal class CommStreamDispatcher : Object
    {
        public CommStreamDispatcher(ICommSkeleton comm, CommSerialization com_ser)
        {
            this.comm = comm;
            this.com_ser = com_ser;
        }
        private ICommSkeleton comm;
        private CommSerialization com_ser;

        public string execute(string m_name, string arg)
        {
            return comm_dispatcher_execute_rpc(com_ser, comm, m_name, arg);
        }
    }

    internal string comm_dispatcher_execute_rpc(
        CommSerialization com_ser,
        ICommSkeleton comm,
        string m_name, string arg)
    {
        string ret;
        if (m_name == "comm.evaluate_enter")
        {
            // argument:
            Object arg0;
            try {
                arg0 = com_ser.read_argument_object_notnull(typeof(Object), arg);
                if (arg0 is ISerializable)
                    if (!((ISerializable)arg0).check_deserialization())
                        error(@"Reading argument for $(m_name): instance of $(arg0.get_type().name()) has not been fully deserialized");
            } catch (HelperNotJsonError e) {
                error(@"Reading argument for $(m_name): HelperNotJsonError $(e.message)");
            } catch (CommDeserializeError e) {
                error(@"Reading argument for $(m_name): CommDeserializeError $(e.message)");
            }

            Object result = comm.evaluate_enter(arg0);
            ret = com_ser.prepare_return_value_object(result);
        }
        else if (m_name == "TODO")
        {
            error(@"Unknown method: \"$(m_name)\"");
            // TODO
        }
        else
        {
            error(@"Unknown method: \"$(m_name)\"");
        }
        return ret;
    }

    internal delegate string FakeRmt(string m_name, string arg) throws StubError;

}