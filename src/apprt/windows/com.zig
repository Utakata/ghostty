//! Safe COM Object Wrapper for strict memory management ($X_1$)
//! By wrapping all IUnknown-derived COM pointers in this struct,
//! we enforce RAII patterns via `defer ptr.release()`.

const std = @import("std");

/// A wrapper for COM pointers that strictly enforces the Release() lifecycle.
/// `T` must be a struct that has a `Release()` method.
pub fn ComPtr(comptime T: type) type {
    return struct {
        const Self = @This();

        ptr: ?*T,

        /// Initialize with a raw pointer, which can be null.
        pub fn init(ptr: ?*T) Self {
            return .{ .ptr = ptr };
        }

        /// Safely releases the COM object if it is not null, and sets the internal
        /// pointer to null to prevent double-freeing. This is crucial for maximizing $X_1$.
        pub fn release(self: *Self) void {
            if (self.ptr) |p| {
                // Ignore the returned reference count
                _ = p.Release();
                self.ptr = null;
            }
        }

        /// Returns the underlying pointer, panicking if it's null.
        /// Useful when passing the pointer to Win32 functions.
        pub fn get(self: Self) *T {
            return self.ptr.?;
        }

        /// Deinitialize helper to be used in defer blocks directly.
        pub fn deinit(self: *Self) void {
            self.release();
        }
    };
}
