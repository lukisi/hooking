using Gee;
using TaskletSystem;
using Netsukuku;

namespace SystemPeer
{
    public interface ICommSkeleton : Object
    {
        public abstract Object evaluate_enter(Object arg0, ArrayList<int> client_address);
        public abstract Object begin_enter(Object arg0, ArrayList<int> client_address);
        public abstract Object completed_enter(Object arg0, ArrayList<int> client_address);
        public abstract Object abort_enter(Object arg0, ArrayList<int> client_address);
        public abstract void prepare_enter(Object arg0);
        public abstract void finish_enter(Object arg0);
        public abstract void prepare_migration(Object arg0);
        public abstract void finish_migration(Object arg0);
        // ... TODO
    }

    internal class StreamSystemCommunicator : Object, IStreamSystemCommunicator, ICommSkeleton
    {
        public StreamSystemCommunicator(CommSerialization com_ser, int local_identity_index)
        {
            this.com_ser = com_ser;
            this.local_identity_index = local_identity_index;
        }
        private CommSerialization com_ser;
        private int local_identity_index;
        private IdentityData? _identity_data;
        public IdentityData identity_data {
            get {
                _identity_data = find_local_identity_by_index(local_identity_index);
                if (_identity_data == null) tasklet.exit_tasklet();
                return _identity_data;
            }
        }

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
            ArrayList<int> client_address = null;
            Object _src_nic;
            try {
                _src_nic = com_ser.read_direct_object_notnull(typeof(Object), src_nic);
            } catch (CommDeserializeError e) {
                error(@"CommDeserializeError $(e.message)");
            } catch (HelperNotJsonError e) {
                error(@"HelperNotJsonError $(e.message)");
            }
            if (_src_nic is ClientAddressSrcNic)
            {
                string s_total_client_address;
                ClientAddressSrcNic client_address_src_nic = (ClientAddressSrcNic)_src_nic;
                s_total_client_address = client_address_src_nic.client_address;
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
            }

            if (m_name == "comm.evaluate_enter")
            {
                tester_events.add(@"HookingManager:$(local_identity_index):ICommSkeleton:executing_evaluate_enter");
                // is client_address mandatory for this method?
                assert(client_address != null);
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

                Object result = evaluate_enter(arg0, client_address);
                resp = com_ser.prepare_return_value_object(result);
            }
            else if (m_name == "comm.begin_enter")
            {
                tester_events.add(@"HookingManager:$(local_identity_index):ICommSkeleton:executing_begin_enter");
                // is client_address mandatory for this method?
                assert(client_address != null);
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

                Object result = begin_enter(arg0, client_address);
                resp = com_ser.prepare_return_value_object(result);
            }
            else if (m_name == "comm.completed_enter")
            {
                tester_events.add(@"HookingManager:$(local_identity_index):ICommSkeleton:executing_completed_enter");
                // is client_address mandatory for this method?
                assert(client_address != null);
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

                Object result = completed_enter(arg0, client_address);
                resp = com_ser.prepare_return_value_object(result);
            }
            else if (m_name == "comm.abort_enter")
            {
                tester_events.add(@"HookingManager:$(local_identity_index):ICommSkeleton:executing_abort_enter");
                // is client_address mandatory for this method?
                assert(client_address != null);
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

                Object result = abort_enter(arg0, client_address);
                resp = com_ser.prepare_return_value_object(result);
            }
            else if (m_name == "comm.prepare_enter")
            {
                tester_events.add(@"HookingManager:$(local_identity_index):ICommSkeleton:executing_prepare_enter");
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

                prepare_enter(arg0);
                resp = com_ser.prepare_return_value_null();
            }
            else if (m_name == "comm.finish_enter")
            {
                tester_events.add(@"HookingManager:$(local_identity_index):ICommSkeleton:executing_finish_enter");
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

                finish_enter(arg0);
                resp = com_ser.prepare_return_value_null();
            }
            else if (m_name == "comm.prepare_migration")
            {
                tester_events.add(@"HookingManager:$(local_identity_index):ICommSkeleton:executing_prepare_migration");
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

                prepare_migration(arg0);
                resp = com_ser.prepare_return_value_null();
            }
            else if (m_name == "comm.finish_migration")
            {
                tester_events.add(@"HookingManager:$(local_identity_index):ICommSkeleton:executing_finish_migration");
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

                finish_migration(arg0);
                resp = com_ser.prepare_return_value_null();
            }
            else
            {
                error(@"Unknown method: \"$(m_name)\"");
            }
        }

