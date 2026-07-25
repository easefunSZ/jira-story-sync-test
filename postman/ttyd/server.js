const express = require('express');
const expressWs = require('express-ws');
const pty = require('node-pty');
const path = require('path');
const os = require('os');
const fs = require('fs');

const app = express();
expressWs(app);

const PORT = process.env.PORT || 7681;
const HOST = process.env.HOST || '0.0.0.0'; // 默认仅限本机访问以保障安全

// 确定 Git Bash 或系统默认 Shell 的可执行文件路径
function getShellPath() {
  if (os.platform() === 'win32') {
    const gitBashPaths = [
      'C:\\Program Files\\Git\\bin\\bash.exe',
      'C:\\Program Files (x86)\\Git\\bin\\bash.exe',
      path.join(os.homedir(), 'AppData\\Local\\Programs\\Git\\bin\\bash.exe')
    ];
    for (const p of gitBashPaths) {
      if (fs.existsSync(p)) {
        return p;
      }
    }
    return 'powershell.exe'; // 回退方案
  }
  return process.env.SHELL || 'bash';
}

const shell = getShellPath();
console.log(`[TTYD] Using shell: ${shell}`);

// 静态文件服务
app.use(express.static(path.join(__dirname, 'public')));

// WebSocket 终端处理逻辑
app.ws('/ws', (ws, req) => {
  console.log('[TTYD] Client connected to terminal WebSocket');

  // 启动 PTY (伪终端)
  const ptyProcess = pty.spawn(shell, [], {
    name: 'xterm-256color',
    cols: 80,
    rows: 24,
    cwd: os.homedir(),
    env: process.env
  });

  // PTY 输出 -> 发送回前端 WebSocket
  ptyProcess.onData((data) => {
    try {
      if (ws.readyState === 1) { // OPEN
        ws.send(data);
      }
    } catch (err) {
      console.error('[TTYD] Error sending data to ws:', err.message);
    }
  });

  // 收到前端 WebSocket 消息 -> 处理输入或调整窗口大小
  ws.on('message', (msg) => {
    try {
      // 判断是否为 JSON 类型的控制指令 (如 resize)
      if (typeof msg === 'string' && msg.startsWith('{')) {
        const parsed = JSON.parse(msg);
        if (parsed.type === 'resize' && parsed.cols && parsed.rows) {
          ptyProcess.resize(parsed.cols, parsed.rows);
          return;
        }
      }
      // 普通命令输入数据
      ptyProcess.write(msg);
    } catch (err) {
      // 非 JSON 字符串或解析错误，直接作为标准输入写入
      ptyProcess.write(msg);
    }
  });

  // 会话断开处理
  ws.on('close', () => {
    console.log('[TTYD] Client disconnected, killing pty process');
    ptyProcess.kill();
  });

  ptyProcess.onExit(({ exitCode, signal }) => {
    console.log(`[TTYD] PTY process exited with code ${exitCode}`);
    if (ws.readyState === 1) {
      ws.close();
    }
  });
});

app.listen(PORT, HOST, () => {
  console.log(`====================================================`);
  console.log(` Web Git Bash Terminal running at http://${HOST}:${PORT}`);
  console.log(` Target Shell: ${shell}`);
  console.log(`====================================================`);
});
