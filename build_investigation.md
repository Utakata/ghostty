# Investigation Results

1. **App Runtime Definition**: `src/apprt/runtime.zig` defines `Runtime = enum { none, gtk }`. We need to add `windows` to this enum.
2. **Default Runtime**: In `Runtime.default(target)`, we should make `windows` the default when `target.os.tag == .windows`.
3. **Build Script Integration**:
   - `src/build/SharedDeps.zig` sets up the executable links based on `config.app_runtime`. We need to add the `.windows` branch there and link `dwrite`, `d3d11`, `user32`.
   - `build.zig` uses `SharedDeps` to configure the main executable.

This confirms the exact locations to modify to achieve a successful build ($X_5$ determinism) for the Windows `.exe`.
