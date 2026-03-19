# SDLC integration of Step 5/6 and 7

- **プロジェクト計画**: The goal is to build a robust Windows `.exe`. Acknowledge that the core architecture relies on `libghostty` (Step 6) and native UX guidelines (Step 5). The plan sets a sequential but partially overlapping schedule. First, establish C-bindings and VT parsing stability, *then* build the Win32/DirectX wrapper on top.
- **要件定義 (Requirements)**: Explicitly require the Windows app to consume `libghostty` rather than importing internal Zig modules directly. The requirement is not just "run on Windows," but "run as a native Windows application that embedds libghostty," mimicking the macOS approach (Swift + C API).
- **基本設計 (Basic Design)**: Define the boundary between the GUI layer (WinUI3 / raw Win32 message loop) and the core emulation layer (`libghostty`). Define the data flow for rendering (e.g., passing window handles to a DirectX renderer).
- **詳細設計 (Detailed Design)**: Design thread synchronization (UI thread vs PTY background thread), memory management for COM objects (DirectWrite/DirectX), and configuration parsing (integrating Windows paths with the core config engine).
- **実装 (Implementation)**: Building the `exe`. Writing the WinMain entry point. Instantiating the COM objects. Passing inputs via `libghostty` APIs.
- **テスト工程 (Testing)**: Unit tests for the C API bindings on Windows. Integration tests connecting a mock Window to the DX renderer. System tests mimicking user input (IME).
