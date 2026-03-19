I have verified that the Ghostty `build.zig` currently handles `app_runtime = .none` and `gtk` and `embedded` (for macOS). It does not yet have a dedicated `windows` apprt linking directive for `DirectWrite` and `D3D11`.
I will document that the next necessary CI step ($X_5$) requires adding:
`exe.linkSystemLibrary("d3d11");`
`exe.linkSystemLibrary("dwrite");`
`exe.linkSystemLibrary("user32");`
to `buildpkg/` or `build.zig` when compiling for the Windows target.
