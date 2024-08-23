const std = @import("std");

const logger = @import("logger.zig").init(.{});

const Context = @import("context.zig");
const Request = @import("request.zig");
const Response = @import("response.zig");
const Handler = @import("handler.zig");
const Middleware = @import("middleware.zig");
const HandlerFn = Handler.HandlerFn;
const HandlerChain = Handler.Chain;

pub const Route = @This();
const Self = @This();

methods: []const std.http.Method = &.{
    .GET,
    .POST,
    .PUT,
    .DELETE,
    .PATCH,
    .OPTIONS,
    .HEAD,
    .CONNECT,
    .TRACE,
},

path: []const u8 = "*",

handler: Handler.HandlerFn = undefined,

pub fn init(self: Self) Route {
    return .{
        .methods = self.methods,
        .path = self.path,
        .handler = self.handler,
    };
}

pub const RouteError = error{
    None,

    // 404 Not Found
    NotFound,
    // 405 Method Not Allowed
    MethodNotAllowed,
};

pub fn match(self: *Route, method: std.http.Method, path: []const u8) anyerror!*Route {
    if (self.isPathMatch(path)) {
        if (self.isMethodAllowed(method)) {
            return self;
        }
        // found route but method not allowed
        return RouteError.MethodNotAllowed;
    }

    return RouteError.NotFound;
}

pub fn get(path: []const u8, handler: anytype) Route {
    return init(.{ .methods = &.{.GET}, .path = path, .handler = handler });
}

pub fn post(path: []const u8, handler: anytype) Route {
    return init(.{ .methods = &.{.POST}, .path = path, .handler = handler });
}
pub fn put(path: []const u8, handler: anytype) Route {
    return init(.{ .methods = &.{.PUT}, .path = path, .handler = handler });
}
pub fn delete(path: []const u8, handler: anytype) Route {
    return init(.{ .methods = &.{.DELETE}, .path = path, .handler = handler });
}
pub fn patch(path: []const u8, handler: anytype) Route {
    return init(.{ .methods = &.{.PATCH}, .path = path, .handler = handler });
}
pub fn options(path: []const u8, handler: anytype) Route {
    return init(.{ .methods = &.{.OPTIONS}, .path = path, .handler = handler });
}
pub fn head(path: []const u8, handler: anytype) Route {
    return init(.{ .methods = &.{.HEAD}, .path = path, .handler = handler });
}
pub fn connect(path: []const u8, handler: anytype) Route {
    return init(.{ .methods = &.{.CONNECT}, .path = path, .handler = handler });
}
pub fn trace(path: []const u8, handler: anytype) Route {
    return init(.{ .methods = &.{.TRACE}, .path = path, .handler = handler });
}

pub fn getPath(self: *Route) []const u8 {
    return self.path;
}

pub fn getHandler(self: *Route) Handler.HandlerFn {
    return &self.handler;
}

pub fn handle(self: *Route, ctx: *Context) anyerror!void {
    // return try self.handler(ctx, req, res);
    return try self.handler(ctx);
}

pub fn isMethodAllowed(self: *Route, method: std.http.Method) bool {
    for (self.methods) |m| {
        if (m == method) {
            return true;
        }
    }

    return false;
}

pub fn isPathMatch(self: *Route, path: []const u8) bool {
    if (std.ascii.eqlIgnoreCase(self.path, "*")) {
        return true;
    }
    return std.ascii.eqlIgnoreCase(self.path, path);
}

pub fn isStaticRoute(self: *Route, target: []const u8) bool {
    if (std.ascii.eqlIgnoreCase(self.path, "*")) {
        return true;
    }

    // not server root
    if (std.mem.eql(u8, target, "/") or std.mem.eql(u8, self.path, "") or std.mem.eql(u8, self.path, "/")) {
        return false;
    }

    var targets = std.mem.splitSequence(u8, target, "/");
    var ps = std.mem.splitSequence(u8, self.path, "/");

    _ = targets.first();
    _ = ps.first();

    while (true) {
        const t = targets.next().?;
        const pp = ps.next().?;
        if (std.ascii.eqlIgnoreCase(t, "") or std.ascii.eqlIgnoreCase(pp, "")) {
            break;
        }

        if (std.ascii.eqlIgnoreCase(t, pp)) {
            return true;
        }
        return false;
    }

    return std.ascii.eqlIgnoreCase(self.path, target);
}

pub fn isMatch(self: *Route, method: std.http.Method, path: []const u8) bool {
    if (self.isPathMatch(path) and self.isMethodAllowed(method)) {
        return true;
    }

    return false;
}

pub fn use(self: *Route, middleware: Middleware) anyerror!void {
    _ = middleware;
    _ = self;
}
