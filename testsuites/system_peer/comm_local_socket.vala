using Gee;
using TaskletSystem;

namespace SystemPeer
{
    /* API */

    public errordomain StreamSystemCommunicatorNoDispatcherError {
        GENERIC
    }

    public interface IStreamSystemCommunicator : Object
    {
        public abstract void communicate(
            string source_id,
            string unicast_id,
            string src_nic,
            string m_name,
            Gee.List<string> arguments,
            bool wait_reply,
            out string resp
            ) throws StreamSystemCommunicatorNoDispatcherError;
    }

    public errordomain StreamSystemError {
        GENERIC
    }

    /* Internals */

    errordomain MessageError {
        MALFORMED
    }

    errordomain InvalidJsonError {
        GENERIC
    }

    errordomain RecvMessageError {
        TOO_BIG,
        FAIL_ALLOC,
        GENERIC
    }

    errordomain SendMessageError {
        GENERIC
    }

    interface IListenerTasklet : Object, ITaskletSpawnable
    {
        public abstract void after_kill();
    }

    public class Comm : Object
    {
        /* API */

        public void start_stream_system_listen(string listen_pathname, IStreamSystemCommunicator communicator)
        {
            do_start_stream_system_listen(listen_pathname, communicator);
        }

        public void stop_stream_system_listen(string listen_pathname)
        {
            do_stop_stream_system_listen(listen_pathname);
        }

        public string send_stream_system(
            string send_pathname,
            string source_id, string src_nic, string unicast_id,
            string m_name, Gee.List<string> arguments, bool wait_reply) throws StreamSystemError
        {
            return do_send_stream_system(
                send_pathname,
                source_id, src_nic, unicast_id,
                m_name, arguments,  wait_reply);
        }

        /* Internals */

        static void parse_and_validate(Json.Parser p, string s) throws Error
        {
            p.load_from_data(s);
            unowned Json.Node p_rootnode = p.get_root();
            if (p_rootnode == null) throw new IOError.FAILED("null-root");
        }

        static string generate_stream(Json.Node node)
        {
            Json.Node cp = node.copy();
            Json.Generator g = new Json.Generator();
            g.pretty = false;
            g.root = cp;
            return g.to_data(null);
        }

        static void build_unicast_request(
            string m_name,
            Gee.List<string> arguments,
            string source_id,
            string unicast_id,
            string src_nic,
            bool wait_reply,
            out string json_tree_request)
            throws InvalidJsonError
        {
            Json.Builder b = new Json.Builder();
            b.begin_object();
                b.set_member_name("method-name").add_string_value(m_name);

                b.set_member_name("arguments").begin_array();
                    for (int j = 0; j < arguments.size; j++)
                    {
                        string arg = arguments[j];
                        var p = new Json.Parser();
                        try {
                            parse_and_validate(p, arg);
                        } catch (Error e) {
                            throw new InvalidJsonError.GENERIC(
                                @"Error parsing JSON for argument from my own stub: $(e.message)"
                                + @" method-name: $(m_name)"
                                + @" argument #$(j): '$(arg)'");
                        }
                        unowned Json.Node p_rootnode = p.get_root();
                        assert(p_rootnode != null);
                        Json.Node* cp = p_rootnode.copy();
                        b.add_value(cp);
                    }
                b.end_array();

                b.set_member_name("source-id");
                {
                    var p = new Json.Parser();
                    try {
                        parse_and_validate(p, source_id);
                    } catch (Error e) {
                        throw new InvalidJsonError.GENERIC(
                            @"Error parsing JSON for source_id from my own stub: $(e.message)"
                            + @" string source_id : $(source_id)");
                    }
                    unowned Json.Node p_rootnode = p.get_root();
                    assert(p_rootnode != null);
                    Json.Node* cp = p_rootnode.copy();
                    b.add_value(cp);
                }

                b.set_member_name("unicast-id");
                {
                    var p = new Json.Parser();
                    try {
                        parse_and_validate(p, unicast_id);
                    } catch (Error e) {
                        throw new InvalidJsonError.GENERIC(
                            @"Error parsing JSON for unicast_id from my own stub: $(e.message)"
                            + @" string unicast_id : $(unicast_id)");
                    }
                    unowned Json.Node p_rootnode = p.get_root();
                    assert(p_rootnode != null);
                    Json.Node* cp = p_rootnode.copy();
                    b.add_value(cp);
                }

                b.set_member_name("src-nic");
                {
                    var p = new Json.Parser();
                    try {
                        parse_and_validate(p, src_nic);
                    } catch (Error e) {
                        throw new InvalidJsonError.GENERIC(
                            @"Error parsing JSON for src_nic from my own stub: $(e.message)"
                            + @" string src_nic : $(src_nic)");
                    }
                    unowned Json.Node p_rootnode = p.get_root();
                    assert(p_rootnode != null);
                    Json.Node* cp = p_rootnode.copy();
                    b.add_value(cp);
                }

                b.set_member_name("wait-reply").add_boolean_value(wait_reply);
            b.end_object();
            Json.Node node = b.get_root();
            json_tree_request = generate_stream(node);
        }

