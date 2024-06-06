const std = @import("std");
const znet = @import("zccl_net.zig");
const cstub = @import("cstub.zig");
const nccl = cstub.nccl;

export fn zccl_init(logger: nccl.ncclDebugLogger_t) nccl.ncclResult_t {
    cstub.set_zccl_log(logger);
    cstub.debug("Logging initialized", .{}) catch return nccl.ncclSystemError;
    return nccl.ncclSuccess;
}

export fn zccl_devices(_ndev: [*c]c_int) nccl.ncclResult_t {
    const ndev: *c_int = _ndev;
    ndev.* = 1;

    cstub.debug("Num devices queries (found: {})", .{ndev.*}) catch return nccl.ncclSystemError;

    return nccl.ncclSuccess;
}

export fn zccl_get_properties(dev: c_int, _props: [*c]nccl.ncclNetProperties_v5_t) nccl.ncclResult_t {
    const props: *nccl.ncclNetProperties_v5_t = _props;
    props.name = @constCast("BKZCCL"); // Used mostly for logging.
    props.pciPath = null; // Path to the PCI device in /sys.
    props.guid = 0; // Unique identifier for the NIC chip. Important for
    props.ptrSupport = nccl.NCCL_PTR_HOST; // [NCCL_PTR_HOST|NCCL_PTR_CUDA|NCCL_PTR_DMABUF]
    props.speed = 16 * 1e3; // Port speed in Mbps.
    props.port = 0; // Port number.
    props.latency = 5; // Network latency
    props.maxComms = 256; // Maximum number of comms we can create
    props.maxRecvs = 1; // Maximum number of grouped receives.

    cstub.debug("Properties Initialized (dev: {})", .{dev}) catch return nccl.ncclSystemError;
    return nccl.ncclSuccess;
}

comptime {
    const zcclNet_v5 = nccl.ncclNet_v5_t{
        .name = "bkzccl-net",
        .init = zccl_init,
        .devices = zccl_devices,
        .getProperties = zccl_get_properties,
        .listen = znet.zccl_listen,
        .connect = znet.zccl_connect,
        .accept = znet.zccl_accept,
        .regMr = znet.zccl_reg_mr,
        .deregMr = znet.zccl_dereg_mr,
        .isend = znet.zccl_isend,
        .irecv = znet.zccl_irecv,
        .iflush = znet.zccl_iflush,
        .gross_hack_test = znet.zccl_test,
        .closeSend = znet.zccl_close_send,
        .closeRecv = znet.zccl_close_recv,
        .closeListen = znet.zccl_close_listen,
    };

    @export(zcclNet_v5, .{ .name = "ncclNetPlugin_v5" });
}
