# Priority Analysis via Logistic Regression Weights ($\beta$)

The user requested a step-by-step progression based on the logistic regression analysis of our explanatory variables. We must assign weights ($\beta_n$) to determine which component provides the maximum marginal increase to $P(Y=1)$ (Enterprise Stability) at this stage.

## Variables and their Weights ($\beta$)

$P(Y=1) = \frac{1}{1 + \exp(-(\beta_0 + \beta_1 X_1 + \beta_2 X_2 + \beta_3 X_3 + \beta_4 X_4 + \beta_5 X_5))}$

*   **$X_2$ (C API Separation) & $X_5$ (Build Determinism)**:
    *   $\beta_2, \beta_5 = \infty$ (Blocking Prerequisites).
    *   We have already designed the architecture for these in the previous step (`main.zig`, `build.zig` modifications).
*   **$X_3$ (Thread Safety - Win32 Event Loop)**:
    *   $\beta_3 = 0.85$.
    *   *Why*: Without a stable event loop and `HWND`, nothing can be rendered, and no inputs can be processed. Race conditions here instantly crash the app. This is the foundation.
*   **$X_4$ (GPU Fault Tolerance - DirectX SwapChain)**:
    *   $\beta_4 = 0.90$.
    *   *Why*: Ghostty relies heavily on GPU acceleration. Device lost (`DXGI_ERROR_DEVICE_REMOVED`) is a common cause of terminal crashes on Windows (e.g., driver updates, sleep/wake). Implementing the recovery state machine here prevents catastrophic failures. However, it requires an `HWND` from $X_3$.
*   **$X_1$ (Memory Strictness - DirectWrite/COM Wrappers)**:
    *   $\beta_1 = 0.70$.
    *   *Why*: Memory leaks in fonts (`IDWriteFactory`) degrade performance over days/weeks but rarely cause instant crashes. We have the `ComPtr` abstraction ready, but we should apply it after the window and renderer are stable.

## Step-by-Step Priority Plan

1.  **Priority 1: $X_3$ (Thread Safety & Windowing)** -> `src/apprt/windows/window.zig`
    *   *Action*: Implement the Win32 window class registration (`RegisterClassEx`), window creation (`CreateWindowEx`), and the core message procedure (`WndProc`). Establish the thread boundary.
2.  **Priority 2: $X_4$ (GPU Fault Tolerance)** -> `src/apprt/windows/renderer.zig`
    *   *Action*: Implement the DirectX 11 device and swap chain initialization, explicitly handling `DXGI_ERROR_DEVICE_REMOVED` and injecting the $X_1$ `ComPtr` for strict memory management.
3.  **Priority 3: $X_1$ (Memory Strictness - Fonts)** -> `src/apprt/windows/font.zig`
    *   *Action*: Implement DirectWrite discovery and rasterization.
