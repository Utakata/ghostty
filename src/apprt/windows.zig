// The required comptime API for any apprt.
pub const App = @import("windows/App.zig");
pub const Surface = @import("windows/Surface.zig");

// Resources directory is not used on Windows in the same way as Linux/GTK
// but we need to expose it to satisfy the interface.
pub const resourcesDir = @import("windows/resources.zig").resourcesDir;

test {
    @import("std").testing.refAllDecls(@This());
}
