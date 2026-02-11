const std = @import("std");
const apprt = @import("../../apprt.zig");
const App = @import("App.zig");
const CoreSurface = @import("../../Surface.zig");
const windows = std.os.windows;
const win32 = @import("../../os/windows.zig");

const Surface = @This();
const log = std.log.scoped(.surface);

app: *App,
core_surface: CoreSurface,
hwnd: windows.HWND,

pub const Options = struct {
    // Basic surface options
};

pub fn init(self: *Surface, app: *App, opts: Options) !void {
    _ = opts;
    self.app = app;
    self.core_surface = undefined;

    const h_instance = win32.kernel32.GetModuleHandleW(null);

    const class_name = std.unicode.utf8ToUtf16LeStringLiteral("GhosttyWindowClass");

    var wnd_class = std.mem.zeroes(win32.WNDCLASSEXW);
    wnd_class.cbSize = @sizeOf(win32.WNDCLASSEXW);
    wnd_class.style = win32.CS_HREDRAW | win32.CS_VREDRAW;
    wnd_class.lpfnWndProc = wndProc;
    wnd_class.hInstance = h_instance;
    wnd_class.hCursor = win32.user32.LoadCursorW(null, win32.IDC_ARROW);
    wnd_class.lpszClassName = class_name;

    _ = win32.user32.RegisterClassExW(&wnd_class);

    const title = std.unicode.utf8ToUtf16LeStringLiteral("Ghostty");

    self.hwnd = win32.user32.CreateWindowExW(
        0,
        class_name,
        title,
        win32.WS_OVERLAPPEDWINDOW | win32.WS_VISIBLE,
        win32.CW_USEDEFAULT,
        win32.CW_USEDEFAULT,
        800,
        600,
        null,
        null,
        h_instance,
        self,
    ) orelse return error.WindowCreationFailed;
}

pub fn deinit(self: *Surface) void {
    _ = win32.user32.DestroyWindow(self.hwnd);
    // TODO: Core surface is not initialized yet
    // self.core_surface.deinit();
}

pub fn close(self: *Surface, process_alive: bool) void {
    _ = process_alive;
    _ = win32.user32.DestroyWindow(self.hwnd);
}

pub fn refresh(self: *Surface) void {
    _ = win32.user32.InvalidateRect(self.hwnd, null, windows.TRUE);
}

pub fn draw(self: *Surface) void {
    _ = self;
    // TODO: Perform drawing
}

pub fn updateContentScale(self: *Surface, x: f64, y: f64) void {
    _ = self;
    _ = x;
    _ = y;
}

pub fn updateSize(self: *Surface, width: u32, height: u32) void {
    _ = self;
    _ = width;
    _ = height;
}

pub fn getCursorPos(self: *const Surface) !apprt.CursorPos {
    var point: windows.POINT = undefined;
    if (win32.user32.GetCursorPos(&point) == 0) return error.GetCursorPosFailed;
    if (win32.user32.ScreenToClient(self.hwnd, &point) == 0) return error.ScreenToClientFailed;
    return .{ .x = @floatFromInt(point.x), .y = @floatFromInt(point.y) };
}

pub fn supportsClipboard(self: *const Surface, clipboard_type: apprt.Clipboard) bool {
    _ = self;
    _ = clipboard_type;
    return false;
}

pub fn clipboardRequest(
    self: *Surface,
    clipboard_type: apprt.Clipboard,
    state: apprt.ClipboardRequest,
) !bool {
    _ = self;
    _ = clipboard_type;
    _ = state;
    return false;
}

pub fn setClipboard(
    self: *const Surface,
    clipboard_type: apprt.Clipboard,
    contents: []const apprt.ClipboardContent,
    confirm: bool,
) !void {
    _ = self;
    _ = clipboard_type;
    _ = contents;
    _ = confirm;
}

pub fn newSurfaceOptions(self: *const Surface, context: apprt.surface.NewSurfaceContext) apprt.Surface.Options {
    _ = self;
    _ = context;
    return .{};
}

pub fn defaultTermioEnv(self: *const Surface) !std.process.EnvMap {
    const alloc = self.app.core_app.alloc;
    return std.process.getEnvMap(alloc);
}

fn wndProc(
    hwnd: windows.HWND,
    uMsg: windows.UINT,
    wParam: windows.WPARAM,
    lParam: windows.LPARAM,
) callconv(windows.WINAPI) windows.LRESULT {
    var surface: ?*Surface = null;
    if (uMsg == win32.WM_NCCREATE) {
        const create_struct = @as(*win32.CREATESTRUCTW, @ptrFromInt(@as(usize, @bitCast(lParam))));
        surface = @as(*Surface, @ptrCast(@alignCast(create_struct.lpCreateParams)));
        _ = win32.user32.SetWindowLongPtrW(hwnd, win32.GWLP_USERDATA, @bitCast(@intFromPtr(surface)));
    } else {
        surface = @as(?*Surface, @ptrFromInt(@as(usize, @bitCast(win32.user32.GetWindowLongPtrW(hwnd, win32.GWLP_USERDATA)))));
    }

    if (surface) |_| {
        switch (uMsg) {
            win32.WM_DESTROY => {
                win32.user32.PostQuitMessage(0);
                return 0;
            },
            win32.WM_PAINT => {
                var ps: win32.PAINTSTRUCT = undefined;
                const hdc = win32.user32.BeginPaint(hwnd, &ps);
                _ = win32.user32.FillRect(hdc, &ps.rcPaint, @ptrFromInt(@as(usize, @intCast(win32.COLOR_WINDOW + 1))));
                _ = win32.user32.EndPaint(hwnd, &ps);
                return 0;
            },
            else => {},
        }
    }

    return win32.user32.DefWindowProcW(hwnd, uMsg, wParam, lParam);
}
