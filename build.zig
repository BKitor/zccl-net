const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addSharedLibrary(.{
        .name = "nccl-net-bkz",
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
        .version = .{ .major = 0, .minor = 1, .patch = 0 },
    });
    lib.linkLibC();
    lib.addIncludePath(.{ .path = "src/cinclude/" });
    b.installArtifact(lib);

    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    lib_unit_tests.linkLibC();
    lib_unit_tests.addIncludePath(.{ .path = "src/cinclude/" });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}
