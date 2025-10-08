# Git त्वरित संदर्भ / Git Quick Reference

TrueCircle के लिए सबसे उपयोगी Git commands  
Most useful Git commands for TrueCircle

## 🚀 शुरुआत / Getting Started

```bash
# Repository clone करें / Clone repository
git clone https://github.com/surendragrover/Truecircle.git

# Upstream add करें / Add upstream
git remote add upstream https://github.com/surendragrover/Truecircle.git

# Status check करें / Check status
git status

# Configuration देखें / View configuration
git config --list
```

## 🌳 Branches / शाखाएं

```bash
# नया branch / New branch
git checkout -b feature/my-feature

# Branch switch करें / Switch branch
git checkout main
git switch main  # Git 2.23+

# Branches list / Branch सूची
git branch -a

# Branch delete / Branch हटाएं
git branch -d feature/old-feature
```

## 📝 Commits / कमिट्स

```bash
# Changes stage करें / Stage changes
git add .
git add path/to/file.dart
git add -p  # Interactive

# Commit करें / Commit
git commit -m "feat(ai): add Gemini Nano"

# Commit amend / Commit सुधारें
git commit --amend

# Last commit undo / अंतिम commit पूर्ववत
git reset --soft HEAD^
```

## 🔄 Syncing / समन्वयन

```bash
# Fetch / फेच
git fetch upstream

# Pull / पुल
git pull upstream main

# Pull with rebase
git pull --rebase upstream main

# Push / पुश
git push origin feature/my-feature

# Force push (सावधानी!)
git push --force-with-lease
```

## 🔍 Viewing / देखना

```bash
# Status / स्थिति
git status
git status -s  # Short format

# Diff / अंतर
git diff
git diff --staged
git diff main feature/my-feature

# Log / लॉग
git log
git log --oneline
git log --graph --all --decorate

# Show / दिखाएं
git show abc123
git show abc123:path/to/file.dart
```

## ↩️ Undoing / पूर्ववत करना

```bash
# Unstage / Unstage करें
git reset HEAD file.dart

# Discard changes / Changes छोड़ें
git checkout -- file.dart
git restore file.dart  # Git 2.23+

# Undo commit (keep changes)
git reset --soft HEAD^

# Undo commit (discard changes)
git reset --hard HEAD^

# Revert / Revert करें
git revert abc123
```

## 💾 Stashing / स्टैशिंग

```bash
# Stash / स्टैश करें
git stash
git stash save "message"

# List / सूची
git stash list

# Apply / लागू करें
git stash apply
git stash pop

# Drop / हटाएं
git stash drop
git stash clear
```

## 🔀 Merging / मर्जिंग

```bash
# Merge / मर्ज
git checkout main
git merge feature/my-feature

# Merge abort / मर्ज रद्द करें
git merge --abort

# Rebase / रीबेस
git checkout feature/my-feature
git rebase main

# Interactive rebase
git rebase -i HEAD~3

# Continue / जारी रखें
git rebase --continue

# Abort / रद्द करें
git rebase --abort
```

## 🏷️ Tags / टैग्स

```bash
# Create tag / टैग बनाएं
git tag v1.0.0

# Annotated tag
git tag -a v1.0.0 -m "Version 1.0.0"

# List tags / टैग सूची
git tag

# Push tag / टैग पुश
git push origin v1.0.0
git push --tags  # All tags
```

## 🔧 Advanced / उन्नत

```bash
# Cherry-pick / चेरी-पिक
git cherry-pick abc123

# Reflog / रीफ़लॉग
git reflog

# Blame / दोष
git blame path/to/file.dart

# Clean / साफ़ करें
git clean -fd  # Remove untracked files

# Bisect / बाइसेक्ट
git bisect start
git bisect bad
git bisect good abc123
```

## 📦 TrueCircle Specific

### नई सुविधा जोड़ना / Adding New Feature

