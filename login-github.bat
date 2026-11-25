@echo off
chcp 65001 >nul
cd /d "%~dp0"
cls
echo.
echo ========================================
echo   GitHub ログイン（1回だけ）
echo ========================================
echo.
echo 次に 8桁のコード（例: ABCD-1234）が表示されます。
echo 出ないときは Ctrl+V で貼り付けて、クリップボードを確認してください。
echo.
echo 1. 下に出たコードをコピー
echo 2. ブラウザで開く: https://github.com/login/device
echo 3. コードを入力して「Authorize」を押す
echo.
echo --- ここから下にコードが出ます ---
echo.
gh auth login -h github.com -p https -w
echo.
if errorlevel 1 (
  echo ログインに失敗しました。もう一度このファイルを実行してください。
) else (
  echo ログインできました。deploy-github-pages.bat を実行してください。
)
echo.
pause