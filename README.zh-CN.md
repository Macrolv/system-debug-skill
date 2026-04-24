# system-debug

一个独立的 Agent Skill / Claude Skill，用于系统化根因调试。

它的目标是让 AI 编程助手不要“猜一个补丁试试”，而是先收集证据、追溯根因、一次验证一个假设，并在最小验证产物证明修复有效之后，才声称问题已解决。

## 适用场景

- bug、回归问题
- 测试失败、flaky test
- 构建、CI/CD、签名、部署、集成失败
- 性能问题
- 配置、环境、缓存、权限、依赖、状态不一致
- 多次 quick fix 失败、需要重新梳理根因的场景

## Claude Code 快速安装

个人全局安装：

```bash
unzip system-debug.zip -d ~/.claude/skills
```

结果应为：

```text
~/.claude/skills/system-debug/SKILL.md
```

项目内安装：

```bash
mkdir -p .claude/skills
unzip system-debug.zip -d .claude/skills
```

结果应为：

```text
.claude/skills/system-debug/SKILL.md
```

从 GitHub 仓库安装：

```bash
git clone https://github.com/<owner>/system-debug-skill.git
cd system-debug-skill
./install.sh --user
```

安装到某个项目：

```bash
./install.sh --project /path/to/your/project
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

## 发布建议

推荐把这个仓库上传到 GitHub，然后在 Release 里附上 `system-debug.zip` 和 `checksums.txt`。别人可以直接下载 zip 上传到 Claude.ai，或者解压到 `~/.claude/skills` / `.claude/skills`。

## 安全说明

这个 skill 已加入诊断安全规则：不要打印 secrets、tokens、cookies、私钥、credentials、signing identities 或完整环境变量；需要诊断时优先打印 presence/absence、长度、数量或安全 fingerprint。

安装任何第三方 Skill 前都应该先阅读 `SKILL.md` 和脚本内容。
