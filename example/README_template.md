# colored.zig

A simple and easy to use library for colored output. Written with zig 0.14

# Installation

```sh
# Version that works with zig 0.16
zig fetch --save git+https://github.com/invra/colored.zig
```

Then add the following to `build.zig`:

```zig
const clap = b.dependency("colored", .{{}});
exe.root_module.addImport("colored", clap.module("colored"));
```

# Examples

## Hello World

```zig
{s}
```

## Color palette

```zig
{s}
```
