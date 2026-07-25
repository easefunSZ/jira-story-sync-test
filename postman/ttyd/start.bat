@echo off
echo ===================================================
echo  Starting Web Git Bash Terminal (ttyd node.js service)
echo ===================================================

cd /d "%~dp0"

IF NOT EXIST node_modules (
    echo [INFO] Installing npm dependencies...
    npm install
)

echo [INFO] Launching Web Terminal server on http://127.0.0.1:7681 ...
node server.js

pause
