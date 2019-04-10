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


    public class NullSourceID : Object, ISourceID
    {
    }

    public class NullUnicastID : Object, IUnicastID
    {
    }

    public class NullSrcNic : Object, ISrcNic
    {
    }

    public class ClientAddressSrcNic : Object, ISrcNic
    {
        public ClientAddressSrcNic(string client_address)
        {
            this.client_address = client_address;
        }
        public string client_address {get; set;}
    }

    public class ArgLevelObj : Object, Json.Serializable
    {
        public ArgLevelObj(int lvl, Object obj)
        {
            this.lvl = lvl;
            this.obj = obj;
        }
        public int lvl {get; set;}
        public Object obj {get; set;}

        public bool deserialize_property
        (string property_name,
         out GLib.Value @value,
         GLib.ParamSpec pspec,
         Json.Node property_node)
        {
            @value = 0;
            switch (property_name) {
            case "lvl":
                try {
                    @value = deserialize_int(property_node);
                } catch (HelperDeserializeError e) {
                    return false;
                }
                break;
            case "obj":
                try {
                    @value = deserialize_object(typeof(Object), true, property_node);
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
            case "lvl":
                return serialize_int((int)@value);
            case "obj":
                return serialize_object((Object?)@value);
            default:
                error(@"wrong param $(property_name)");
            }
        }
    }


    internal interface IJsonBuilderElement : Object {
        public abstract void execute(Json.Builder b);
    }

    internal interface IJsonReaderElement : Object {
        public abstract void execute(Json.Reader r) throws CommDeserializeError;
    }

    internal delegate unowned Json.Node JsonExecPath(Json.Node root);

    internal delegate void JsonReadElement(Json.Reader r, int index) throws CommDeserializeError;

    internal class JsonBuilderNull : Object, IJsonBuilderElement
    {
        public JsonBuilderNull() {}
        public void execute(Json.Builder b) {
            b.add_null_value();
        }
    }

    internal class JsonReaderVoid : Object, IJsonReaderElement
    {
        public bool ret_ok;
        public JsonReaderVoid() {
            ret_ok = false;
        }
        public void execute(Json.Reader r) throws CommDeserializeError {
            if (!r.get_null_value())
                throw new CommDeserializeError.GENERIC("element must be void");
            ret_ok = true;
        }
    }

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

        public string prepare_return_value_null()
        {
            return prepare_return_value(new JsonBuilderNull());
        }

        public Object read_return_value_object_notnull
            (Type expected_type, string js)
            throws CommDeserializeError, HelperNotJsonError
        {
            return read_return_value_object(expected_type, js, false);
        }

        public void read_return_value_void
            (string js)
            throws CommDeserializeError, HelperNotJsonError
        {
            JsonReaderVoid cb = new JsonReaderVoid();
            read_return_value(js, cb);
            assert(cb.ret_ok);
            return;
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
}