const std = @import("std");
const vkgen = @import("vulkan-zig");
const ShaderCompileStep = vkgen.ShaderCompileStep;

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    // const static = b.option(bool, "static", "build a static GLFW") orelse false;

    const module = b.addModule("zlfw", .{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("lib.zig"),
    });

    const tests = b.addTest(.{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("lib.zig"),
    });

    // if (false) {
    // const lib = try compileGLFW(b, target, optimize);
    // module.linkLibrary(lib);
    // tests.linkLibrary(lib);
    // b.installArtifact(lib);
    // } else {
    module.linkSystemLibrary("glfw3", .{});
    tests.linkSystemLibrary("glfw3");
    // }

    const tests_run = b.addRunArtifact(tests);
    const tests_step = b.step("test", "run tests");
    tests_step.dependOn(&tests_run.step);
}

// TODO
// fn compileGLFW(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) !*std.Build.Step.Compile {
//     const lib = b.addStaticLibrary(.{
//         .target = target,
//         .optimize = optimize,
//         .name = "glfw3",
//     });
//     lib.linkLibC();
//     const upstream = b.lazyDependency("upstream", .{}) orelse return error.Failed;

//     lib.installHeader(upstream.path("include/GLFW/glfw3.h"), "GLFW/glfw3.h");
//     lib.installHeader(upstream.path("include/GLFW/glfw3native.h"), "GLFW/glfw3native.h");
//     lib.addIncludePath(upstream.path("include"));
//     lib.addIncludePath(upstream.path("src"));
//     lib.addCSourceFiles(.{ .files = &.{
//         "context.c",        "init.c",      "input.c",        "monitor.c",
//         "platform.c",       "vulkan.c",    "window.c",       "egl_context.c",
//         "osmesa_context.c", "null_init.c", "null_monitor.c", "null_window.c",
//         "null_joystick.c",
//     }, .root = upstream.path("src") });

//     const t = target.result.os.tag;
//     if (t.isDarwin()) {
//         lib.defineCMacro("_GLFW_COCOA", "1");
//         lib.addCSourceFiles(.{
//             .files = &.{
//                 "cocoa_time.c",
//                 "posix_module.c",
//                 "posix_thread.c",
//                 "cocoa_init.m",
//                 "cocoa_joystick.m",
//                 "cocoa_monitor.m",
//                 "cocoa_window.m",
//                 "nsgl_context.m",
//             },
//             .root = upstream.path("src"),
//         });
//     } else if (t == .windows) {
//         lib.defineCMacro("_GLFW_WIN32", "1");
//         lib.addCSourceFiles(.{
//             .files = &.{
//                 "win32_time.c",
//                 "win32_module.c",
//                 "win32_thread.c",
//                 "win32_init.c",
//                 "win32_joystick.c",
//                 "win32_monitor.c",
//                 "win32_window.c",
//                 "wgl_context.c",
//             },
//             .root = upstream.path("src"),
//         });
//     } else {
//         lib.defineCMacro("_GLFW_WAYLAND", "1");
//         lib.addCSourceFiles(.{
//             .files = &.{
//                 "posix_time.c",
//                 "posix_module.c",
//                 "posix_thread.c",
//                 "wl_init.c",
//                 "wl_monitor.c",
//                 "wl_window.c",
//                 "xkb_unicode.c",
//                 "posix_poll.c",
//             },
//             .root = upstream.path("src"),
//         });

//         if (t == .linux) {
//             lib.addCSourceFiles(.{
//                 .files = &.{"linux_joystick.c"},
//                 .root = upstream.path("src"),
//             });
//         }
//     }
//     return lib;
// }
