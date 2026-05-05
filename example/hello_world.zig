const std = @import("std");
const colored = @import("colored");

pub fn main(init: std.process.Init) !void {
    const io = init.io;

    var buf: [128]u8 = undefined;
    var file_writer = std.Io.File.stdout().writer(io, &buf);
    const stdout: *std.Io.Writer = &file_writer.interface;

    try colored.print(stdout, "Hello, World!\n", .{
        .color = .{ .ansi = .brightRed },
        .background = .{ .ansi = .black },
        .styles = &.{ .bold, .underline },
    });
}
