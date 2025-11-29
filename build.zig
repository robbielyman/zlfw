const std = @import("std");
const vkgen = @import("vulkan-zig");
const ShaderCompileStep = vkgen.ShaderCompileStep;

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const shared = b.option(bool, "shared", "build a shared GLFW") orelse true;

    const module = b.addModule("zlfw", .{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("lib.zig"),
    });

    const tests = b.addTest(.{
        .root_module = module,
    });

    const glfw_dep = b.dependency("upstream", .{
        .target = target,
        .optimize = optimize,
        .shared = shared,
    });
    module.linkLibrary(glfw_dep.artifact("glfw3"));

    const tests_run = b.addRunArtifact(tests);
    const tests_step = b.step("test", "run tests");
    tests_step.dependOn(&tests_run.step);
}
