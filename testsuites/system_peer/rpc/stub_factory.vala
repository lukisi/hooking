using Gee;
using Netsukuku;
using Netsukuku.Hooking;
using TaskletSystem;

namespace SystemPeer
{
    class StubFactory : Object
    {
        public StubFactory()
        {
        }

        public IAddressManagerStub
        get_stub_identity_aware_unicast(
            /*INeighborhoodArc arc*/ string my_dev, string send_pathname,
            IdentityData identity_data,
            NodeID unicast_node_id,
            bool wait_reply=true)
        {
            NodeID source_node_id = identity_data.nodeid;
            IdentityAwareSourceID source_id = new IdentityAwareSourceID(source_node_id);
            IdentityAwareUnicastID unicast_id = new IdentityAwareUnicastID(unicast_node_id);
            string my_dev_mac = fake_random_mac(pid, my_dev);
            NeighbourSrcNic src_nic = new NeighbourSrcNic(my_dev_mac);
            return get_addr_stream_system(send_pathname, source_id, unicast_id, src_nic, wait_reply);
        }

        public IAddressManagerStub
        get_stub_identity_aware_unicast_from_ia(IdentityArc ia, bool wait_reply=true)
        {
            string my_dev = ia.arc.my_nic.dev;
            string send_pathname = @"conn_$(ia.arc.peer_linklocal)";
            IdentityData identity_data = ia.identity_data;
            NodeID unicast_node_id = ia.peer_nodeid;
            return get_stub_identity_aware_unicast(my_dev, send_pathname, identity_data, unicast_node_id, wait_reply);
        }
    }
}
