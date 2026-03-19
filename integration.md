# Integration and Binding (libghostty via apprt)

To finalize the `.exe` creation, the `src/apprt/windows.zig` must act as the orchestrator linking the C API ($X_2$) to our natively built $X_1$, $X_3$, and $X_4$ components.

```zig
// Proposed src/apprt/windows.zig Orchestrator Update
const std = @import("std");
const window = @import("windows/window.zig");
const renderer = @import("windows/renderer.zig");
const font = @import("windows/font.zig");

// Assuming `libghostty` exposes `ghostty_app_t` and `ghostty_config_t`
const libghostty = @import("libghostty_c_api");

pub const AppRuntime = struct {
    win: window.Window,
    gfx: renderer.Renderer,
    text: font.FontSubsystem,

    // The core terminal state machine
    core_app: *libghostty.ghostty_app_t,

    pub fn init() !AppRuntime {
        // ... (Call init for win, gfx, text)
        // ... (Initialize core_app and bind the HWND to it)
    }

    pub fn run() void {
        // Start the background thread for PTY ($X_3$ guarantee)
        // Start the UI message pump
    }
};
```
