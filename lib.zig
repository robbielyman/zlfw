pub const c = @import("c.zig");
const std = @import("std");

pub const InitOptions = struct {
    platform: c.Platform = .any,
    hats_as_buttons: bool = false,
    angle_platform_type: c.AnglePlatform = .none,
    cocoa_chdir_resources: bool = true,
    cocoa_menubar: bool = true,
    libdecor: c.WaylandLibdecor = .prefer,
    x11_xcb_vulkan_surface: bool = true,
    vulkan_loader: ?*const fn (?*anyopaque, [*:0]const u8) callconv(.C) ?*const fn () callconv(.C) void = null,
};

fn allocate(size: usize, user: *anyopaque) callconv(.C) ?*anyopaque {
    const ally: *std.mem.Allocator = @ptrCast(@alignCast(user));
    const bytes = @call(.auto, ally.vtable.alloc, .{ ally.ptr, size + 16, 4, @returnAddress() });
    if (bytes) |b| {
        const as_usizes: [*]usize = @ptrCast(@alignCast(b));
        as_usizes[0] = size + 16;
        return b + 16;
    }
    return null;
}

fn reallocate(ptr: *anyopaque, size: usize, user: *anyopaque) callconv(.C) ?*anyopaque {
    const ally: *std.mem.Allocator = @ptrCast(@alignCast(user));
    const bytes: [*]u8 = @as([*]u8, @ptrCast(ptr)) - 16;
    const as_usizes: [*]usize = @ptrCast(@alignCast(bytes));
    const old_size = as_usizes[0];
    const succeeded = @call(.auto, ally.vtable.resize, .{ ally.ptr, bytes[0..old_size], 4, size + 16, @returnAddress() });
    if (succeeded) {
        as_usizes[0] = size + 16;
        return bytes + 16;
    }
    deallocate(ptr, user);
    return allocate(size, user);
}

fn deallocate(ptr: *anyopaque, user: *anyopaque) callconv(.C) void {
    const ally: *std.mem.Allocator = @ptrCast(@alignCast(user));
    const bytes: [*]u8 = @as([*]u8, @ptrCast(ptr)) - 16;
    const as_usizes: [*]usize = @ptrCast(@alignCast(bytes));
    const old_size = as_usizes[0];
    @call(.auto, ally.vtable.free, .{ ally.ptr, bytes[0..old_size], 4, @returnAddress() });
}

pub fn init(opts: InitOptions, allocator: ?*const std.mem.Allocator, comptime errorFn: ?fn (c.Err, [:0]const u8) void) error{InitFailed}!void {
    c.glfwInitHint(@intFromEnum(c.InitHint.joystick_hat_buttons), if (opts.hats_as_buttons) 1 else 0);
    c.glfwInitHint(@intFromEnum(c.InitHint.angle_platform_type), @intFromEnum(opts.angle_platform_type));
    c.glfwInitHint(@intFromEnum(c.InitHint.cocoa_chdir_resources), if (opts.cocoa_chdir_resources) 1 else 0);
    c.glfwInitHint(@intFromEnum(c.InitHint.platform), @intFromEnum(opts.platform));
    c.glfwInitHint(@intFromEnum(c.InitHint.wayland_libdecor), @intFromEnum(opts.libdecor));
    c.glfwInitHint(@intFromEnum(c.InitHint.x11_xcb_vulkan_surface), if (opts.x11_xcb_vulkan_surface) 1 else 0);
    if (opts.vulkan_loader) |vl| c.glfwInitVulkanLoader(vl);
    if (allocator) |ally| {
        const a: c.Allocator = .{
            .allocate = allocate,
            .deallocate = deallocate,
            .reallocate = reallocate,
            .user = @constCast(ally),
        };
        c.glfwInitAllocator(&a);
    }
    if (errorFn) |e| {
        const inner = struct {
            fn f(err: c_int, desc: [*:0]const u8) callconv(.C) void {
                @call(.always_inline, e, .{
                    @as(c.Err, @enumFromInt(err)), std.mem.sliceTo(desc, 0),
                });
            }
        };
        _ = c.glfwSetErrorCallback(inner.f);
    }
    if (c.glfwInit() == 0) return error.InitFailed;
}

pub fn defaultErrorFn(err: c.Err, desc: [:0]const u8) void {
    std.log.scoped(.zlfw).err("error {s}, {s}", .{ @tagName(err), desc });
}