```bash
# 1. Upstream से sync करें
git checkout main
git pull upstream main

# 2. Feature branch बनाएं
git checkout -b feature/cultural-ai

# 3. Changes करें और commit करें
git add .
git commit -m "feat(ai): add cultural AI features"

# 4. Push करें
git push origin feature/cultural-ai

# 5. GitHub पर PR बनाएं
```

### Bug Fix करना / Fixing Bug

```bash
# 1. Bug fix branch बनाएं
git checkout -b fix/firebase-auth

# 2. Fix implement करें
# ... make changes ...

# 3. Test करें
flutter test

# 4. Commit और push
git add .
git commit -m "fix(auth): resolve Firebase timeout issue"
git push origin fix/firebase-auth
```

### Code Review के बाद Changes / Changes After Review

```bash
# 1. Review comments के अनुसार changes करें
# ... make changes ...

# 2. Commit करें
git add .
git commit -m "refactor(ai): address review comments"

# 3. Push करें (automatically PR में add होगा)
git push
```

## 🎯 Commit Message Examples

```bash
# Feature
git commit -m "feat(ai): add Gemini Nano integration"
git commit -m "feat(ui): add cultural festival cards"

# Bug Fix
git commit -m "fix(auth): resolve login timeout"
git commit -m "fix(hive): fix adapter registration"

# Documentation
git commit -m "docs(readme): add Hindi instructions"
git commit -m "docs(api): update API documentation"

# Refactoring
git commit -m "refactor(services): optimize AI calls"
git commit -m "refactor(ui): improve card layout"

# Testing
git commit -m "test(emotion): add unit tests"
git commit -m "test(integration): add e2e tests"

# Chore
git commit -m "chore(deps): update Flutter to 3.35.4"
git commit -m "chore(build): update build config"
```

## ⚡ Aliases / उपनाम

Add to `~/.gitconfig`:

```bash
[alias]
    st = status
    co = checkout
    br = branch
    ci = commit
    unstage = reset HEAD --
    last = log -1 HEAD
    visual = log --oneline --graph --all --decorate
    
    # TrueCircle specific
    sync = !git checkout main && git pull upstream main
    cleanup = !git branch --merged | grep -v \"\\*\" | xargs -n 1 git branch -d
```

Usage:
```bash
git st       # instead of git status
git co main  # instead of git checkout main
git visual   # pretty log
git sync     # sync with upstream
```

## 🚨 Common Mistakes / सामान्य गलतियां

### ❌ गलत / Wrong

```bash
git commit -m "fix"
git commit -m "update"
git commit -m "changes"
git push -f origin main  # Force push to main!
git add .  # Without checking
```

### ✅ सही / Correct

```bash
git commit -m "fix(auth): resolve Firebase timeout"
git commit -m "feat(ui): add festival cards"
git status  # Check first
git add -p  # Interactive staging
git push --force-with-lease  # Safer force push
```

## 💡 Pro Tips / विशेषज्ञ सुझाव

1. **हमेशा छोटे commits करें** / Always make small commits
2. **Meaningful messages लिखें** / Write meaningful messages
3. **अक्सर sync करें** / Sync frequently
4. **Main पर direct commit न करें** / Don't commit directly to main
5. **Tests चलाएं commit से पहले** / Run tests before committing

## 🔗 Quick Links / त्वरित लिंक

- [Full Git Workflow Guide](GIT_WORKFLOW_GUIDE.md)
- [Contributing Guidelines](../CONTRIBUTING.md)
- [TrueCircle Documentation](../TrueCircle_Complete_Documentation.md)

---

**Keep this handy while working!** 🚀  
**काम करते समय इसे पास रखें!** 🚀

_For detailed explanations, see [GIT_WORKFLOW_GUIDE.md](GIT_WORKFLOW_GUIDE.md)_  
_विस्तृत व्याख्या के लिए, [GIT_WORKFLOW_GUIDE.md](GIT_WORKFLOW_GUIDE.md) देखें_
