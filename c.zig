pub const Err = enum(c_int) {
    no_error = 0,
    not_initialized = 0x00010001,
    no_current_context = 0x00010002,
    invalid_enum = 0x00010003,
    invalid_value = 0x00010004,
    out_of_memory = 0x00010005,
    api_unavailable = 0x00010006,
    version_unavailable = 0x00010007,
    platform_error = 0x00010008,
    format_unavailable = 0x00010009,
    no_window_context = 0x0001000a,
    cursor_unavailable = 0x0001000b,
    feature_unavailable = 0x0001000c,
    feature_unimplemented = 0x0001000d,
    platform_unavailable = 0x0001000e,
};

pub const InitHint = enum(c_int) {
    joystick_hat_buttons = 0x00050001,
    angle_platform_type = 0x00050002,
    platform = 0x00050003,
    cocoa_chdir_resources = 0x00051001,
    x11_xcb_vulkan_surface = 0x00052001,
    wayland_libdecor = 0x00053001,
};

pub const Platform = enum(c_int) {
    any = 0x00060000,
    win32 = 0x00060001,
    cocoa = 0x00060002,
    wayland = 0x00060003,
    x11 = 0x00060004,
    null_platform = 0x00060005,
};

pub const AnglePlatform = enum(c_int) {
    none = 0x00037001,
    opengl = 0x00037002,
    opengles = 0x00037003,
    d3d9 = 0x00037004,
    d3d11 = 0x00037005,
    vulkan = 0x00037007,
    metal = 0x00037008,
};

pub const WaylandLibdecor = enum(c_int) {
    prefer = 0x00038011,
    disable = 0x00038002,
};

pub const ClientApi = enum(c_int) {
    none = 0,
    opengl = 0x00030001,
    ogengl_es = 0x00030002,
};

pub const Robustness = enum(c_int) {
    none = 0,
    no_reset_notification = 0x00031001,
    lose_context_on_reset = 0x00031002,
};

pub const Profile = enum(c_int) {
    any = 0,
    core = 0x00032001,
    compat = 0x00031002,
};

pub const ReleaseBehavior = enum(c_int) {
    any = 0,
    flush = 0x00035001,
    none = 0x00035002,
};

pub const ContextCreationApi = enum(c_int) {
    native = 0x00036001,
    egl = 0x00036002,
    osmesa = 0x00036003,
};

pub const Allocator = extern struct {
    allocate: *const fn (usize, *anyopaque) callconv(.C) ?*anyopaque,
    reallocate: *const fn (*anyopaque, usize, *anyopaque) callconv(.C) ?*anyopaque,
    deallocate: *const fn (*anyopaque, *anyopaque) callconv(.C) void,
    user: *anyopaque,
};

pub const any_position: c_int = @bitCast(@as(u32, 0x80000000));

pub const WindowHint = enum(c_int) {
    focused = 0x00020001,
    iconified = 0x00020002,
    resizable = 0x00020003,
    visible = 0x00020004,
    decorated = 0x00020005,
    auto_iconify = 0x00020006,
    floating = 0x00020007,
    maximized = 0x00020008,
    center_cursor = 0x00020009,
    transparent_framebuffer = 0x0002000a,
    focus_on_show = 0x0002000c,
    mouse_passthrough = 0x0002000d,
    x_position = 0x0002000e,
    y_position = 0x0002000f,
    red_bits = 0x00021001,
    green_bits = 0x00021002,
    blue_bits = 0x00021003,
    alpha_bits = 0x00021004,
    depth_bits = 0x00021005,
    stencil_bits = 0x00021006,
    stereo = 0x0002100c,
    samples = 0x0002100d,
    srgb_capable = 0x0002100e,
    refresh_rate = 0x0002100f,
    double_buffer = 0x00021010,
    client_api = 0x00022001,
    context_version_major = 0x00022002,
    context_version_minor = 0x00022003,
    robustness = 0x00022005,
    opengl_forward_compat = 0x00022006,
    context_debug = 0x00022007,
    profile = 0x00022008,
    release_behavior = 0x00022009,
    context_creation_api = 0x0002200b,
    scale_to_monitor = 0x0002200c,
    scale_framebuffer = 0x0002200d,
    cocoa_utf8_frame_name = 0x00023002,
    cocoa_graphics_switching = 0x00023003,
    x11_ascii_class_name = 0x00024001,
    x11_ascii_instance_name = 0x00024002,
    win32_keyboard_menu = 0x00025001,
    win32_showdefault = 0x00025002,
    wayland_ascii_app_id = 0x00026001,
};

pub extern "c" fn glfwInit() c_int;
pub extern "c" fn glfwTerminate() void;
pub extern "c" fn glfwInitHint(hint: c_int, val: c_int) void;
pub extern "c" fn glfwInitAllocator(allocator: *const Allocator) void;
pub extern "c" fn glfwInitVulkanLoader(?*const fn (?*anyopaque, [*:0]const u8) callconv(.C) ?*const fn () callconv(.C) void) void;
pub extern "c" fn glfwSetErrorCallback(*const fn (c_int, [*:0]const u8) callconv(.C) void) ?*const fn (c_int, [*:0]const u8) callconv(.C) void;

pub extern "c" fn glfwWindowHint(c_int, c_int) void;
pub extern "c" fn glfwWindowHintString(c_int, [*:0]const u8) void;
pub extern "c" fn glfwCreateWindow(c_int, c_int, [*:0]const u8, ?*anyopaque, ?*anyopaque) ?*anyopaque;
pub extern "c" fn glfwDestroyWindow(?*anyopaque) void;
pub extern "c" fn glfwWindowShouldClose(?*anyopaque) c_int;

pub extern "c" fn glfwPollEvents() void;
pub extern "c" fn glfwWaitEvents() void;
pub extern "c" fn glfwWaitEventsTimeout(f64) void;
