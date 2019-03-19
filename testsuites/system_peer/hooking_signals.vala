using Gee;
using Netsukuku;
using Netsukuku.Hooking;
using TaskletSystem;

namespace SystemPeer
{
    void per_identity_hooking_same_network(IdentityData id, IIdentityArc _ia)
    {
        IdentityArc ia = ((HookingIdentityArc)_ia).ia;
        NodeID peer_nodeid = ia.peer_nodeid;
        PseudoArc pseudoarc = ia.arc;
        int arc_num = -1;
        for (int i = 0; i < arc_list.size; i++)
        {
            PseudoArc _pseudoarc = arc_list[i];
            if (_pseudoarc == pseudoarc)
            {
                arc_num = i;
                break;
            }
        }
        assert(arc_num >= 0);
        int peer_id = -1;
        for (int i = 0; i < 10; i++)
        {
            NodeID _peer_nodeid = fake_random_nodeid(pseudoarc.peer_pid, i);
            if (_peer_nodeid.equals(peer_nodeid))
            {
                peer_id = i;
                break;
            }
        }
        assert(peer_id >= 0);
        string descr = @"$(arc_num)+$(peer_id)";
        print(@"INFO: Identity #$(id.local_identity_index): arc $(descr) signal same_network.\n");
        tester_events.add(@"HookingManager:$(id.local_identity_index):Signal:same_network:$(descr)");
    }

    void per_identity_hooking_another_network(IdentityData id, IIdentityArc _ia, int64 network_id)
    {
        IdentityArc ia = ((HookingIdentityArc)_ia).ia;
        NodeID peer_nodeid = ia.peer_nodeid;
        PseudoArc pseudoarc = ia.arc;
        int arc_num = -1;
        for (int i = 0; i < arc_list.size; i++)
        {
            PseudoArc _pseudoarc = arc_list[i];
            if (_pseudoarc == pseudoarc)
            {
                arc_num = i;
                break;
            }
        }
        assert(arc_num >= 0);
        int peer_id = -1;
        for (int i = 0; i < 10; i++)
        {
            NodeID _peer_nodeid = fake_random_nodeid(pseudoarc.peer_pid, i);
            if (_peer_nodeid.equals(peer_nodeid))
            {
                peer_id = i;
                break;
            }
        }
        assert(peer_id >= 0);
        string descr = @"$(arc_num)+$(peer_id)";
        print(@"INFO: Identity #$(id.local_identity_index): arc $(descr) signal another_network: $(network_id).\n");
        tester_events.add(@"HookingManager:$(id.local_identity_index):Signal:another_network:$(descr),$(network_id)");
    }

    void per_identity_hooking_do_prepare_enter(IdentityData id, int enter_id)
    {
        error("not implemented yet");
    }

    void per_identity_hooking_do_finish_enter(IdentityData id,
        int enter_id, int guest_gnode_level, EntryData entry_data, int go_connectivity_position)
    {
        error("not implemented yet");
    }

    void per_identity_hooking_do_prepare_migration(IdentityData id, int migration_id)
    {
        error("not implemented yet");
    }

    void per_identity_hooking_do_finish_migration(IdentityData id,
        int migration_id, int guest_gnode_level, EntryData migration_data, int go_connectivity_position)
    {
        error("not implemented yet");
    }

    void per_identity_hooking_failing_arc(IdentityData id, IIdentityArc _ia)
    {
        error("not implemented yet");
    }
}