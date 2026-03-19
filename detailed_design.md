# 続行：詳細設計（アーキテクチャ・データ構造へのブレイクダウン）

ロジスティック回帰モデルに基づき定義した説明変数（X1〜X5）を最大化するため、**「ステップ3：詳細設計」**へ移行します。ここでは、実際にコード（Zig / C++）を書き始める前に、Windows版 `.exe` の内部アーキテクチャとデータ構造を厳密に定義します。

---

### 1. ディレクトリ構造とコンポーネント分離（$X_2$: C API分離度=100%）

GhosttyのコアロジックとWindowsシェルを完全に分離します。Windowsプラットフォーム専用のコードは `src/apprt/windows/` に集約し、`libghostty` (C API) を経由して通信します。

*   `src/apprt/windows/`
    *   `main.zig`: `WinMain` のエントリポイント。
    *   `app.zig`: `ghostty_app_t` をラップし、アプリケーション全体のライフサイクルを管理。
    *   `window.zig`: Win32メッセージループ、`HWND` の管理、IME・キー入力のインターセプト。
    *   `renderer.zig`: DirectX (D3D11/12) と DXGI SwapChain の管理。
    *   `font.zig`: DirectWrite (`IDWriteFactory`) を用いたフォント探索・描画。

---

### 2. メモリ管理とCOMオブジェクトのラッパー設計（$X_1$: メモリ厳格性=100%）

Windows開発で最もリークが起きやすいCOMオブジェクトに対して、Zigの `defer` またはラッパー構造体を強制します。

**設計方針**:
*   COMインターフェース（`IUnknown` 派生）を扱う際は、生ポインタを直接操作することを禁止します。
*   以下のようなスマートポインタ相当の構造体を定義し、`release` 呼び出しを強制します。

```zig
// 概念的なCOMラッパー設計
const ComPtr = struct {
    ptr: *anyopaque,

    pub fn init(ptr: *anyopaque) ComPtr {
        return .{ .ptr = ptr };
    }

    pub fn release(self: *ComPtr) void {
        if (self.ptr != null) {
            // IUnknown::Release() の呼び出し
            _ = self.ptr.Release();
            self.ptr = null;
        }
    }
};

// 使用例 (font.zig)
var factory = try createDWriteFactory();
defer factory.release(); // 必ずスコープ外で解放される
```

---

### 3. スレッドセーフティとイベント駆動モデル（$X_3$: スレッド安全度=100%）

UIスレッドとターミナル処理スレッド間のデータ競合を防ぎます。

**設計方針**:
1.  **UIスレッド（Win32）**:
    *   `GetMessage` / `DispatchMessage` を実行するメインスレッド。
    *   ウィンドウリサイズ（`WM_SIZE`）やキー入力（`WM_KEYDOWN`, `WM_IME_COMPOSITION`）を受け取ります。
    *   入力を受け取ると、**ミューテックスで保護されたキュー** または `ghostty` C API のスレッドセーフな関数を介してバックグラウンドへ送信します。
2.  **バックグラウンドスレッド（libghostty）**:
    *   PTYからのI/O読み書き、VTシーケンスのパース、画面バッファの更新を行います。
    *   UIスレッドのブロックを避けるため、描画要求（Dirtyフラグのセット）のみを非同期に行います。

---

### 4. GPUクラッシュからの回復機構（$X_4$: 耐障害性=100%）

`renderer.zig` における DirectX のライフサイクル設計です。

**設計方針**:
*   `IDXGISwapChain::Present` 呼び出し時に `DXGI_ERROR_DEVICE_REMOVED` または `DXGI_ERROR_DEVICE_RESET` が返された場合をトラップします。
*   **回復シーケンス**:
    1.  既存のD3D Device, DeviceContext, SwapChain, およびすべてのテクスチャ・バッファリソース（COMオブジェクト）を `Release()` します（ここで $X_1$ の設計が生きます）。
    2.  `libghostty` 側に再描画要求をキャッシュさせます。
    3.  新しいD3D Deviceを再生成し、`HWND` に対してSwapChainを再構築します。
    4.  キャッシュされたバッファから画面全体を再描画（Full Redraw）します。

---

### 5. 次のステップ（実装フェーズへの移行判断）

この「詳細設計」により、実装者が「どこでメモリを解放すべきか」「どのようにスレッドを同期すべきか」を迷う余地は排除されました（成功確率 $P(Y=1)$ の最大化）。

**次のアクション**:
もしこの設計方針に同意いただける場合、ロードマップの**「ステップ4：実装」**に入り、具体的な実装タスク（例: CIビルドの設定追加、`main.zig` のスケルトン作成、DirectWriteラッパーの記述など）に優先順位をつけ、コードレベルでの作業を開始します。どのコンポーネントから着手すべきかご指示ください。
