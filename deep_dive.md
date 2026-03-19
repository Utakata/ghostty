# Deep Dive Analysis (Top Gun Perspective)

- **プロジェクト計画**: We must integrate Step 5 & 6 as blockers. The plan dictates parallel development: the engine team stabilizes `libghostty` C API on Windows (memory layout, calling conventions), while the platform team builds the Win32/DirectX shell. We refuse to build a monolithic Zig app that hacks around the UI; we strictly separate UI (C++ or Zig with Win32 wrappers) from Core (`libghostty`).

- **要件定義**:
  - The Windows client must natively embed `libghostty` via its C API.
  - No generic GUI frameworks; it must use native Win32/WinUI (Step 5 alignment).
  - Must pass strict CI (zero warnings, GPA memory leak tests).

- **基本設計**:
  - **Architecture**: A host executable (`.exe`) managing the Win32 message loop and a rendering surface (DirectX SwapChain). This host dynamically or statically links to `libghostty`.
  - **Resource Lifecycle**: The host owns the OS-level resources (HWND, COM pointers). It passes handles (like the HWND or a generic `void*` context) down to the renderer.

- **詳細設計**:
  - **Memory Management**: Every COM interface (`IDWriteFactory`, `IDXGISwapChain`) in the host must be wrapped in a RAII-like structure or strictly use `defer x.Release()`.
  - **Thread Safety**: The Win32 UI thread handles user input and resizes. The PTY parsing and rendering must happen asynchronously. Memory shared between the UI thread and `libghostty` state machine must be protected by explicit synchronization primitives (mutexes/atomics) to prevent undefined behavior.

- **実装**:
  - Write the `WinMain` entry. Setup DirectWrite (Font Discovery/Face) and DirectX 11/12 contexts.
  - We do not tolerate "mockups". The first implementation of the renderer must correctly handle `DXGI_ERROR_DEVICE_REMOVED` (device lost) to ensure high availability. If the GPU crashes, the terminal redraws without crashing the app.

- **単体・結合テスト**:
  - Unit: Test the Win32 abstractions (e.g., ensure our COM wrappers don't leak).
  - Integration: Test the boundary between the host `exe` and `libghostty`. Does sending an input key sequence via the C API correctly update the internal terminal state?

- **システムテスト**:
  - E2E testing mimicking user behavior. Focus on Windows-specific edge cases: IME input (kanji composition), complex rendering under load.

- **運用テスト / リリース / 保守**:
  - Beta deployment via GitHub Actions (signed `.exe` using Authenticode).
  - Monitor automated crash reports (Sentry) specific to the DirectX/Win32 layer. Fast triage of memory leaks reported by end users.
