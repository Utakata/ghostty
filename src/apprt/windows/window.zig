//! Win32 Windowing subsystem.
//! Creates the HWND and handles the main message loop.
//! Responsible for isolating the UI thread from the libghostty background threads ($X_3$).

const std = @import("std");
const windows = std.os.windows;

// TODO: Import libghostty C API definitions.

/// Represents the main Ghostty Terminal window on Windows.
pub const Window = struct {
    hwnd: windows.HWND,

    // The C-API app reference to communicate inputs asynchronously.
    // app: *ghostty_app_t,

    pub fn init() !Window {
        // Implementation of Win32 class registration and CreateWindowEx goes here.
        // We will assert `-Dstrict` compliance during compilation.
        return Window{
            .hwnd = undefined, // placeholder
        };
    }

    pub fn destroy(self: *Window) void {
        // Safe destruction of the Window handle.
        _ = self;
    }

    /// The Win32 Message Pump. This runs strictly on the UI thread.
    pub fn pumpMessages(self: *Window) void {
        // while (GetMessage(...)) { TranslateMessage(); DispatchMessage(); }
        _ = self;
    }
};
