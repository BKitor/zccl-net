const std = @import("std");
const cstub = @import("cstub.zig");
const nccl = cstub.nccl;
const fi = cstub.fi;

const zccl_port: u16 = 9574;
const zccl_port_str = "9574";

const lcomm_t = struct {
    p_addr: std.net.Address,
    s_addr: std.net.Address,
    server: std.net.Server,
};

fn sockaddr_to_address(soca: std.c.sockaddr) !std.net.Address {
    const bufsize = 32;
    var _buf: [bufsize]u8 = undefined;

    const buf = try std.fmt.bufPrint(&_buf, "{}.{}.{}.{}", .{
        soca.data[2], soca.data[3],
        soca.data[4], soca.data[5],
    });

    return try std.net.Address.resolveIp(buf, zccl_port);
    // return try std.net.Address.parseIp4(buf, zccl_port);
}

fn get_local_adress() !std.net.Address {
    var ret_soc: ?std.c.sockaddr = null;
    var ifas: ?*cstub.ifaddrs = null;
    _ = cstub.getifaddrs(&ifas);
    if (ifas) |ifs| {
        defer cstub.freeifaddrs(ifs);
    } else {
        return error.noDev;
    }
    var tmp = ifas;
    while (tmp) |a| {
        tmp = a.next;
        const soca = a.addr orelse continue;
        const name = a.name orelse continue;
        if (soca.family != std.c.AF.INET)
            continue;
        if (std.mem.eql(u8, std.mem.span(name), "eno1")) {
            ret_soc = soca.*;
            break;
        }
    }
    if (ret_soc) |soca| {
        return try sockaddr_to_address(soca);
    } else {
        return error.noDev;
    }
}

pub export fn zccl_listen(dev: c_int, _handle: ?*anyopaque, _listen_comm: [*c]?*anyopaque) nccl.ncclResult_t {
    cstub.debug("Listen Called (dev: {}), MAX_HANDLE_SIZE:{}", .{ dev, nccl.NCCL_NET_HANDLE_MAXSIZE }) catch return nccl.ncclSystemError;
    const ca = std.heap.c_allocator;

    const lcomm = ca.create(lcomm_t) catch {
        std.debug.print("memory allocation failed", .{});
        return nccl.ncclSystemError;
    };

    lcomm.s_addr = std.net.Address.resolveIp("0.0.0.0", zccl_port) catch {
        std.debug.print("Fialed to resolve IP", .{});
        return nccl.ncclSystemError;
    };

    lcomm.server = lcomm.s_addr.listen(.{
        .reuse_port = true,
        .reuse_address = true,
        .force_nonblocking = true,
    }) catch {
        std.debug.print("Fialed to init server", .{});
        return nccl.ncclSystemError;
    };
    defer lcomm.server.deinit();

    lcomm.p_addr = get_local_adress() catch return nccl.ncclSystemError;

    cstub.debug("Server stook up: listen:{} serve:{}", .{ lcomm.s_addr, lcomm.p_addr }) catch return nccl.ncclSystemError;

    const ret_lcomm: **lcomm_t = @ptrCast(_listen_comm);
    ret_lcomm.* = lcomm;
    const ret_handle: *std.net.Address = @alignCast(@ptrCast(_handle));
    ret_handle.* = lcomm.p_addr;

    return nccl.ncclSuccess;
}

pub export fn zccl_connect(dev: c_int, _handle: ?*anyopaque, _: [*c]?*anyopaque) nccl.ncclResult_t {
    const addr: *std.net.Address = @alignCast(@ptrCast(_handle));

    cstub.debug("Connect called (dev: {}) Address: {}", .{ dev, addr.* }) catch return nccl.ncclSystemError;

    const send_stream = std.net.tcpConnectToAddress(addr.*) catch return nccl.ncclSystemError;

    _ = send_stream;

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
