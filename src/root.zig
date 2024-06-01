const std = @import("std");
const testing = std.testing;

const c = @cImport({
    @cInclude("nccl/net.h");
});

const name = "ZLPP";

var zcclLog: c.ncclDebugLogger_t = null;

export fn zccl_init(logger: c.ncclDebugLogger_t) c.ncclResult_t {
    zcclLog = logger;
    return c.ncclSuccess;
}

export fn zccl_devices(_ndev: [*c]c_int) c.ncclResult_t {
    const ndev: *c_int = _ndev;
    ndev.* = 1;
    return c.ncclSuccess;
}

export fn zccl_get_properties(_: c_int, _props: [*c]c.ncclNetProperties_v5_t) c.ncclResult_t {
    const props: *c.ncclNetProperties_v5_t = _props;
    props.name = @as([*c]u8, @constCast("ZLPP")); // Used mostly for logging.
    props.pciPath = null; // Path to the PCI device in /sys.
    props.guid = 0; // Unique identifier for the NIC chip. Important for
    props.ptrSupport = c.NCCL_PTR_HOST; // [NCCL_PTR_HOST|NCCL_PTR_CUDA|NCCL_PTR_DMABUF]
    props.speed = 16 * 1e3; // Port speed in Mbps.
    props.port = 0; // Port number.
    props.latency = 5; // Network latency
    props.maxComms = 256; // Maximum number of comms we can create
    props.maxRecvs = 1; // Maximum number of grouped receives.

    return c.ncclSuccess;
}

export fn zccl_listen(_: c_int, _: ?*anyopaque, _: [*c]?*anyopaque) c.ncclResult_t {
    return c.ncclSystemError;
}

export fn zccl_connect(_: c_int, _: ?*anyopaque, _: [*c]?*anyopaque) c.ncclResult_t {
    return c.ncclSystemError;
}

export fn zccl_accept(_: ?*anyopaque, _: [*c]?*anyopaque) c.ncclResult_t {
    return c.ncclSystemError;
}

export fn zccl_reg_mr(_: ?*anyopaque, _: ?*anyopaque, _: c_int, _: c_int, _: [*c]?*anyopaque) c.ncclResult_t {
    return c.ncclSystemError;
}

export fn zccl_dereg_mr(_: ?*anyopaque, _: ?*anyopaque) c.ncclResult_t {
    return c.ncclSystemError;
}

export fn zccl_isend(
    _: ?*anyopaque,
    _: ?*anyopaque,
    _: c_int,
    _: c_int,
    _: ?*anyopaque,
    _: [*c]?*anyopaque,
) c.ncclResult_t {
    return c.ncclSystemError;
}

export fn zccl_irecv(
    _: ?*anyopaque,
    _: c_int,
    _: [*c]?*anyopaque,
    _: [*c]c_int,
    _: [*c]c_int,
    _: [*c]?*anyopaque,
    _: [*c]?*anyopaque,
) c.ncclResult_t {
    return c.ncclSystemError;
}

export fn zccl_test(_: ?*anyopaque, _: [*c]c_int, _: [*c]c_int) c.ncclResult_t {
    return c.ncclSystemError;
}

export fn zccl_iflush(_: ?*anyopaque, _: c_int, _: [*c]?*anyopaque, _: [*c]c_int, _: [*c]?*anyopaque, _: [*c]?*anyopaque) c.ncclResult_t {
    return c.ncclSystemError;
}

export fn zccl_close_send(_: ?*anyopaque) c.ncclResult_t {
    return c.ncclSystemError;
}
export fn zccl_close_recv(_: ?*anyopaque) c.ncclResult_t {
    return c.ncclSystemError;
}

export fn zccl_close_listen(_: ?*anyopaque) c.ncclResult_t {
    return c.ncclSystemError;
}

comptime {
    const zcclNet_v5 = c.ncclNet_v5_t{
        .init = zccl_init,
        .devices = zccl_devices,
        .getProperties = zccl_get_properties,
        .listen = zccl_listen,
        .connect = zccl_connect,
        .accept = zccl_accept,
        .regMr = zccl_reg_mr,
        .deregMr = zccl_dereg_mr,
        .isend = zccl_isend,
        .irecv = zccl_irecv,
        .iflush = zccl_iflush,
        .gross_hack_test = zccl_test,
        .closeSend = zccl_close_send,
        .closeRecv = zccl_close_recv,
        .closeListen = zccl_close_listen,
    };

    @export(zcclNet_v5, .{ .name = "ncclNet_v5" });
}

test "basic add functionality" {
    try testing.expectEqual(c.NCCL_NET_MAX_REQUESTS, 32);
}