        static void parse_unicast_request(
            string json_tree_request,
            out string m_name,
            out Gee.List<string> arguments,
            out string source_id,
            out string unicast_id,
            out string src_nic,
            out bool wait_reply)
            throws MessageError
        {
            try {
                // The parser must not be freed until we finish with the reader.
                Json.Parser p_buf = new Json.Parser();
                parse_and_validate(p_buf, json_tree_request);
                unowned Json.Node buf_rootnode = p_buf.get_root();
                assert(buf_rootnode != null);
                Json.Reader r_buf = new Json.Reader(buf_rootnode);
                if (!r_buf.is_object()) throw new MessageError.MALFORMED("root must be an object");

                if (!r_buf.read_member("method-name")) throw new MessageError.MALFORMED("root must have method-name");
                if (!r_buf.is_value()) throw new MessageError.MALFORMED("method-name must be a string");
                if (r_buf.get_value().get_value_type() != typeof(string)) throw new MessageError.MALFORMED("method-name must be a string");
                m_name = r_buf.get_string_value();
                r_buf.end_member();

                if (!r_buf.read_member("arguments")) throw new MessageError.MALFORMED("root must have arguments");
                if (!r_buf.is_array()) throw new MessageError.MALFORMED("arguments must be an array");
                int num_elements = r_buf.count_elements();
                arguments = new ArrayList<string>();
                for (int j = 0; j < num_elements; j++)
                {
                    r_buf.read_element(j);
                    if (!r_buf.is_object() && !r_buf.is_array()) throw new MessageError.MALFORMED("each argument must be a valid JSON tree");
                    r_buf.end_element();
                }
                r_buf.end_member();
                for (int j = 0; j < num_elements; j++)
                {
                    unowned Json.Node node1 = buf_rootnode.get_object().get_array_member("arguments").get_element(j);
                    arguments.add(generate_stream(node1));
                }

                if (!r_buf.read_member("source-id")) throw new MessageError.MALFORMED("root must have source-id");
                if (!r_buf.is_object() && !r_buf.is_array())
                    throw new MessageError.MALFORMED(@"source-id must be a valid JSON tree");
                r_buf.end_member();
                unowned Json.Node node2 = buf_rootnode.get_object().get_member("source-id");
                source_id = generate_stream(node2);

                if (!r_buf.read_member("unicast-id")) throw new MessageError.MALFORMED("root must have unicast-id");
                if (!r_buf.is_object() && !r_buf.is_array())
                    throw new MessageError.MALFORMED(@"unicast-id must be a valid JSON tree");
                r_buf.end_member();
                unowned Json.Node node3 = buf_rootnode.get_object().get_member("unicast-id");
                unicast_id = generate_stream(node3);

                if (!r_buf.read_member("src-nic")) throw new MessageError.MALFORMED("root must have src-nic");
                if (!r_buf.is_object() && !r_buf.is_array())
                    throw new MessageError.MALFORMED(@"src-nic must be a valid JSON tree");
                r_buf.end_member();
                unowned Json.Node node4 = buf_rootnode.get_object().get_member("src-nic");
                src_nic = generate_stream(node4);

                if (!r_buf.read_member("wait-reply")) throw new MessageError.MALFORMED("root must have wait-reply");
                if (!r_buf.is_value()) throw new MessageError.MALFORMED("wait-reply must be a boolean");
                if (r_buf.get_value().get_value_type() != typeof(bool)) throw new MessageError.MALFORMED("wait-reply must be a boolean");
                wait_reply = r_buf.get_boolean_value();
                r_buf.end_member();
            } catch (MessageError e) {
                throw e;
            } catch (Error e) {
                throw new MessageError.MALFORMED(@"Error parsing json_tree_request: $(e.message)");
            }
        }

