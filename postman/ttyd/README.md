# Web-based Git Bash Terminal (ttyd)

这是一个在 Windows 机器上运行的 Node.js 网页终端服务。通过该程序，你可以在浏览器中访问并直接控制 Windows 本机的 Git Bash。

## 目录结构

```
Lead-93/postman/ttyd/
├── package.json        # 项目依赖配置
├── server.js          # Node.js 后端服务 (Express + WebSocket + node-pty)
├── start.bat           # Windows 一键启动脚本
├── README.md           # 说明文档
└── public/
    └── index.html      # 前端终端页面 (xterm.js)
```

## 快速使用说明 (Windows)

### 1. 前置条件
- 已安装 Node.js (推荐 v16 以上)
- 已安装 Git for Windows (默认路径：`C:\Program Files\Git\bin\bash.exe`)

### 2. 启动服务
你可以直接双击运行 `start.bat`，或者在命令行中执行：

```cmd
cd Lead-93\postman\ttyd
npm install
npm start
```

### 3. 打开网页使用
打开浏览器访问：[http://127.0.0.1:7681](http://127.0.0.1:7681)

你将看到一个暗黑主题的 Git Bash 交互式终端，支持：
- 完整命令交互与 Shell 彩色显示
- 自动适配浏览器窗口尺寸调整 (Resize)
- 支持复制/粘贴、Tab 补全、Vim 编辑器等

## 高级配置

### 修改监听端口与主机
默认监听 `127.0.0.1:7681`（仅限本机访问）。如果需要允许局域网访问，可设置环境变量：

```cmd
set PORT=8080
set HOST=0.0.0.0
node server.js
```

> **安全提示**：若监听 `0.0.0.0` 开放内网访问，请确保网络安全或在后端增加身份认证逻辑（如 Basic Auth）。
