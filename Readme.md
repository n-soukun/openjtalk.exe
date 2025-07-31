# OpenJTalk.exe

OpenJTalk に少し手を加えたソースコードとバイナリーを公開しています。

## ダウンロード

コンパイル済みのバイナリは [Releases](https://github.com/your-username/openjtalk.exe/releases) ページからダウンロードできます。

## ビルド方法

### 前提条件

- Windows: Visual Studio Build Tools または Visual Studio
- Linux/macOS: GCC、autotools

### Windows でのビルド

1. Visual Studio Developer Command Prompt を開く
2. HTS Engine API をビルド・インストール:
   ```cmd
   cd lib\hts_engine_API-1.10
   nmake /f Makefile.mak
   nmake /f Makefile.mak install
   ```
3. Open JTalk をビルド・インストール:
   ```cmd
   cd ..\open_jtalk-1.11
   nmake /f Makefile.mak
   nmake /f Makefile.mak install
   ```

### Linux/macOS でのビルド

1. 依存関係をインストール:

   ```bash
   # Ubuntu/Debian
   sudo apt-get install build-essential autoconf automake libtool

   # macOS
   brew install autoconf automake libtool
   ```

2. HTS Engine API をビルド・インストール:

   ```bash
   cd lib/hts_engine_API-1.10
   ./configure --prefix=/usr/local/hts_engine_API
   make && sudo make install
   ```

3. Open JTalk をビルド・インストール:
   ```bash
   cd ../open_jtalk-1.11
   ./configure --prefix=/usr/local/open_jtalk \
     --with-hts-engine-header-path=/usr/local/hts_engine_API/include \
     --with-hts-engine-library-path=/usr/local/hts_engine_API/lib
   make && sudo make install
   ```

## リリース作成

新しいリリースを作成するには:

### 自動リリース（推奨）

1. タグを作成してプッシュ:

   ```bash
   # Linux/macOS
   ./scripts/create-release.sh v1.0.0

   # Windows
   scripts\create-release.bat v1.0.0
   ```

2. GitHub Actions が自動的にビルドし、リリースを作成します

### 手動リリース

GitHub Actions の「Build and Release OpenJTalk」ワークフローを手動実行することもできます。

## CI/CD

このプロジェクトでは以下の GitHub Actions ワークフローを使用しています：

- **release.yml**: タグプッシュ時にバイナリをビルドし、GitHub Release を作成
- **build.yml**: プルリクエストや push 時にマルチプラットフォームでビルドテスト

## ライセンス

本リポジトリの全てのコードは修正 BSD ライセンス（3 条項 BSD）で配布しています。

詳しくは`LICENSE`ファイルを参照ください。
