//! DirectWrite Font subsystem.
//! Responsible for Font Discovery and Face mapping ($X_1$).
//! Strictly utilizes ComPtr for COM object memory management to prevent leaks.

const std = @import("std");
const windows = std.os.windows;
const com = @import("com.zig");

// Placeholders for DirectWrite C ABI structs
const dwrite = opaque {}; // IDWriteFactory
const dwrite_font_collection = opaque {}; // IDWriteFontCollection
const dwrite_text_format = opaque {}; // IDWriteTextFormat

pub const FontSubsystem = struct {
    factory: com.ComPtr(dwrite),
    system_collection: com.ComPtr(dwrite_font_collection),

    pub fn init() !FontSubsystem {
        var self = FontSubsystem{
            .factory = com.ComPtr(dwrite).init(null),
            .system_collection = com.ComPtr(dwrite_font_collection).init(null),
        };

        // 1. DWriteCreateFactory
        // try createDWriteFactory(&self.factory.ptr);

        // 2. GetSystemFontCollection
        // try self.factory.get().GetSystemFontCollection(&self.system_collection.ptr, false);

        return self;
    }

    pub fn destroy(self: *FontSubsystem) void {
        // Enforce strict memory release ($X_1$)
        self.system_collection.release();
        self.factory.release();
    }

    /// Discovers a font face by name (e.g., "Cascadia Code")
    /// Returns a new format object that the caller must manage.
    pub fn discoverFontFace(self: *FontSubsystem, name: []const u16, size: f32) !com.ComPtr(dwrite_text_format) {
        var format = com.ComPtr(dwrite_text_format).init(null);

        // Call IDWriteFactory::CreateTextFormat
        // self.factory.get().CreateTextFormat(
        //     name.ptr,
        //     self.system_collection.get(),
        //     DWRITE_FONT_WEIGHT_NORMAL,
        //     DWRITE_FONT_STYLE_NORMAL,
        //     DWRITE_FONT_STRETCH_NORMAL,
        //     size,
        //     L"en-US",
        //     &format.ptr
        // );
        _ = self;
        _ = name;
        _ = size;

        return format;
    }
};