pub fn terminate() void {
    c.glfwTerminate();
}

pub const Window = opaque {
    pub const InitOptions = struct {
        resizable: bool = true,
        visible: bool = true,
        decorated: bool = true,
        focused: bool = true,
        auto_iconify: bool = true,
        floating: bool = false,
        maximized: bool = false,
        center_cursor: bool = true,
        transparent_framebuffer: bool = false,
        focus_on_show: bool = true,
        scale_to_monitor: bool = false,
        scale_framebuffer: bool = true,
        mouse_passthrough: bool = false,
        x_position: Position = .any,
        y_position: Position = .any,
        red_bits: IntOrDontCare = .{ .number = 8 },
        green_bits: IntOrDontCare = .{ .number = 8 },
        blue_bits: IntOrDontCare = .{ .number = 8 },
        alpha_bits: IntOrDontCare = .{ .number = 8 },
        depth_bits: IntOrDontCare = .{ .number = 24 },
        stencil_bits: IntOrDontCare = .{ .number = 8 },
        refresh_rate: IntOrDontCare = .dont_care,
        srgb_capable: bool = false,
        samples: IntOrDontCare = .{ .number = 0 },
        stereo: bool = false,
        double_buffer: bool = true,
        client_api: c.ClientApi = .opengl,
        context_creation_api: c.ContextCreationApi = .native,
        context_version_major: c_int = 1,
        context_version_minor: c_int = 0,
        robustness: c.Robustness = .none,
        release_behavior: c.ReleaseBehavior = .any,
        opengl_forward_compat: bool = false,
        context_debug: bool = false,
        profile: c.Profile = .any,
        win32_keyboard_menu: bool = false,
        win32_showdefault: bool = false,
        cocoa_utf8_frame_name: [:0]const u8 = "",
        cocoa_graphics_switching: bool = false,
        wayland_ascii_app_id: [:0]const u8 = "",
        x11_ascii_class_name: [:0]const u8 = "",
        x11_ascii_instance_name: [:0]const u8 = "",

        const IntOrDontCare = union(enum) {
            number: u31,
            dont_care,
        };
        const Position = union(enum) {
            any,
            coord: c_int,
        };
    };

    pub fn create(width: u31, height: u31, title: [:0]const u8, options: Window.InitOptions, monitor: ?*Monitor, share: ?*Window) ?*Window {
        const fields = @typeInfo(Window.InitOptions).Struct.fields;
        inline for (fields) |field| {
            const hint: c_int = @intFromEnum(@field(c.WindowHint, field.name));
            switch (field.type) {
                bool => c.glfwWindowHint(hint, if (@field(options, field.name)) 1 else 0),
                Window.InitOptions.IntOrDontCare => c.glfwWindowHint(hint, switch (@field(options, field.name)) {
                    .dont_care => -1,
                    .number => |n| n,
                }),
                Window.InitOptions.Position => c.glfwWindowHint(hint, switch (@field(options, field.name)) {
                    .any => c.any_position,
                    .coord => |n| n,
                }),
                c.ClientApi, c.ReleaseBehavior, c.Robustness, c.Profile, c.ContextCreationApi => c.glfwWindowHint(hint, @intFromEnum(@field(options, field.name))),
                c_int => c.glfwWindowHint(hint, @field(options, field.name)),
                [:0]const u8 => c.glfwWindowHintString(hint, @field(options, field.name).ptr),
                else => unreachable,
            }
        }
        return @ptrCast(c.glfwCreateWindow(width, height, title.ptr, monitor, share));
    }

    pub fn destroy(w: *Window) void {
        c.glfwDestroyWindow(w);
    }

    pub fn shouldClose(w: *Window) bool {
        return c.glfwWindowShouldClose(w) != 0;
    }
};

const Monitor = opaque {};

pub fn pollEvents() void {
    c.glfwPollEvents();
}

pub fn waitEvents(timeout: ?f64) void {
    if (timeout) |t| c.glfwWaitEventsTimeout(t) else c.glfwWaitEvents();
}

test "lifecycle" {
    std.testing.log_level = .debug;
    try init(.{}, &std.testing.allocator, defaultErrorFn);
    defer terminate();
    const w = Window.create(640, 480, "test window", .{}, null, null) orelse return error.WindowCreationFailed;
    defer w.destroy();
    while (!w.shouldClose()) pollEvents();
}
