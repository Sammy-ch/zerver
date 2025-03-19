const std = @import("std");
const stdout = std.io.getStdOut().writer();
const SocketConf = @import("config.zig");
const Request = @import("request.zig");
const Response = @import("response.zig");

pub fn main() !void {
    const socket = try SocketConf.Socket.init();
    try stdout.print("Server Addr: {any}\n", .{socket._address});
    var server = try socket._address.listen(.{});
    var buffer: [1000]u8 = undefined;

    for (0..buffer.len) |i| {
        buffer[i] = 0;
    }
    while (true) {
        const connection = try server.accept();

        try Request.read_request(connection, buffer[0..buffer.len]);

        const request = Request.parse_request(buffer[0..buffer.len]);
        try stdout.print("{any}\n", .{request});

        if (request.method == Request.Method.GET) {
            if (std.mem.eql(u8, request.uri, "/")) {
                try Response.send_200(connection);
            } else {
                try Response.send_404(connection);
            }
        }
    }
}