        private void log_call_with_client_address(string m_name, ArrayList<int> client_address)
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

        private void log_call_per_propagation(string m_name)
        {
            debug(@"StreamSystemCommunicator: calling $(m_name) per propagation.");
        }

        public Object evaluate_enter(Object arg0, ArrayList<int> client_address)
        {
            log_call_with_client_address("evaluate_enter", client_address);
            return identity_data.hook_mgr.evaluate_enter(arg0, client_address);
        }

        public Object begin_enter(Object arg0, ArrayList<int> client_address)
        {
            log_call_with_client_address("begin_enter", client_address);
            assert(arg0 is ArgLevelObj);
            ArgLevelObj _arg0 = (ArgLevelObj)arg0;
            return identity_data.hook_mgr.begin_enter(_arg0.lvl, _arg0.obj, client_address);
        }

        public Object completed_enter(Object arg0, ArrayList<int> client_address)
        {
            log_call_with_client_address("completed_enter", client_address);
            assert(arg0 is ArgLevelObj);
            ArgLevelObj _arg0 = (ArgLevelObj)arg0;
            return identity_data.hook_mgr.completed_enter(_arg0.lvl, _arg0.obj, client_address);
        }

        public Object abort_enter(Object arg0, ArrayList<int> client_address)
        {
            log_call_with_client_address("abort_enter", client_address);
            assert(arg0 is ArgLevelObj);
            ArgLevelObj _arg0 = (ArgLevelObj)arg0;
            return identity_data.hook_mgr.abort_enter(_arg0.lvl, _arg0.obj, client_address);
        }

        void prepare_enter(Object arg0)
        {
            log_call_per_propagation("prepare_enter");
            assert(arg0 is ArgLevelObj);
            ArgLevelObj _arg0 = (ArgLevelObj)arg0;
            identity_data.hook_mgr.prepare_enter(_arg0.lvl, _arg0.obj);
        }

        void finish_enter(Object arg0)
        {
            log_call_per_propagation("finish_enter");
            assert(arg0 is ArgLevelObj);
            ArgLevelObj _arg0 = (ArgLevelObj)arg0;
            identity_data.hook_mgr.finish_enter(_arg0.lvl, _arg0.obj);
        }

        void prepare_migration(Object arg0)
        {
            log_call_per_propagation("prepare_migration");
            assert(arg0 is ArgLevelObj);
            ArgLevelObj _arg0 = (ArgLevelObj)arg0;
            identity_data.hook_mgr.prepare_migration(_arg0.lvl, _arg0.obj);
        }

        void finish_migration(Object arg0)
        {
            log_call_per_propagation("finish_migration");
            assert(arg0 is ArgLevelObj);
            ArgLevelObj _arg0 = (ArgLevelObj)arg0;
            identity_data.hook_mgr.finish_migration(_arg0.lvl, _arg0.obj);
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

        public void start_stream_system_listen(string listen_pathname, int local_identity_index)
        {
            IStreamSystemCommunicator communicator = new StreamSystemCommunicator(com_ser, local_identity_index);
            com_soc.start_stream_system_listen(listen_pathname, communicator);
        }
        public void stop_stream_system_listen(string listen_pathname)
        {
            com_soc.stop_stream_system_listen(listen_pathname);
        }
    }
}