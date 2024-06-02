const std = @import("std");

pub const nccl = @cImport({
    @cInclude("nccl/net.h");
});

var zccl_log: nccl.ncclDebugLogger_t = null;

pub fn set_zccl_log(logger: nccl.ncclDebugLogger_t) void {
    zccl_log = logger;
}

fn out(level: u32, flags: u64, comptime fmt: []const u8, args: anytype) !void {
    const ca = std.heap.c_allocator;
    const _msg = try std.fmt.allocPrint(ca, fmt, args);
    defer ca.free(_msg);
    const msg = try std.fmt.allocPrint(ca, "ZCCL-NET {s}", .{fmt});
    defer ca.free(msg);
    zccl_log.?(level, flags, "todo.zig", 69420, @ptrCast(msg));
}

pub fn debug(comptime fmt: []const u8, args: anytype) !void {
    const _NCCL_ALL = ~@as(c_ulong, 0);
    try out(nccl.NCCL_LOG_INFO, _NCCL_ALL, fmt, args);
}

pub fn warn(comptime fmt: []const u8, args: anytype) !void {
    const _NCCL_ALL = ~@as(c_ulong, 0);
    try out(nccl.NCCL_LOG_WARN, _NCCL_ALL, fmt, args);
}

pub export fn zccl_listen(_: c_int, _: ?*anyopaque, _: [*c]?*anyopaque) nccl.ncclResult_t {
    nccl.NCCL_NET_HANDLE_MAX_SIZE;

    return nccl.ncclSystemError;
}

pub export fn zccl_connect(_: c_int, _: ?*anyopaque, _: [*c]?*anyopaque) nccl.ncclResult_t {
    return nccl.ncclSystemError;
}

pub export fn zccl_accept(_: ?*anyopaque, _: [*c]?*anyopaque) nccl.ncclResult_t {
    return nccl.ncclSystemError;
}

pub export fn zccl_reg_mr(_: ?*anyopaque, _: ?*anyopaque, _: c_int, _: c_int, _: [*c]?*anyopaque) nccl.ncclResult_t {
    return nccl.ncclSystemError;
}

pub export fn zccl_dereg_mr(_: ?*anyopaque, _: ?*anyopaque) nccl.ncclResult_t {
    return nccl.ncclSystemError;
}

pub export fn zccl_isend(
    _: ?*anyopaque,
    _: ?*anyopaque,
    _: c_int,
    _: c_int,
    _: ?*anyopaque,
    _: [*c]?*anyopaque,
) nccl.ncclResult_t {
    return nccl.ncclSystemError;
}

pub export fn zccl_irecv(
    _: ?*anyopaque,
    _: c_int,
    _: [*c]?*anyopaque,
    _: [*c]c_int,
    _: [*c]c_int,
    _: [*c]?*anyopaque,
    _: [*c]?*anyopaque,
) nccl.ncclResult_t {
    return nccl.ncclSystemError;
}

pub export fn zccl_iflush(_: ?*anyopaque, _: c_int, _: [*c]?*anyopaque, _: [*c]c_int, _: [*c]?*anyopaque, _: [*c]?*anyopaque) nccl.ncclResult_t {
    return nccl.ncclSystemError;
}

pub export fn zccl_test(_: ?*anyopaque, _: [*c]c_int, _: [*c]c_int) nccl.ncclResult_t {
    return nccl.ncclSystemError;
}

pub export fn zccl_close_send(_: ?*anyopaque) nccl.ncclResult_t {
    return nccl.ncclSystemError;
}
pub export fn zccl_close_recv(_: ?*anyopaque) nccl.ncclResult_t {
    return nccl.ncclSystemError;
}

pub export fn zccl_close_listen(_: ?*anyopaque) nccl.ncclResult_t {
    return nccl.ncclSystemError;
}
