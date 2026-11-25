$ErrorActionPreference = "Stop"
$Root = $PSScriptRoot
$Port = 8765
$Cloudflared = Join-Path $Root "tools\cloudflared.exe"

if (-not (Test-Path $Cloudflared)) {
  Write-Host "cloudflared がありません。tools\cloudflared.exe を用意してください。"
  exit 1
}

$null = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
if ($LASTEXITCODE -ne 0) {
  Start-Process -FilePath "python" -ArgumentList "-m", "http.server", "$Port" -WorkingDirectory $Root -WindowStyle Minimized
  Start-Sleep -Seconds 1
}

Write-Host ""
Write-Host "スマホ用の公開URLを作成しています..."
Write-Host "表示された https://....trycloudflare.com をスマホのブラウザで開いてください。"
Write-Host "このウィンドウを閉じると公開が止まります。"
Write-Host ""

& $Cloudflared tunnel --url "http://127.0.0.1:$Port"