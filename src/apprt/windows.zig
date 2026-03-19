//! Windows-native application runtime (apprt).
//! This acts as the bridge between libghostty and the Win32/DirectX APIs.

const std = @import("std");
const windows = std.os.windows;

// TODO: Integrate with libghostty state.
