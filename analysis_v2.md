## Analysis of Global Roadmap Dependencies

The user correctly pointed out the global roadmap:
1. Standards-compliant terminal emulation (Done)
2. Competitive performance (Done)
3. Basic customizability (Done)
4. Richer windowing features (Done)
5. Native Platform Experiences (In Progress - Warning)
6. Cross-platform libghostty for Embeddable Terminals (In Progress - Warning)
7. Windows Terminals (Not Started)

**Critical Engineering Insight for Windows**:
To build a truly native Windows application (Step 7), we must rely on the architecture being developed in Step 5 and Step 6.
- **Step 6 (`libghostty` C API)**: The core terminal emulation state machine (`libghostty-vt`) and rendering pipeline must be decoupled into a C-compatible shared library. The macOS app is already doing this (Swift calling `libghostty`). Windows will similarly need a native Win32/WinUI executable that links to `libghostty`. If we skip Step 6, we end up tightly coupling the Windows UI with the core Zig engine, breaking cross-platform parity.
- **Step 5 (Native Platform Experiences)**: We need a dedicated configuration abstraction (`apprt` / GUI preferences) that doesn't rely on generic cross-platform UI frameworks. The macOS preference panel is the template. Windows will need its own native equivalent.

Therefore, the Windows `.exe` development is **strictly dependent** on the completion (or at least stable APIs) of Step 5 and 6. Our system development plan must explicitly handle these dependencies in the Requirements and Basic Design phases.
