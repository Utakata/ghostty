//! The main entry point for the Ghostty Windows executable.
//! This ensures that we act as a standalone host embedding `libghostty` ($X_2$).

const std = @import("std");
const windows = std.os.windows;
const win_app = @import("window.zig");

// Standard WinMain signature mapping for Zig.
pub fn WinMain(
    hInstance: windows.HINSTANCE,
    hPrevInstance: ?windows.HINSTANCE,
    pCmdLine: ?windows.PWSTR,
    nCmdShow: windows.INT,
) callconv(.C) windows.INT {
    _ = hInstance;
    _ = hPrevInstance;
    _ = pCmdLine;
    _ = nCmdShow;

    // Use Zig's GPA for memory leak detection during development ($X_1$).
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    _ = allocator; // Will pass to libghostty / DXGI subsystems

    // Step 1: Initialize the C API engine (libghostty via ghostty_app_t).

    // Step 2: Initialize the Native Win32 Window
    var window = win_app.Window.init() catch {
        return 1;
    };
    defer window.destroy();

    // Step 3: Enter the message pump (Thread Separation: $X_3$)
    window.pumpMessages();

    return 0;
}
