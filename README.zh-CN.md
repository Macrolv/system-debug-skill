# system-debug

一个独立的 Agent Skill / Claude Skill，用于系统化根因调试。

它的目标是让 AI 编程助手不要“猜一个补丁试试”，而是先收集证据、追溯根因、一次验证一个假设，并在最小验证产物证明修复有效之后，才声称问题已解决。

## 一行命令安装

### macOS / Linux / WSL

安装到个人 Claude Code，全局可用：

```bash
curl -fsSL https://raw.githubusercontent.com/Macrolv/system-debug-skill/main/scripts/install-remote.sh | bash
```

安装到当前项目，进入项目根目录后执行：

```bash
curl -fsSL https://raw.githubusercontent.com/Macrolv/system-debug-skill/main/scripts/install-remote.sh | bash -s -- --project .
```

覆盖已有安装：

```bash
curl -fsSL https://raw.githubusercontent.com/Macrolv/system-debug-skill/main/scripts/install-remote.sh | bash -s -- --user --force
```

安装指定分支或版本：

```bash
curl -fsSL https://raw.githubusercontent.com/Macrolv/system-debug-skill/main/scripts/install-remote.sh | bash -s -- --ref v1.0.0 --force
```

### Windows PowerShell

安装到个人 Claude Code，全局可用：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "$u='https://raw.githubusercontent.com/Macrolv/system-debug-skill/main/scripts/install-remote.ps1'; $p=Join-Path $env:TEMP 'install-system-debug.ps1'; Invoke-WebRequest -UseBasicParsing $u -OutFile $p; & $p -Scope User"
```

安装到某个项目：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "$u='https://raw.githubusercontent.com/Macrolv/system-debug-skill/main/scripts/install-remote.ps1'; $p=Join-Path $env:TEMP 'install-system-debug.ps1'; Invoke-WebRequest -UseBasicParsing $u -OutFile $p; & $p -Scope Project -ProjectPath 'C:\path\to\project'"
```

覆盖已有安装：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "$u='https://raw.githubusercontent.com/Macrolv/system-debug-skill/main/scripts/install-remote.ps1'; $p=Join-Path $env:TEMP 'install-system-debug.ps1'; Invoke-WebRequest -UseBasicParsing $u -OutFile $p; & $p -Scope User -Force"
```

验证结果：

```text
~/.claude/skills/system-debug/SKILL.md                 # macOS/Linux 个人安装
.claude/skills/system-debug/SKILL.md                   # 项目安装
%USERPROFILE%\.claude\skills\system-debug\SKILL.md   # Windows 个人安装
```

测试调用：

```text
/system-debug diagnose why this test is failing
```

## 适用场景

- bug、回归问题
- 测试失败、flaky test
- 构建、CI/CD、签名、部署、集成失败
- 性能问题
- 配置、环境、缓存、权限、依赖、状态不一致
- 多次 quick fix 失败、需要重新梳理根因的场景

它支持三种模式：

- **Triage Mode**：先理解错误、失败或日志，不急着改代码。
- **Full Debug Mode**：在提出或应用修复前，完成根因调查。
- **Incident Mitigation Mode**：生产、数据或安全风险紧急时，先做可逆的临时止血，再继续根因调查。

## 从 Release zip 安装

下载 GitHub Release 里的 `system-debug.zip`。

个人全局安装：

```bash
unzip system-debug.zip -d ~/.claude/skills
```

项目内安装：

```bash
mkdir -p .claude/skills
unzip system-debug.zip -d .claude/skills
```

## Claude.ai 上传

上传 `system-debug.zip`。它已经按要求打包为：

```text
system-debug.zip
└── system-debug/
    ├── SKILL.md
    └── ...
```

上传并启用后，可以这样测试：

```text
Use system-debug to diagnose this failing test before changing code.
```

## 从 GitHub 仓库安装

```bash
git clone https://github.com/Macrolv/system-debug-skill.git
cd system-debug-skill
./install.sh --user
```

安装到某个项目：

```bash
./install.sh --project /path/to/your/project
```

Windows PowerShell：

```powershell
.\install.ps1 -Scope User
```

## 发布建议

推荐把这个仓库上传到 GitHub，并在 Release 里附上 `system-debug.zip` 和 `checksums.txt`。别人既可以用一行命令安装到 Claude Code，也可以直接下载 zip 上传到 Claude.ai。

## 安全说明

这个 skill 已加入诊断安全规则：不要打印 secrets、tokens、cookies、私钥、credentials、signing identities 或完整环境变量；需要诊断时优先打印 presence/absence、长度、数量或安全 fingerprint。

安装任何第三方 Skill 前都应该先阅读 `SKILL.md` 和脚本内容。
