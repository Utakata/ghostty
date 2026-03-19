私は安定性・可用性を最優先とし、メモリ管理に一切の妥協を許さないソフトウェアエンジニアとして、GhosttyのWindowsサポート（Issue #2563）のロードマップを分析し、**「確実に動作する `.exe` を出力する」**ためのステップバイステップの計画を提示します。

モックアップや中途半端な実装は排除し、各ステップで「ビルドが通ること」と「メモリリーク・クラッシュを未然に防ぐアーキテクチャ」を要求します。

現在のGhosttyは、Windowsにおいてテスト用のビルド（`zig build test`）やGLFW/OpenGLを用いた最低限のクロスプラットフォーム描画（MVP）までは完了しています。ここから本番品質のネイティブアプリケーション（.exe）へと昇華させるための厳格なロードマップは以下の通りです。

---

### フェーズ1：ビルドパイプラインとCIの絶対的堅牢化（最優先事項）
*Issue Task: CI, GitHub Actions for Windows build*

コードを1行でも書く前に、Windows用のビルドパイプラインを確立します。「ローカルでビルドできた」は無価値です。
1. **GitHub ActionsでのWindows Build追加**:
   - `x86_64-windows` および `aarch64-windows` (ARM64) 向けのコンパイルをCIに強制します。
   - 警告（Warnings）はエラーとして扱い、一切の妥協を許しません（`-Dstrict`相当）。
2. **メモリリークと未定義動作のCI検知**:
   - Zigの `GeneralPurposeAllocator` (GPA) を活用し、CI上のテスト実行でメモリリークを厳密にチェックします（LinuxにおけるValgrindと同等の役割をGPAで担わせます）。
   - これにより、今後のWindows固有API（Win32 APIやCOMオブジェクト）の呼び出しで発生しうる解放漏れを初期段階で潰します。

### フェーズ2：フォントサブシステムのWindowsネイティブ化 (DirectWrite)
*Issue Task: Font Discovery & Font Face for Windows (DirectWrite)*

クロスプラットフォームのFreetypeから、WindowsネイティブのDirectWrite（COMベース）への移行を行います。ここでメモリ管理の真価が問われます。
1. **Font Discovery (フォント探索) の実装**:
   - `IDWriteFactory` を用いたシステムフォントの探索処理を実装します。
   - **メモリ管理戦略**: COMオブジェクトは `AddRef`/`Release` による参照カウントで管理されます。Zigの `defer` またはラッパー構造体を構築し、スコープを抜ける際に確実に `Release` が呼ばれる設計を強制します。リークしたCOMオブジェクトは長期稼働するターミナルにおいて致命的です。
2. **Font Rasterization (フォント描画) の実装**:
   - 探索したフォントをDirectWriteでラスタライズ（ピクセル化）します。
   - **パフォーマンスと安定性**: OS固有のサブピクセルレンダリング（ClearType）を正しく反映させます。生成されたグリフキャッシュの破棄タイミングを厳密に管理し、メモリ使用量の上限（OOM回避）を定めます。

### フェーズ3：レンダリングエンジンの最適化 (DirectX への移行準備)
*Issue Task: Use the GLFW native API to get access to Window to use DirectX*

OpenGLではなく、DirectX (Direct3D 11/12) を使ったレンダリングに向けた橋渡しを行います。
1. **ウィンドウハンドルの取得とSwapChainの構築**:
   - GLFWのネイティブAPI（`glfwGetWin32Window`）を使用して `HWND` (ウィンドウハンドル) を取得し、DXGIの `IDXGISwapChain` を初期化します。
2. **GPUリソースのライフサイクル管理**:
   - ウィンドウのサイズ変更（Resize）や、デバイスロスト（GPUドライバのクラッシュ等）が発生した際の回復処理を設計します。
   - **可用性の確保**: ターミナルはGPUクラッシュ時でも落ちてはいけません。テクスチャやバッファのリソースをすべて安全に解放し、デバイスを再初期化するフォールバック機構を構築します。

### フェーズ4：ネイティブ・アプリケーション・ランタイム (`apprt`) の構築
*Issue Task: New apprt implementation for dedicated Windows GUI, native widgets*

Ghosttyの中核である `src/apprt/` 層に、Windows専用のネイティブ実装（GLFW依存からの脱却）を追加します。
1. **Win32 API メッセージループの実装**:
   - 自前のメッセージポンプ (`GetMessage` / `DispatchMessage`) を実装し、イベントループを構築します。
2. **入力処理とスレッドセーフティ**:
   - WindowsのIME（Input Method Editor）やデッドキーの処理を正確に実装します。
   - **並行処理の厳格化**: UIスレッド（Win32メッセージ）と、PTY・I/Oを処理するバックグラウンドスレッド間のデータ受け渡しは、ミューテックスやアトミック操作で厳格に保護します。データ競合（Data Race）はターミナルの死を意味します。

### フェーズ5：堅牢なデプロイメントとパッケージング（exe化の完了）
*Issue Task: Installers, packages, whatever is necessary for a platform-native run experience*

最後に、エンドユーザーに届く `.exe` としての信頼性を保証します。
1. **静的リンクと依存関係の排除**:
   - DLL Hell（依存ライブラリのバージョン不整合）を防ぐため、可能な限りライブラリ（Zigランタイム、C依存）を静的にリンクし、単一の実行可能ファイル（Standalone `.exe`）を目指します。
2. **コード署名（Code Signing）の自動化**:
   - CIプロセス（GitHub Actions for release）にコード署名（Authenticode）を組み込みます。これによりWindows SmartScreenの警告を防ぎ、改ざんされていない信頼できる実行ファイルであることを保証します。

---

### 総括
私の設計方針では、「とりあえず動く」機能追加は許可しません。
各フェーズ（特にCOMオブジェクトの参照管理とGPUリソースの破棄、スレッド間の同期）において、**コンパイル時の型安全性と実行時のメモリリーク検査（CI）を通過したものだけ**が、次のステップに進むことを許されます。このロードマップを順守することで、GhosttyはWindows上でも最強の安定性を誇るターミナルエミュレータ（.exe）として完成します。
