# 08：发布到 GitHub

## 推荐仓库名

```text
hrio-cc-switch-guide
```

## 网页创建仓库

1. 登录 [GitHub](https://github.com/login)。
2. 打开 [New repository](https://github.com/new)。
3. Repository name 填 `hrio-cc-switch-guide`。
4. 可见性按公司要求选 Public 或 Private。
5. 不要勾选自动创建 README、.gitignore 或 License，因为本地已经有文件。
6. 点击 Create repository。

## 推送本地仓库

把 `YOUR_GITHUB_NAME` 换成你的 GitHub 用户名或组织名：

```powershell
git remote add origin https://github.com/YOUR_GITHUB_NAME/hrio-cc-switch-guide.git
git push -u origin main
```

如果使用 SSH：

```powershell
git remote add origin git@github.com:YOUR_GITHUB_NAME/hrio-cc-switch-guide.git
git push -u origin main
```

## 发布前检查

```powershell
git status
git log --oneline -1
rg -n --hidden -g '!*.png' -g '!*.jpg' -g '!*.jpeg' "sk-[A-Za-z0-9_-]{16,}" .
```

最后一条命令不应找到真实 Key。示例中的 `YOUR_API_KEY` 可以保留。

## Public 还是 Private

- Public：适合公开教程；必须确认没有公司内部域名、真实 Key、客户信息和非公开截图。
- Private：适合内部部署流程或含公司专属配置的版本。

本教程当前只包含公开域名、占位符和公开/官方截图，可以公开发布；最终可见性仍由仓库所有者决定。