        static void build_unicast_response(
            string response,
            out string json_tree_response)
            throws InvalidJsonError
        {
            Json.Builder b = new Json.Builder();
            Json.Parser p = new Json.Parser();
            b.begin_object();
                b.set_member_name("response");
                try {
                    parse_and_validate(p, response);
                } catch (Error e) {
                    throw new InvalidJsonError.GENERIC(
                        @"Error parsing JSON for response from my own dispatcher: $(e.message)"
                        + @" response: $(response)");
                }
                unowned Json.Node p_rootnode = p.get_root();
                assert(p_rootnode != null);
                Json.Node* cp = p_rootnode.copy();
                b.add_value(cp);
            b.end_object();
            Json.Node node = b.get_root();
            json_tree_response = generate_stream(node);
        }

        static void parse_unicast_response(
            string json_tree_response,
            out string response)
            throws MessageError
        {
            try {
                Json.Parser p_buf = new Json.Parser();
                parse_and_validate(p_buf, json_tree_response);
                unowned Json.Node buf_rootnode = p_buf.get_root();
                assert(buf_rootnode != null);
                Json.Reader r_buf = new Json.Reader(buf_rootnode);
                if (!r_buf.is_object()) throw new MessageError.MALFORMED("root must be an object");
                if (!r_buf.read_member("response")) throw new MessageError.MALFORMED("root must have response");
                if (!r_buf.is_object() && !r_buf.is_array()) throw new MessageError.MALFORMED("response must be a valid JSON tree");
                r_buf.end_member();
                Json.Node cp = buf_rootnode.get_object().get_member("response").copy();
                Json.Generator g = new Json.Generator();
                g.pretty = false;
                g.root = cp;
                response = g.to_data(null);
            } catch (MessageError e) {
                throw e;
            } catch (Error e) {
                throw new MessageError.MALFORMED(@"Error parsing json_tree_response: $(e.message)");
            }
        }

        static void send_one_message(IConnectedStreamSocket c, string msg) throws SendMessageError
        {
            size_t len = msg.length;
            assert(len <= uint32.MAX);
            uint8 buf_numbytes[4];
            buf_numbytes[3] = (uint8)(len % 256);
            len -= buf_numbytes[3];
            len /= 256;
            buf_numbytes[2] = (uint8)(len % 256);
            len -= buf_numbytes[2];
            len /= 256;
            buf_numbytes[1] = (uint8)(len % 256);
            len -= buf_numbytes[1];
            len /= 256;
            buf_numbytes[0] = (uint8)(len % 256);
            try {
                c.send(buf_numbytes, 4);
                c.send(msg.data, msg.length);
            } catch (Error e) {
                throw new SendMessageError.GENERIC(@"$(e.message)");
            }
        }

        static size_t max_msg_size = 10000000;

        /*
        ** If the connection was closed from peer, we return false and m=null.
        ** If an RecvMessageError is reported, m=null.
        ** If m!= null, the caller can safely use something like that:
                    unowned uint8[] buf;
                    buf = (uint8[])m;
                    buf.length = (int)s;
                    unowned string msg = (string)buf;
        ** After using msg, the caller has to free m.
        **/
        static bool get_one_message(IConnectedStreamSocket c, out void * m, out size_t s) throws RecvMessageError
        {
            // Get one message
            m = null;
            s = 0;
            unowned uint8[] buf;

            uint8 buf_numbytes[4];
            size_t maxlen = 4;
            uint8* b = buf_numbytes;
            bool no_bytes_read = true;
            while (maxlen > 0)
            {
                try {
                    size_t len = c.recv(b, maxlen);
                    if (len == 0)
                    {
                        if (no_bytes_read)
                        {
                            // normal closing from client, abnormal if from server.
                            return false;
                        }
                        throw new RecvMessageError.GENERIC("4-bytes length is missing");
                    }
                    no_bytes_read = false;
                    maxlen -= len;
                    b += len;
                } catch (Error e) {
                    throw new RecvMessageError.GENERIC(e.message);
                }
            }
            size_t msglen = buf_numbytes[0];
            msglen *= 256;
            msglen += buf_numbytes[1];
            msglen *= 256;
            msglen += buf_numbytes[2];
            msglen *= 256;
            msglen += buf_numbytes[3];
            if (msglen > max_msg_size)
            {
                throw new RecvMessageError.TOO_BIG(@"Refusing to receive a message too big ($(msglen) bytes)");
            }

            s = msglen + 1;
            m = try_malloc(s);
            if (m == null)
            {
                throw new RecvMessageError.FAIL_ALLOC(@"Could not allocate memory ($(s) bytes)");
            }
            buf = (uint8[])m;
            buf.length = (int)s;
            maxlen = msglen;
            b = buf;
            while (maxlen > 0)
            {
                try {
                    size_t len = c.recv(b, maxlen);
                    if (len == 0)
                    {
                        throw new RecvMessageError.GENERIC(@"More bytes (len=$(msglen)) were expected.");
                    }
                    maxlen -= len;
                    b += len;
                } catch (Error e) {
                    free(m);
                    m = null;
                    s = 0;
                    throw new RecvMessageError.GENERIC(e.message);
                }
            }
            buf[msglen] = (uint8)0;
            return true;
        }

