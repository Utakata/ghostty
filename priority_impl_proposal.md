# Priority 1 Implementation: $X_3$ (Thread Safety via Win32 Message Loop)

The logistic regression analysis dictates that we implement the Win32 `HWND` creation and message loop first. This guarantees thread separation ($X_3$) before integrating the GPU renderer ($X_4$) and font rasterization ($X_1$).

We will update `src/apprt/windows/window.zig` to include the `WNDCLASSEX` registration, `CreateWindowEx`, and the core `WndProc`.

```zig
// Proposed Implementation for src/apprt/windows/window.zig
const std = @import("std");
const windows = std.os.windows;

const CLASS_NAME = std.unicode.utf8ToUtf16LeStringLiteral("GhosttyWindowClass");

pub const Window = struct {
    hwnd: windows.HWND,

    pub fn init(hInstance: windows.HINSTANCE) !Window {
        // 1. Register Window Class
        var wc: windows.WNDCLASSEXW = undefined;
        wc.cbSize = @sizeOf(windows.WNDCLASSEXW);
        wc.style = windows.CS_HREDRAW | windows.CS_VREDRAW;
        wc.lpfnWndProc = wndProc;
        wc.cbClsExtra = 0;
        wc.cbWndExtra = 0;
        wc.hInstance = hInstance;
        wc.hIcon = null; // TODO: load ghostty icon
        wc.hCursor = null; // TODO: load standard arrow cursor
        wc.hbrBackground = null;
        wc.lpszMenuName = null;
        wc.lpszClassName = CLASS_NAME;
        wc.hIconSm = null;

        if (windows.user32.RegisterClassExW(&wc) == 0) {
            return error.RegisterClassFailed;
        }

        // 2. Create Window ($X_3$ prerequisite)
        const hwnd = windows.user32.CreateWindowExW(
            0,
            CLASS_NAME,
            std.unicode.utf8ToUtf16LeStringLiteral("Ghostty"),
            windows.WS_OVERLAPPEDWINDOW,
            windows.CW_USEDEFAULT, windows.CW_USEDEFAULT,
            800, 600, // Default dimensions
            null,
            null,
            hInstance,
            null,
        ) orelse return error.CreateWindowFailed;

        _ = windows.user32.ShowWindow(hwnd, windows.SW_SHOWDEFAULT);

        return Window{
            .hwnd = hwnd,
        };
    }

    pub fn destroy(self: *Window) void {
        _ = windows.user32.DestroyWindow(self.hwnd);
    }

    pub fn pumpMessages(self: *Window) void {
        _ = self;
        var msg: windows.MSG = undefined;
        // Main UI Thread Event Loop ($X_3$)
        while (windows.user32.GetMessageW(&msg, null, 0, 0) > 0) {
            _ = windows.user32.TranslateMessage(&msg);
            _ = windows.user32.DispatchMessageW(&msg);
        }
    }
};

// The WndProc that must forward events safely to the background libghostty thread.
fn wndProc(hwnd: windows.HWND, uMsg: windows.UINT, wParam: windows.WPARAM, lParam: windows.LPARAM) callconv(.C) windows.LRESULT {
    switch (uMsg) {
        windows.WM_DESTROY => {
            windows.user32.PostQuitMessage(0);
            return 0;
        },
        // TODO: Handle WM_SIZE for DirectX swap chain resize ($X_4$)
        // TODO: Handle WM_KEYDOWN, WM_IME_COMPOSITION for thread-safe input queue ($X_3$)
        else => return windows.user32.DefWindowProcW(hwnd, uMsg, wParam, lParam),
    }
}
```
