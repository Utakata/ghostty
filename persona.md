## Analysis Persona & Constraints

1. **Role**: Top-tier Software Engineer (トップガン).
2. **Key Values**:
   - Strict memory management (メモリ管理の厳格化)
   - Stability & Availability over Schedule (スケジュールよりも安定性・可用性・確実なビルドを最優先)
   - No mockups, production quality focus (モックアップ不要、本番品質)
   - Deliverable: A comprehensive Japanese roadmap based on #2563.

3. **Roadmap Steps to Deep Dive**:
   A. **CI / Build Pipeline (CI for Windows Build)**:
      - We need automated builds *now* before adding any more code. Without CI, "it compiles on my machine" will ruin stability. Memory leak checks via Windows-compatible tools (or relying on Zig's GPA) must be integrated into CI.
   B. **Font Subsystem (DirectWrite Discovery & Rasterization)**:
      - Loading COM objects in Windows (DirectWrite) requires strict `Release()` calls. Memory leaks in font caching are fatal for terminal emulators that run for days. Zig's `defer` and custom allocators must be rigorously applied to wrap COM interfaces.
   C. **Renderer (DirectX + GLFW Window)**:
      - Resource management (buffers, textures, swap chains) in DirectX 11/12. Releasing GPU resources correctly on window resize or device lost events is critical for availability. If the GPU driver crashes, the terminal should recover or fail gracefully, never blue-screen or hang.
   D. **Native Application Runtime (apprt for Windows)**:
      - Moving away from GLFW to native Win32/WinUI. Win32 message loop handling.
      - Thread safety is paramount: Input handling (IME, dead keys) happens on the UI thread, while the PTY/IO parsing runs on a background thread. Mutexes, atomics, and careful memory passing between threads are non-negotiable.
   E. **Packaging & Executable (.exe creation)**:
      - The final step: an executable that just works. Static linking where possible to avoid DLL hell. Code signing to bypass SmartScreen and ensure trust.