        class ListenerHandle : Object
        {
            private ITaskletHandle th;
            private IListenerTasklet t;
            public ListenerHandle(ITaskletHandle th, IListenerTasklet t)
            {
                this.th = th;
                this.t = t;
            }

            public void kill()
            {
                th.kill();
                t.after_kill();
            }
        }

        HashMap<string,ListenerHandle> handles_by_listen_pathname;

        void do_start_stream_system_listen(string listen_pathname, IStreamSystemCommunicator communicator)
        {
            if (handles_by_listen_pathname == null) handles_by_listen_pathname = new HashMap<string,ListenerHandle>();
            handles_by_listen_pathname[listen_pathname] = stream_system_listen(listen_pathname, communicator);
        }

        void do_stop_stream_system_listen(string listen_pathname)
        {
            assert(handles_by_listen_pathname != null);
            assert(handles_by_listen_pathname.has_key(listen_pathname));
            ListenerHandle lh = handles_by_listen_pathname[listen_pathname];
            lh.kill();
            handles_by_listen_pathname.unset(listen_pathname);
        }

        ListenerHandle stream_system_listen(string listen_pathname, IStreamSystemCommunicator communicator)
        {
            StreamSystemListenerTasklet t = new StreamSystemListenerTasklet();
            t.listen_pathname = listen_pathname;
            t.communicator = communicator;
            ITaskletHandle th = tasklet.spawn(t);
            var ret = new ListenerHandle(th, t);
            return ret;
        }
        class StreamSystemListenerTasklet : Object, ITaskletSpawnable, IListenerTasklet
        {
            public string listen_pathname;
            public IStreamSystemCommunicator communicator;
            private IServerStreamLocalSocket s;

            public StreamSystemListenerTasklet()
            {
                s = null;
            }

            public void * func()
            {
                try {
                    s = tasklet.get_server_stream_local_socket(listen_pathname);
                    while (true) {
                        IConnectedStreamSocket c = s.accept();
                        StreamConnectionHandlerTasklet t = new StreamConnectionHandlerTasklet();
                        t.c = c;
                        t.communicator = communicator;
                        tasklet.spawn(t);
                    }
                } catch (Error e) {
                    error(e.message);
                }
                // point not_reached
                // This function (i.e. the tasklet) will exit after an error or for a kill.
            }

            public void after_kill()
            {
                // This function should be called only after killing the tasklet.
                assert(s != null);
                try {s.close();} catch (Error e) {}
            }
        }
        class StreamConnectionHandlerTasklet : Object, ITaskletSpawnable
        {
            public IConnectedStreamSocket c;
            public IStreamSystemCommunicator communicator;

            private void *m;

            public void * func()
            {
                m = null;
                while (true)
                {
                    if (m != null) free(m);
                    // Get one message
                    size_t s;
                    try {
                        bool got = get_one_message(c, out m, out s);
                        if (!got)
                        {
                            // closed normally, terminate tasklet
                            cleanup();
                            return null;
                        }
                    } catch (RecvMessageError e) {
                        // log message
                        warning(@"stream_listener: Error receiving message: $(e.message)");
                        // terminate tasklet
                        cleanup();
                        return null;
                    }
                    unowned uint8[] buf;
                    buf = (uint8[])m;
                    buf.length = (int)s;

                    // Parse JSON
                    string source_id;
                    string unicast_id;
                    string src_nic;
                    string m_name;
                    Gee.List<string> arguments;
                    bool wait_reply;
                    try {
                        parse_unicast_request(
                            (string)buf,
                            out m_name,
                            out arguments,
                            out source_id,
                            out unicast_id,
                            out src_nic,
                            out wait_reply);
                    } catch (MessageError e) {
                        // log message
                        warning(@"stream_listener: Error parsing JSON of received message: $(e.message)");
                        // terminate tasklet
                        cleanup();
                        return null;
                    }

                    string resp;
                    try {
                        communicator.communicate(
                            source_id,
                            unicast_id,
                            src_nic,
                            m_name,
                            arguments,
                            wait_reply,
                            out resp);
                    } catch (StreamSystemCommunicatorNoDispatcherError e) {
                        // log message
                        debug(@"stream_listener: Delegate stream_dlg did not recognize this message.");
                        // Ignore this msg and terminate tasklet
                        cleanup();
                        return null;
                    }
                    if (wait_reply)
                    {
                        string json_tree_response;
                        try {
                            build_unicast_response(
                                resp,
                                out json_tree_response
                                );
                        } catch (InvalidJsonError e) {
                            error(@"stream_listener: Error building JSON from my own result: $(e.message)");
                        }
                        // Send response
                        try {
                            send_one_message(c, json_tree_response);
                        } catch (SendMessageError e) {
                            // log message
                            warning(@"stream_listener: Error sending JSON of response: $(e.message)");
                            // terminate tasklet
                            cleanup();
                            return null;
                        }
                    }
                }
                // point not_reached
            }

