const std = @import("std");

const FileWriter = struct {
    const Self = @This();
    pub fn writeAll(_: Self, bytes: []const u8) void {
        std.debug.print("[FileWriter] {s};\n", .{bytes});
    }
};

const MultiWriter = struct {
    const Self = @This();
    const foo = "foo";
    pub fn writeAll(_: Self, bytes: []const u8) void {
        std.debug.print("[MultiWriter] {s};\n", .{bytes});
    }
};

const NullWriter = struct {
    const Self = @This();
    pub fn writeAll(_: Self, _: []const u8) void {}
};

const BadWriter = struct {
    const Self = @This();
    pub fn writeAll(_: Self, val: i32) void {
        std.debug.print("[BadWriter] {d};\n", .{val});
    }
};

fn save_explicit(writer: anytype, bytes: []const u8) void {
    writer.writeAll(bytes);
}

fn explicit_save() void {
    save_explicit(FileWriter{}, "foo");
    save_explicit(MultiWriter{}, "foo");
    save_explicit(NullWriter{}, "foo");
    save_explicit(BadWriter{}, "foo");
}

const trait = std.meta.trait;
fn save_trait(writer: anytype, bytes: []const u8) void {
    comptime {
        if (!trait.isPtrTo(.Struct)(@TypeOf(writer))) @compileError("Expects writer to be pointer type");
        if (!trait.hasFn("writeAll")(@TypeOf(writer.*))) @compileError("Expects writer.* to have fn 'writeAll'");
    }
    writer.writeAll(bytes);
}

fn trait_save() void {
    save_trait(&FileWriter{}, "foo");
    save_trait(MultiWriter{}, "foo");
    save_trait(&NullWriter{}, "foo");
    save_trait(&BadWriter{}, "foo");
}

const Writer = union(enum) {
    FileWriter: FileWriter,
    MultiWriter: MultiWriter,
};

fn save_union(writer: Writer, bytes: []const u8) void {
    switch (writer) {
        inline else => |w| w.writeAll(bytes),
    }
}

fn union_save() void {
    save_union(Writer{ .FileWriter = FileWriter{} }, "hello");
    save_union(Writer{ .MultiWriter = MultiWriter{} }, "hello");
}

pub fn main() !void {
    explicit_save();
    trait_save();
    union_save();
}
