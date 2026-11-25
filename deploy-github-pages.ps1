$ErrorActionPreference = "Stop"
$Root = "C:\Users\user\Desktop\coupon-demo"
$RepoName = "coupon-demo"
Set-Location $Root

function Test-GhLoggedIn {
  $prev = $ErrorActionPreference
  $ErrorActionPreference = "SilentlyContinue"
  gh auth status 2>$null | Out-Null
  $ok = ($LASTEXITCODE -eq 0)
  $ErrorActionPreference = $prev
  return $ok
}

Write-Host "GitHub Pages へ公開します（PCを切っても24時間表示）"
Write-Host ""

if (-not (Test-GhLoggedIn)) {
  Write-Host ""
  Write-Host "GitHub に未ログインです。"
  Write-Host "先に同じフォルダの login-github.bat をダブルクリックしてログインしてください。"
  Write-Host "（8桁コードが画面に出ない場合は Ctrl+V で貼り付け）"
  Write-Host "https://github.com/login/device"
  Write-Host ""
  exit 1
}

if (-not (Test-GhLoggedIn)) {
  Write-Host ""
  Write-Host "ログインできませんでした。ブラウザでの認証を完了してから、もう一度実行してください。"
  exit 1
}

$User = gh api user -q .login
if (-not $User) {
  Write-Host "GitHub アカウント情報を取得できませんでした。"
  exit 1
}
Write-Host "アカウント: $User"

git rev-parse --is-inside-work-tree 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) {
  Write-Host "git リポジトリがありません。"
  exit 1
}

$remotes = @(git remote)
if ($remotes.Count -eq 0) {
  Write-Host "GitHub リポジトリを作成しています..."
  gh repo create $RepoName --public --source . --remote origin --push
  if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
} else {
  Write-Host "GitHub へ送信中..."
  git push -u origin main
  if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

Write-Host "GitHub Pages を有効化しています..."
$prev = $ErrorActionPreference
$ErrorActionPreference = "SilentlyContinue"
gh api -X POST "/repos/$User/$RepoName/pages" `
  -f build_type=legacy `
  -f "source[branch]=main" `
  -f "source[path]=/" 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) {
  gh api -X PUT "/repos/$User/$RepoName/pages" `
    -f build_type=legacy `
    -f "source[branch]=main" `
    -f "source[path]=/" 2>$null | Out-Null
}
$ErrorActionPreference = $prev

$PagesUrl = "https://$User.github.io/$RepoName/"
Write-Host ""
Write-Host "公開URL（スマホでブックマークしてください）:"
Write-Host $PagesUrl
Write-Host ""
Write-Host "初回は 1〜3 分ほどかかることがあります。"
Write-Host "更新したときはファイルを直したあと、このバッチを再実行するか git push してください。"