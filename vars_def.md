# Variables Definition for Logistic Regression in Ghostty Windows Support

## Objective Variable (Y)
- **Y (Project Success)**: The probability (0.0 to 1.0) that the Ghostty Windows `.exe` achieves enterprise-grade stability, zero memory leaks, and 100% build reliability in the CI pipeline without relying on mockups.

## Explanatory Variables (X)
These variables mathematically drive the probability of `Y`.
- **X1 (Memory Management Strictness)**: The percentage of COM objects (`IDWriteFactory`, `IDXGISwapChain`) and Win32 handles correctly wrapped in RAII/defer patterns, validated by zero leaks in Zig's GPA during CI tests.
- **X2 (Build Determinism)**: The success rate of the GitHub Actions Windows build pipeline (`x86_64` and `aarch64`) with `-Dstrict` (warnings treated as errors).
- **X3 (Concurrency Safety)**: The absence of race conditions (measured inversely by the number of unsafe memory accesses) between the Win32 UI message loop and the `libghostty` background PTY thread.
- **X4 (GPU Fault Tolerance)**: The successful recovery rate from `DXGI_ERROR_DEVICE_REMOVED` (device lost) without crashing the application.
- **X5 (C API Decoupling)**: The degree to which the Windows `.exe` correctly interfaces with the core engine exclusively via the `libghostty` C API, rather than tightly coupling internal Zig modules.

## The Model
`P(Y=1) = 1 / (1 + exp(-(β0 + β1*X1 + β2*X2 + β3*X3 + β4*X4 + β5*X5)))`
Where `β` represents the weight (importance) of each variable as determined by the Top Gun engineer (e.g., `β1` and `β3` are heavily weighted as memory and concurrency bugs are fatal).
