# 👷 Deployment
 **`Link`**:

# Contributing Guidelines

Welcome to the team! To ensure a smooth workflow for our 10-member squad, please follow these strict guidelines. Chaos is not an option here!

## 🌳 Git Workflow Strategy

We use a **Feature Branch Workflow**.
- **`main`**: The integration branch. All features merge here first.

### 1. Starting a Task
Always pull the latest changes from `main` before starting:
```bash
git checkout main
git pull origin main
git checkout -b feature/your-feature-name
```

_Branch Naming Convention:_
- Features: feature/auth-login, feature/chat-ui
### 2. Committing and Pushing Your Changes
After completing your work on the feature branch, stage, commit, and push your changes to GitHub:
```bash
git add .
git commit -m "Your descriptive commit message here"
git push origin feature/your-feature-name
```

### 2. Committing Changes

We follow Conventional Commits. Your commit message must be clear

### 3. Pull Requests (PR)

When your task is done:

1. Push your branch to GitHub.

2. Open a Pull Request to the `main` branch .


## ⚠️ Important Notes

- Assets: Add images to assets/images and run flutter pub get.

