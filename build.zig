const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const libid3tag_dep = b.dependency("libid3tag", .{});

    const zlib_dep = b.dependency("zlib", .{
        .target = target,
        .optimize = optimize,
    });
    const config_h = b.addConfigHeader(.{
        .style = .{ .cmake = libid3tag_dep.path("id3tag.h.in") },
        .include_path = "id3tag.h",
    }, .{
        .CMAKE_PROJECT_VERSION_MAJOR = 0,
        .CMAKE_PROJECT_VERSION_MINOR = 16,
        .CMAKE_PROJECT_VERSION_PATCH = 3,
    });

    const lib = b.addStaticLibrary(.{
        .name = "id3tag",
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    lib.addConfigHeader(config_h);
    lib.addCSourceFiles(.{
        .root = libid3tag_dep.path("."),
        .files = &id3tag_src,
        .flags = &.{},
    });
    lib.linkLibrary(zlib_dep.artifact("z"));
    lib.defineCMacro("HAVE_SYS_STAT_H", "1");
    lib.defineCMacro("HAVE_UNISTD_H", "1");
    lib.defineCMacro("HAVE_ASSERT_H", "1");
    lib.defineCMacro("HAVE_FTRUNCATE", "1");
    lib.addIncludePath(libid3tag_dep.path("."));
    lib.installConfigHeader(config_h);
    b.installArtifact(lib);

    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}

const id3tag_src = [_][]const u8{
    "compat.c",
    "crc.c",
    "debug.c",
    "field.c",
    "file.c",
    "frame.c",
    "frametype.c",
    "genre.c",
    "latin1.c",
    "parse.c",
    "render.c",
    "tag.c",
    "ucs4.c",
    "utf16.c",
    "utf8.c",
    "util.c",
    "version.c",
};
