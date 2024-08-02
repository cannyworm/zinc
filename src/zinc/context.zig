const std = @import("std");

const RespondOptions = std.http.Server.Request.RespondOptions;

const Request = @import("request.zig").Request;
const Response = @import("response.zig").Response;
const Config = @import("config.zig").Config;

pub const Context = @This();
const Self = @This();

request: *Request,
response: *Response,

pub fn init(
    req: *Request,
    res: *Response,
) Context {
    return Context{
        .request = req,
        .response = res,
    };
}

pub fn HTML(self: *Self, conf: Config.Context, content: []const u8) anyerror!void {
    try self.response.send(content, .{
        .status = conf.status,
        .extra_headers = &[_]std.http.Header{
            .{ .name = "Content-Type", .value = "text/html" },
        },
        .keep_alive = false,
    });
}

pub fn Text(self: *Self, conf: Config.Context, content: []const u8) anyerror!void {
    try self.response.send(content, .{
        .status = conf.status,
        .extra_headers = &[_]std.http.Header{
            .{ .name = "Content-Type", .value = "text/plain" },
        },
        .keep_alive = false,
    });
}

pub fn JSON(self: *Self, conf: Config.Context, value: anytype) anyerror!void {
    var buf: [100]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buf);
    var string = std.ArrayList(u8).init(fba.allocator());
    try std.json.stringify(value, .{}, string.writer());

    try self.response.send(string.items, .{
        .status = conf.status,
        .extra_headers = &[_]std.http.Header{
            .{ .name = "Content-Type", .value = "application/json" },
        },
        .keep_alive = false,
    });
}
