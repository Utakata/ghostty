## Analysis of #2563

### Done:
- `zig build test` working
- CI, GitHub Actions for zig build test
- Shared dependencies building for Windows (Freetype, Harfbuzz, GLFW, libpng, zlib, utf8proc, pixman)
- MVP: GLFW, OpenGL, Freetype zig build -Dapp-runtime=glfw run working

### To Do:
- CI, GitHub Actions for Windows build
- Font Discovery for Windows (DirectWrite? Unsure)
- Font Face for Windows (DirectWrite)
- Use the GLFW native API to get access to Window to use DirectX
- New apprt implementation for dedicated Windows GUI, native widgets
- Installers, packages, whatever is necessary for a platform-native run experience (i.e. the macOS codesign + notarization step)
- GitHub Actions for release (release-tip.yml changes)
- Alternate "terminal" support, maybe: Console, PowerShell, WSL integration

### Developer Notes from Mitchell:
- Order matters: Incrementally goes from feature-poor to fully native dedicated experience.
- Font discovery: Still uses Freetype for rasterization initially.
- Dedicated font rasterization: Platform-native solution (DirectWrite) for correct font feel.
- Renderer: Use GLFW native API to grab window handle -> Swap OpenGL for DirectX.
- Windowing: Custom windowing layer in `apprt`.
