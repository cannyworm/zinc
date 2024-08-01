const std = @import("std");
const print = std.debug.print;

const HandlerFn = @import("handler.zig").HandlerFn;
const HandleAction = @import("handler.zig").HandleAction;
const Context = @import("context.zig").Context;
const Request = @import("request.zig").Request;
const Response = @import("response.zig").Response;
const Route = @import("route.zig");

pub const Router = @This();
const Self = @This();

// fn arena_allocator() std.heap.Allocator {
//     var gpa = std.heap.GeneralPurposeAllocator(.{}){};
//     const gpa_allocator = gpa.allocator();
//     const arena = std.heap.ArenaAllocator.init(gpa_allocator);

//     defer {
//         const deinit_status = gpa.deinit();
//         if (deinit_status == .leak) @panic("Memory leak!");
//         defer arena.deinit();
//     }

//     const allocator = arena.allocator();
//     return allocator;
// }

routes: std.ArrayList(Route),

pub fn init() Router {
    return Router{
        // Todo, use arena allocator
        .routes = std.ArrayList(Route).init(std.heap.page_allocator),
    };
}

/// Return routes.
pub fn getRoutes(self: *Self) std.ArrayList(Route) {
    return self.routes;
}

pub fn add(self: *Self, http_method: std.http.Method, comptime path: []const u8, comptime handler: anytype) anyerror!void {
    try self.routes.append(Route{
        .http_method = http_method,
        .path = path,
        .handler = handler,
    });
}
pub fn get(self: *Self, comptime path: []const u8, comptime handler: anytype) anyerror!void {
    try self.routes.append(Route.get(path, handler));
}
pub fn post(self: *Self, comptime path: []const u8, comptime handler: anytype) anyerror!void {
    try self.routes.append(Route.post(path, handler));
}
pub fn put(self: *Self, comptime path: []const u8, comptime handler: anytype) anyerror!void {
    try self.routes.append(Route.put(path, handler));
}
pub fn delete(self: *Self, comptime path: []const u8, comptime handler: anytype) anyerror!void {
    try self.routes.append(Route.delete(path, handler));
}
pub fn patch(self: *Self, comptime path: []const u8, comptime handler: anytype) anyerror!void {
    try self.routes.append(Route.patch(path, handler));
}
pub fn options(self: *Self, comptime path: []const u8, comptime handler: anytype) anyerror!void {
    try self.routes.append(Route.options(path, handler));
}
pub fn head(self: *Self, comptime path: []const u8, comptime handler: anytype) anyerror!void {
    try self.routes.append(Route.head(path, handler));
}
pub fn connect(self: *Self, comptime path: []const u8, comptime handler: anytype) anyerror!void {
    try self.routes.append(Route.connect(path, handler));
}
pub fn trace(self: *Self, comptime path: []const u8, comptime handler: anytype) anyerror!void {
    try self.routes.append(Route.trace(path, handler));
}

pub fn addRoute(self: *Self, route: Route) anyerror!void {
    try self.routes.append(route);
}
