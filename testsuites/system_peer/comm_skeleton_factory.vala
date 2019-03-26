using Gee;
using TaskletSystem;
using Netsukuku;

namespace SystemPeer
{
    public interface ICommSkeleton : Object
    {
        public abstract Object evaluate_enter(Object arg0);
        // ... TODO
    }

    internal class StreamSystemCommunicator : Object, IStreamSystemCommunicator, ICommSkeleton
    {
        public StreamSystemCommunicator(CommSerialization com_ser, IdentityData identity_data)
        {
            this.com_ser = com_ser;
            this.identity_data = identity_data;
        }
        private CommSerialization com_ser;
        private IdentityData identity_data;
        private ArrayList<int> client_address;

        public void communicate(
            string source_id,
            string unicast_id,
            string src_nic,
            string m_name,
            string arg,
            bool wait_reply,
            out string resp
            ) throws StreamSystemCommunicatorNoDispatcherError
        {
            // public Object read_direct_object_notnull(Type expected_type, string js) throws CommDeserializeError, HelperNotJsonError
            string s_total_client_address;
            try {
                Object _src_nic = com_ser.read_direct_object_notnull(typeof(ClientAddressSrcNic), src_nic);
                ClientAddressSrcNic client_address_src_nic = (ClientAddressSrcNic)_src_nic;
                s_total_client_address = client_address_src_nic.client_address;
            } catch (CommDeserializeError e) {
                throw new StreamSystemCommunicatorNoDispatcherError.GENERIC(@"CommDeserializeError $(e.message)");
            } catch (HelperNotJsonError e) {
                throw new StreamSystemCommunicatorNoDispatcherError.GENERIC(@"HelperNotJsonError $(e.message)");
            }
            ArrayList<int> total_client_address = new ArrayList<int>();
            string[] parts = s_total_client_address.split(",");
            for (int i = 0; i < parts.length; i++)
            {
                int64 element;
                if (! int64.try_parse(parts[i], out element)) error("bad parts element in src_nic.client_address in remote call comm.");
                total_client_address.add((int)element);
            }
            client_address = new ArrayList<int>();
            for (int i = levels-1; i >= 0; i--)
            {
                if (client_address.size == 0 && total_client_address[i] == identity_data.get_my_naddr_pos(i)) continue;
                client_address.insert(0, total_client_address[i]);
            }
            resp = comm_dispatcher_execute_rpc(com_ser, this, m_name, arg);
        }

        private void log_call(string m_name)
        {
            string s_client_address = ""; string next = "";
            for (int i = 0; i < client_address.size; i++)
            {
                s_client_address = @"$(s_client_address)$(next)$(client_address[i])";
                next = ",";
            }
            if (client_address.size == 0) s_client_address = "myself";
            debug(@"StreamSystemCommunicator: calling $(m_name) per request from $(s_client_address).");
        }

        public Object evaluate_enter(Object arg0)
        {
            log_call("evaluate_enter");
            return identity_data.hook_mgr.evaluate_enter(arg0, client_address);
        }
    }

    CommSkeletonFactory comm_skeleton_factory;
    class CommSkeletonFactory : Object
    {
        private CommSerialization com_ser;
        private CommSockets com_soc;
        HashMap<string,IListenerHandle> handles_by_listen_pathname;
        public CommSkeletonFactory()
        {
            com_ser = new CommSerialization();
            com_soc = new CommSockets();
        }

        public void start_stream_system_listen(string listen_pathname, IdentityData identity_data)
        {
            IStreamSystemCommunicator communicator = new StreamSystemCommunicator(com_ser, identity_data);
            com_soc.start_stream_system_listen(listen_pathname, communicator);
        }
        public void stop_stream_system_listen(string listen_pathname)
        {
            com_soc.stop_stream_system_listen(listen_pathname);
        }
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
}