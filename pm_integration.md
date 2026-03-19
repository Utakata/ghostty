# Applying Logistic Regression to Requirements & SDLC

The logistic regression approach transforms abstract goals into mathematically managed requirements and implementation steps.

## Phase Mapping

1. **要件定義 (Requirements Definition)**:
   - *Goal*: Define the baseline metrics to keep `P(Y=1) > 0.99`.
   - *Requirement 1*: `X1 (Memory Strictness)` MUST be 100%. No memory leaks are acceptable in a 24/7 terminal emulator.
   - *Requirement 2*: `X5 (C API Decoupling)` MUST be 100%. The app must embed `libghostty` (Step 6 dependency) to ensure cross-platform parity.
   - *Requirement 3*: `X4 (GPU Fault Tolerance)` MUST be >95%. The renderer must not crash the app if the GPU fails.

2. **基本設計 (Basic Design)**:
   - *Goal*: Assign architectural weights (`β`). Memory management (`β1`) and thread safety (`β3`) are given the highest impact factors.
   - The UI architecture is decoupled into a host `exe` and a `libghostty` backend to maximize `X5`.

3. **詳細設計 (Detailed Design)**:
   - *Goal*: Provide the blueprints to maximize the explanatory variables (`X_n`).
   - For `X1` (Memory): Design the `defer` block wrappers for all DirectWrite and DirectX COM pointers.
   - For `X3` (Thread Safety): Design the exact lock-free algorithms or mutex placements between the Win32 UI thread and the PTY thread.

4. **実装 (Implementation)**:
   - *Goal*: Write code strictly focused on increasing the probability of `Y=1`.
   - Mockups are forbidden because they provide `X_n = 0` value to long-term stability. Every PR must include unit tests ensuring memory is freed.

5. **テスト (Testing & Release Threshold)**:
   - At each CI run, compute the proxy for `P(Y=1)` based on test results (`X2`). If `-Dstrict` fails, `X2` drops, plunging `P(Y=1)` below the release threshold, automatically blocking the PR.
