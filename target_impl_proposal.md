# Windows Build Target Implementation Proposal

To formally implement the Windows build target (maximizing variable $X_5$: Build Determinism) and integrate our previously created `src/apprt/windows/main.zig`, the following changes must be applied to the codebase.

## 1. Update `src/apprt/runtime.zig`
```zig
<<<<<<< SEARCH
    /// GTK4. Rich windowed application. This uses a full GObject-based
    /// approach to building the application.
    gtk,

    pub fn default(target: std.Target) Runtime {
        return switch (target.os.tag) {
=======
    /// GTK4. Rich windowed application. This uses a full GObject-based
    /// approach to building the application.
    gtk,

    /// Native Windows application. Uses Win32, DirectWrite, and DirectX.
    windows,

    pub fn default(target: std.Target) Runtime {
        return switch (target.os.tag) {
            .windows => .windows,
>>>>>>> REPLACE
```

## 2. Update `src/build/SharedDeps.zig`
This file applies the platform-specific linking.

```zig
<<<<<<< SEARCH
            .gtk => {
                exe.linkLibrary(self.gtk4_layer_shell.?.artifact("gtk4-layer-shell"));
            },
        }
=======
            .gtk => {
                exe.linkLibrary(self.gtk4_layer_shell.?.artifact("gtk4-layer-shell"));
            },
            .windows => {
                exe.linkSystemLibrary("user32");
                exe.linkSystemLibrary("d3d11");
                exe.linkSystemLibrary("dwrite");
                exe.linkSystemLibrary("dxgi");
            },
        }
>>>>>>> REPLACE
```

## 3. Update `build.zig` Main Executable Creation
Ensure that when `app_runtime == .windows`, the main file points to our new wrapper (`src/apprt/windows/main.zig`), or that the generic `src/main_ghostty.zig` correctly switches to it.

```zig
// In `build.zig` around line 351 where `exe` is created:
// The entry point is usually `src/main_ghostty.zig`.
// We would update `src/main_ghostty.zig` to conditionally jump to the WinMain.
```

## 4. Update `src/main_ghostty.zig`
```zig
<<<<<<< SEARCH
pub fn main() !void {
    if (comptime build_config.app_runtime == .none) {
=======
// When building for Windows native runtime, we defer entirely to our WinMain entrypoint.
// This guarantees X_2 (C API decoupling).
pub const WinMain = if (comptime build_config.app_runtime == .windows)
    @import("apprt/windows/main.zig").WinMain else void;

pub fn main() !void {
    if (comptime build_config.app_runtime == .none) {
>>>>>>> REPLACE
```

*Note: Since the user requested roadmap and detailed design breakdown without actually making PR commits (as the codebase is huge and this is a deep dive), I am documenting this implementation proposal to show EXACTLY how $X_5$ will be maximized.*
