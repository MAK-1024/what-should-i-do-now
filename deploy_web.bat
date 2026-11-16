@echo off
setlocal

rem Build the Flutter web bundle and deploy build\web to Vercel (production).
cd /d "%~dp0"

if not exist ".env" (
  echo [deploy_web] ERROR: .env not found. It must define SUPABASE_URL and SUPABASE_ANON_KEY.
  exit /b 1
)

echo [deploy_web] Building Flutter web (release)...
call flutter build web --release
if errorlevel 1 (
  echo [deploy_web] ERROR: flutter build web failed.
  exit /b 1
)

if not exist "build\web\vercel.json" (
  echo [deploy_web] build\web\vercel.json missing - copying web\vercel.json...
  copy /y "web\vercel.json" "build\web\vercel.json" >nul
  if errorlevel 1 (
    echo [deploy_web] ERROR: could not copy web\vercel.json.
    exit /b 1
  )
)

echo [deploy_web] Deploying build\web to Vercel...
pushd "build\web"
call npx --yes vercel --prod
set "DEPLOY_EXIT=%ERRORLEVEL%"
popd

if not "%DEPLOY_EXIT%"=="0" (
  echo [deploy_web] ERROR: Vercel deployment failed.
  exit /b %DEPLOY_EXIT%
)

echo [deploy_web] Deployment complete.
endlocal
