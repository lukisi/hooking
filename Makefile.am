NULL = 
ACLOCAL_AMFLAGS = -I m4
.PHONY: check

noinst_LTLIBRARIES = \
	libhooking.la \
	$(NULL)

TESTS = \
	test_serializables \
	two_nodes_meet \
	two_gnodes_meet \
	graph1 \
	$(NULL)

# manually check scripts: first, second

check_PROGRAMS = \
	test_serializables \
	system_peer \
	$(NULL)

libhooking_la_SOURCES = \
	hooking.vala \
	api.vala \
	rngen.vala \
	serializables.vala \
	message_routing.vala \
	arc_handler.vala \
	proxy_coord.vala \
	propagation_coord.vala \
	structs.vala \
	$(NULL)

libhooking_la_VALAFLAGS = \
	-H hooking.h \
	--library hooking \
	--vapidir $(GEE_PREFIX)/share/vala/vapi \
	--vapidir $(JSON_PREFIX)/share/vala-0.36/vapi \
	--vapidir $(TASKLETSYSTEM_VAPIDIR) \
	--vapidir $(NTKDCOMMON_VAPIDIR) \
	--vapidir $(NTKDRPC_VAPIDIR) \
	--pkg gee-0.8 \
	--pkg json-glib-1.0 \
	--pkg tasklet-system \
	--pkg ntkd-common \
	--pkg ntkdrpc\
	$(NULL)

libhooking_la_CPPFLAGS = \
	-w \
	$(GOBJECT_CFLAGS) \
	$(GEE_CFLAGS) \
	$(JSONGLIB_CFLAGS) \
	$(TASKLETSYSTEM_CFLAGS) \
	$(NTKDCOMMON_CFLAGS) \
	$(NTKDRPC_CFLAGS) \
	$(NULL)

libhooking_la_LIBADD = \
	$(GOBJECT_LIBS) \
	$(GEE_LIBS) \
	$(JSONGLIB_LIBS) \
	$(TASKLETSYSTEM_LIBS) \
	$(NTKDCOMMON_LIBS) \
	$(NTKDRPC_LIBS) \
	$(NULL)

test_serializables_SOURCES =  \
	testsuites/test_serializables/test_serializables.vala \
	testsuites/test_serializables/serializables.vala \
	$(NULL)

test_serializables_VALAFLAGS = \
	--vapidir $(GEE_PREFIX)/share/vala/vapi \
	--vapidir $(JSON_PREFIX)/share/vala-0.36/vapi \
	--pkg gee-0.8 \
	--pkg json-glib-1.0 \
	$(NULL)

test_serializables_CPPFLAGS = \
	-w \
	$(GOBJECT_CFLAGS) \
	$(GEE_CFLAGS) \
	$(JSONGLIB_CFLAGS) \
	$(NULL)

test_serializables_LDADD = \
	$(GOBJECT_LIBS) \
	$(GEE_LIBS) \
	$(JSONGLIB_LIBS) \
	$(NULL)

system_peer_SOURCES =  \
	testsuites/system_peer/system_peer.vala \
	testsuites/system_peer/rpc/module_stubs.vala \
	testsuites/system_peer/rpc/skeleton_factory.vala \
	testsuites/system_peer/rpc/stub_factory.vala \
	testsuites/system_peer/serializables.vala \
	testsuites/system_peer/rngen.vala \
	testsuites/system_peer/hooking_helpers.vala \
	testsuites/system_peer/hooking_signals.vala \
	testsuites/system_peer/comm_local_socket.vala \
	testsuites/system_peer/comm_serialization.vala \
	testsuites/system_peer/comm_skeleton_factory.vala \
	testsuites/system_peer/comm_stub_factory.vala \
	testsuites/system_peer/task_addtag.vala \
	testsuites/system_peer/task_identities.vala \
	testsuites/system_peer/task_identity_data.vala \
	testsuites/system_peer/task_coord_data.vala \
	testsuites/system_peer/task_modules.vala \
	testsuites/system_peer/task_gateways.vala \
	testsuites/system_peer/task_check_two_nodes_meet.vala \
	testsuites/system_peer/task_check_two_gnodes_meet.vala \
	testsuites/system_peer/task_check_graph1.vala \
	hooking.vapi \
	$(NULL)

system_peer_VALAFLAGS = \
	--vapidir $(GEE_PREFIX)/share/vala/vapi \
	--vapidir $(JSON_PREFIX)/share/vala-0.36/vapi \
	--vapidir $(TASKLETSYSTEM_VAPIDIR) \
	--vapidir $(PTHTASKLET_VAPIDIR) \
	--vapidir $(NTKDCOMMON_VAPIDIR) \
	--vapidir $(NTKDRPC_VAPIDIR) \
	--pkg gee-0.8 \
	--pkg json-glib-1.0 \
	--pkg ntkd-common \
	--pkg tasklet-system \
	--pkg pth-tasklet \
	--pkg ntkdrpc \
	$(NULL)

system_peer_CPPFLAGS = \
	-w \
	$(GOBJECT_CFLAGS) \
	$(GEE_CFLAGS) \
	$(JSONGLIB_CFLAGS) \
	$(NTKDCOMMON_CFLAGS) \
	$(TASKLETSYSTEM_CFLAGS) \
	$(PTHTASKLET_CFLAGS) \
	$(NTKDRPC_CFLAGS) \
	$(NULL)

system_peer_LDADD = \
	$(GOBJECT_LIBS) \
	$(GEE_LIBS) \
	$(JSONGLIB_LIBS) \
	$(NTKDCOMMON_LIBS) \
	$(TASKLETSYSTEM_LIBS) \
	$(PTHTASKLET_LIBS) \
	$(NTKDRPC_LIBS) \
	$(builddir)/libhooking.la \
	$(NULL)

MAINTAINERCLEANFILES = \
	$(srcdir)/hooking.vapi \
	$(NULL)

hooking.vapi: libhooking_la_vala.stamp
	$(NULL)

