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

    public CommSkeletonFactory comm_skeleton_factory;
    public class CommSkeletonFactory : Object
    {
        private CommSerialization com_ser;
        private CommSockets com_soc;
        private IStreamSystemCommunicator communicator;
        HashMap<string,IListenerHandle> handles_by_listen_pathname;
        public CommSkeletonFactory()
        {
            com_ser = new CommSerialization();
            com_soc = new CommSockets();
            // communicator = ???
        }

        public void start_stream_system_listen(string listen_pathname)
        {   
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