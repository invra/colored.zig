const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Module
    const pretty_mod = b.addModule("colored", .{
        .root_source_file = b.path("src/pretty.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Test
    const test_step = b.step("test", "Run all tests in all modes.");
    const tests = b.addTest(.{
        .root_module = pretty_mod,
    });
    const run_tests = b.addRunArtifact(tests);
    test_step.dependOn(&run_tests.step);

    // Examples
    const Example = enum {
        hello_world,
        color_palette,
    };
    const example_option = b.option(Example, "example", "Example to run (default: hello_world)") orelse .hello_world;
    const example_step = b.step("example", "Run example");
    const example = b.addExecutable(.{
        .name = "example",
        .root_module = b.createModule(.{
            .root_source_file = b.path(
                b.fmt("example/{s}.zig", .{@tagName(example_option)}),
            ),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "colored", .module = pretty_mod },
            },
        }),
    });
    example.root_module.addImport("colored", pretty_mod);
    const example_run = b.addRunArtifact(example);
    example_step.dependOn(&example_run.step);

    // Docs
    const docs_step = b.step("docs", "Build docs");
    const docs_obj = b.addObject(.{
        .name = "colored",
        .root_module = pretty_mod,
    });
    const docs = docs_obj.getEmittedDocs();
    docs_step.dependOn(&b.addInstallDirectory(.{
        .source_dir = docs,
        .install_dir = .prefix,
        .install_subdir = "docs",
    }).step);

    // README
    const readme_step = b.step("readme", "Remake README.");
    const readme = readMeStep(b);
    readme_step.dependOn(readme);

    // ALL
    const all_step = b.step("all", "Build everything and runs all tests");
    all_step.dependOn(test_step);
    all_step.dependOn(readme_step);
    b.default_step.dependOn(all_step);
}

fn readMeStep(b: *std.Build) *std.Build.Step {
    const s = b.allocator.create(std.Build.Step) catch unreachable;
    s.* = std.Build.Step.init(.{
        .id = .custom,
        .name = "ReadMeStep",
        .owner = b,
        .makeFn = struct {
            fn make(step: *std.Build.Step, options: std.Build.Step.MakeOptions) anyerror!void {
                _ = options;
                @setEvalBranchQuota(10000);
                const owner = step.owner;
                const content = try std.fmt.allocPrint(owner.allocator, @embedFile("example/README_template.md"), .{
                    @embedFile("example/hello_world.zig"),
                    @embedFile("example/color_palette.zig"),
                });
                defer owner.allocator.free(content);

                const file = try owner.build_root.handle.createFile(owner.graph.io, "README.md", .{});
                var buf: [4096]u8 = undefined;
                var writer = file.writer(owner.graph.io, &buf);
                try writer.interface.writeAll(content);
                try writer.flush();
            }
        }.make,
    });
    return s;
}
