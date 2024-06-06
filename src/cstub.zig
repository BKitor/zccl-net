const std = @import("std");

pub const nccl = @cImport({
    @cInclude("nccl/net.h");
});

// pub const fi = @cImport({
//     @cInclude("rdma/fabric.h");
// });

pub const ifaddrs = extern struct {
    next: ?*ifaddrs,
    name: ?[*:0]u8,
    flags: u32,
    addr: ?*std.c.sockaddr,
    netmaks: ?*std.c.sockaddr,
    ifu: extern union { broadaddr: ?*std.c.sockaddr, dstaddr: ?*std.c.sockaddr },
    data: ?*anyopaque,
};

pub extern "c" fn getifaddrs(ifap: *?*ifaddrs) c_int;
pub extern "c" fn freeifaddrs(ifap: *ifaddrs) void;

const _NCCL_ALL = ~@as(c_ulong, 0);

var zccl_log: nccl.ncclDebugLogger_t = null;

pub fn set_zccl_log(logger: nccl.ncclDebugLogger_t) void {
    zccl_log = logger;
}

fn out(level: c_uint, flags: c_ulong, comptime fmt: []const u8, args: anytype) !void {
    const ca = std.heap.c_allocator;
    const __msg = try std.fmt.allocPrint(ca, fmt, args);
    defer ca.free(__msg);

    const _msg = try std.fmt.allocPrint(ca, "{s} ", .{__msg});
    defer ca.free(_msg);

    _msg[_msg.len - 1] = 0;
    const msg: [*c]const u8 = @ptrCast(_msg);
    zccl_log.?(level, flags, "makecomptime.zig", 69420, "ZCCL-NET %s", msg);
}

pub fn debug(comptime fmt: [:0]const u8, args: anytype) !void {
    try out(nccl.NCCL_LOG_INFO, _NCCL_ALL, fmt, args);
}

pub fn warn(comptime fmt: []const u8, args: anytype) !void {
    try out(nccl.NCCL_LOG_WARN, _NCCL_ALL, fmt, args);
}
