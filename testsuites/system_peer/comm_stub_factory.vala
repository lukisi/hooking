using Gee;
using TaskletSystem;
using Netsukuku;

namespace SystemPeer
{
    public interface ICommStub : Object
    {
        public abstract Object evaluate_enter(Object arg0) throws StubError, StreamSystemError, DeserializeError;
        public abstract Object begin_enter(Object arg0) throws StubError, StreamSystemError, DeserializeError;
        public abstract Object completed_enter(Object arg0) throws StubError, StreamSystemError, DeserializeError;
        public abstract Object abort_enter(Object arg0) throws StubError, StreamSystemError, DeserializeError;
        public abstract void prepare_enter(Object arg0) throws StubError, StreamSystemError, DeserializeError;
        public abstract void finish_enter(Object arg0) throws StubError, StreamSystemError, DeserializeError;
        // ... TODO
    }

    public ICommStub get_comm_stream_system(
        int local_identity_index,
        string send_pathname,
        ISrcNic src_nic,
        bool wait_reply)
    {
        ISourceID source_id = new NullSourceID();
        IUnicastID unicast_id = new NullUnicastID();
        return new StreamSystemCommStub(local_identity_index, send_pathname,
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
        private int local_identity_index;
        public StreamSystemCommStub(
            int local_identity_index, string send_pathname,
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
            this.local_identity_index = local_identity_index;
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

        private Object process_comm(string m_name, Object arg0) throws StubError, StreamSystemError, DeserializeError
        {
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

        private void process_comm_void(string m_name, Object arg0) throws StubError, StreamSystemError, DeserializeError
        {
            string arg = com_ser.prepare_argument_object(arg0);

            string resp;
            try {
                resp = this.call(m_name, arg);
            }
            // The following catch is to be added only for methods that return void.
            catch (StubError.DID_NOT_WAIT_REPLY e) {return;}

            // deserialize response
            string doing = @"Reading return-value of $(m_name)";
            try {
                com_ser.read_return_value_void(resp);
            } catch (HelperNotJsonError e) {
                error(@"Error parsing JSON for return-value of $(m_name): $(e.message)");
            } catch (CommDeserializeError e) {
                throw new DeserializeError.GENERIC(@"$(doing): $(e.message)");
            }
            return;
        }


        public Object evaluate_enter(Object arg0) throws StubError, StreamSystemError, DeserializeError
        {
            tester_events.add(@"HookingManager:$(local_identity_index):StreamSystemCommStub:calling_evaluate_enter");
            return process_comm("comm.evaluate_enter", arg0);
        }

        public Object begin_enter(Object arg0) throws StubError, StreamSystemError, DeserializeError
        {
            tester_events.add(@"HookingManager:$(local_identity_index):StreamSystemCommStub:calling_begin_enter");
            return process_comm("comm.begin_enter", arg0);
        }

        public Object completed_enter(Object arg0) throws StubError, StreamSystemError, DeserializeError
        {
            tester_events.add(@"HookingManager:$(local_identity_index):StreamSystemCommStub:calling_completed_enter");
            return process_comm("comm.completed_enter", arg0);
        }

        public Object abort_enter(Object arg0) throws StubError, StreamSystemError, DeserializeError
        {
            tester_events.add(@"HookingManager:$(local_identity_index):StreamSystemCommStub:calling_abort_enter");
            return process_comm("comm.abort_enter", arg0);
        }

        public void prepare_enter(Object arg0) throws StubError, StreamSystemError, DeserializeError
        {
            tester_events.add(@"HookingManager:$(local_identity_index):StreamSystemCommStub:calling_prepare_enter");
            process_comm_void("comm.prepare_enter", arg0);
        }

        public void finish_enter(Object arg0) throws StubError, StreamSystemError, DeserializeError
        {
            tester_events.add(@"HookingManager:$(local_identity_index):StreamSystemCommStub:calling_finish_enter");
            process_comm_void("comm.finish_enter", arg0);
        }
    }
}