            private void cleanup()
            {
                // close connection
                try {c.close();} catch (Error e) {}
                if (m != null) free(m);
            }
        }

        HashMap<string, Gee.List<IConnectedStreamSocket>> connected_pools;
        delegate IConnectedStreamSocket GetNewConnection() throws Error;

        string do_send_stream_system(
            string send_pathname,
            string source_id, string src_nic, string unicast_id,
            string m_name, Gee.List<string> arguments, bool wait_reply) throws StreamSystemError
        {
            // Handle pools of connections.
            if (connected_pools == null) connected_pools = new HashMap<string, Gee.List<IConnectedStreamSocket>>();
            string key = @"local_$(send_pathname)";
            if (!connected_pools.has_key(key)) connected_pools[key] = new ArrayList<IConnectedStreamSocket>();
            Gee.List<IConnectedStreamSocket> connected_pool = connected_pools[key];
            GetNewConnection get_new_connection = () => tasklet.get_client_stream_local_socket(send_pathname);

            // common part
            return send_stream(
                connected_pool, key, get_new_connection,
                source_id, src_nic, unicast_id,
                m_name, arguments, wait_reply);
        }

        string send_stream(
            Gee.List<IConnectedStreamSocket> connected_pool, string key, GetNewConnection get_new_connection,
            string source_id, string src_nic, string unicast_id,
            string m_name, Gee.List<string> arguments, bool wait_reply) throws StreamSystemError
        {
            IConnectedStreamSocket c = null;
            bool try_again = true;
            while (try_again)
            {
                // Get a connection
                try_again = false;
                bool old_socket = false;
                if (connected_pool.is_empty) {
                    try {
                        c = get_new_connection();
                    } catch (Error e) {
                        throw new StreamSystemError.GENERIC(@"send_stream($(key)): Error connecting: $(e.message)");
                    }
                } else {
                    old_socket = true;
                    c = connected_pool.remove_at(0);
                }

                // build message
                string json_tree_request;
                try {
                    build_unicast_request(
                        m_name,
                        arguments,
                        source_id,
                        unicast_id,
                        src_nic,
                        wait_reply,
                        out json_tree_request);
                } catch (InvalidJsonError e) {
                    error(@"send_stream($(key)): Error building JSON from my own request: $(e.message)");
                }

                // send one message
                try {
                    send_one_message(c, json_tree_request);
                } catch (SendMessageError e) {
                    if (old_socket)
                    {
                        try_again = true;
                        // log message (because we'll retry)
                        warning(@"send_stream($(key)): could not write to old socket: $(e.message). We'll try another one.");
                        continue;
                    }
                    else throw new StreamSystemError.GENERIC(@"send_stream($(key)): Error while writing: $(e.message)");
                }
            }
            assert(c != null);

            // no reply?
            if (! wait_reply)
            {
                connected_pool.add(c);
                return "";
            }

            // wait reply
            // Get one message
            void *m;
            size_t s;
            try {
                bool got = get_one_message(c, out m, out s);
                if (!got) throw new StreamSystemError.GENERIC(@"send_stream($(key)): Connection was closed while waiting reply.");
            } catch (RecvMessageError e) {
                throw new StreamSystemError.GENERIC(@"send_stream($(key)): Error receiving reply: $(e.message)");
            }
            unowned uint8[] buf;
            buf = (uint8[])m;
            buf.length = (int)s;
            string json_tree_response = (string)buf; // copy
            free(m);

            // Parse JSON
            string response;
            try {
                parse_unicast_response(
                    json_tree_response,
                    out response);
            } catch (MessageError e) {
                throw new StreamSystemError.GENERIC(@"send_stream($(key)): Error parsing JSON of received reply: $(e.message)");
            }
            connected_pool.add(c);
            return response;
        }
    }
}