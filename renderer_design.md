# Renderer Design (Priority 2: $X_4$ & $X_1$)

## 1. Goal
Maximize $P(Y=1)$ by ensuring that the terminal NEVER crashes when the GPU driver restarts or the user undocks a laptop (eGPU disconnect). This requires trapping `DXGI_ERROR_DEVICE_REMOVED` during the `Present` call.

## 2. Requirements
- **Memory Strictness ($X_1$)**: All DirectX COM interfaces (`ID3D11Device`, `ID3D11DeviceContext`, `IDXGISwapChain`) must be wrapped in `com.zig`'s `ComPtr`.
- **Fault Tolerance ($X_4$)**: A state machine that transitions to a `Recovery` state upon `DEVICE_REMOVED`. In this state, the app completely drops the D3D11 context and recreates it from scratch using the existing `HWND`.

## 3. Zig Structure
```zig
pub const Renderer = struct {
    hwnd: windows.HWND,
    device: ComPtr(d3d11.ID3D11Device),
    context: ComPtr(d3d11.ID3D11DeviceContext),
    swap_chain: ComPtr(dxgi.IDXGISwapChain),

    pub fn init(hwnd: windows.HWND) !Renderer { ... }
    pub fn render(self: *Renderer) void { ... }
    fn handleDeviceLost(self: *Renderer) void { ... }
};
```
