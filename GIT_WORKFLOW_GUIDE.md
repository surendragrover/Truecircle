# Git वर्कफ़्लो गाइड / Git Workflow Guide

TrueCircle के लिए संपूर्ण Git वर्कफ़्लो दस्तावेज़  
Complete Git Workflow Documentation for TrueCircle

## 📋 विषय-सूची / Table of Contents

1. [Git शुरुआत / Git Setup](#git-setup)
2. [Branch रणनीति / Branch Strategy](#branch-strategy)
3. [दैनिक वर्कफ़्लो / Daily Workflow](#daily-workflow)
4. [Commit दिशानिर्देश / Commit Guidelines](#commit-guidelines)
5. [Pull Request प्रक्रिया / Pull Request Process](#pull-request-process)
6. [Code Review / कोड समीक्षा](#code-review)
7. [सामान्य Git कमांड्स / Common Git Commands](#common-commands)
8. [समस्या निवारण / Troubleshooting](#troubleshooting)

---

## 🚀 Git शुरुआत / Git Setup

### प्रारंभिक सेटअप / Initial Setup

```bash
# Git install करें (यदि पहले से installed नहीं है)
# Install Git (if not already installed)
# Download from: https://git-scm.com/downloads

# Git version check करें
git --version

# Git configure करें
git config --global user.name "आपका नाम / Your Name"
git config --global user.email "your.email@example.com"

# Editor set करें (optional)
git config --global core.editor "code --wait"  # VS Code
git config --global core.editor "vim"           # Vim

# Line endings (Windows users के लिए)
git config --global core.autocrlf true

# Configuration देखें
git config --list
```

### Repository Clone करना / Cloning Repository

```bash
# Main repository clone करें
git clone https://github.com/surendragrover/Truecircle.git
cd Truecircle

# या अपना fork clone करें
# Or clone your fork
git clone https://github.com/YOUR_USERNAME/Truecircle.git
cd Truecircle

# Upstream remote add करें
git remote add upstream https://github.com/surendragrover/Truecircle.git

# Remotes verify करें
git remote -v
# Output:
# origin    https://github.com/YOUR_USERNAME/Truecircle.git (fetch)
# origin    https://github.com/YOUR_USERNAME/Truecircle.git (push)
# upstream  https://github.com/surendragrover/Truecircle.git (fetch)
# upstream  https://github.com/surendragrover/Truecircle.git (push)
```

---

## 🌳 Branch रणनीति / Branch Strategy

### Branch संरचना / Branch Structure

```
main (production-ready code)
│
├── feature/     (नई सुविधाएं / New features)
│   ├── feature/cultural-ai-enhancement
│   ├── feature/hindi-support
│   └── feature/festival-notifications
│
├── fix/         (बग फिक्स / Bug fixes)
│   ├── fix/authentication-error
│   ├── fix/ui-rendering-issue
│   └── fix/hive-adapter-crash
│
├── docs/        (डॉक्यूमेंटेशन / Documentation)
│   ├── docs/api-documentation
│   └── docs/user-guide-hindi
│
├── refactor/    (कोड सुधार / Code improvements)
│   ├── refactor/service-locator
│   └── refactor/optimize-ai-calls
│
└── hotfix/      (Critical fixes)
    └── hotfix/security-patch
```

### Branch नाम / Branch Names

#### अच्छे उदाहरण / Good Examples ✅

```bash
feature/add-gemini-nano-android
feature/cultural-festival-recommendations
fix/firebase-auth-timeout
fix/hive-registration-error
docs/update-contributing-guide
refactor/optimize-emotion-analysis
hotfix/critical-privacy-leak
```

#### बुरे उदाहरण / Bad Examples ❌

```bash
my-changes
fix
update
test-branch
temp
```

### Branch बनाना और Switch करना / Creating and Switching Branches

```bash
# नया branch बनाएं और switch करें
# Create new branch and switch to it
git checkout -b feature/your-feature-name

# या (Git 2.23+)
git switch -c feature/your-feature-name

# मौजूदा branch में switch करें
# Switch to existing branch
git checkout main
git switch main

# सभी branches देखें
# View all branches
git branch -a

# Current branch देखें
git branch --show-current
```

---

## 💼 दैनिक वर्कफ़्लो / Daily Workflow

### 1. दिन की शुरुआत / Starting Your Day

```bash
# Main branch पर जाएं
git checkout main

# Upstream से latest changes pull करें
git pull upstream main

# या अपने fork को update करें
git pull origin main

# अपने feature branch पर जाएं
git checkout feature/your-feature

# Main से latest changes merge करें
git merge main

# या rebase करें (preferred)
git rebase main
```

### 2. काम करना / Working on Code

```bash
# Changes देखें
git status

# Modified files देखें
git diff

# Specific file का diff देखें
git diff path/to/file.dart

# Changes stage करें
git add path/to/file.dart

# या सभी changes stage करें
git add .

# Interactive staging (recommended)
git add -p

# Changes commit करें
git commit -m "feat(ai): add Gemini Nano support"

# या detailed commit message के साथ
git commit
# Editor खुलेगा detailed message के लिए
```

### 3. Changes को Remote पर Push करना / Pushing Changes

```bash
# पहली बार push करें
git push -u origin feature/your-feature

# बाद के pushes
git push

# Force push (सावधानी से!)
git push --force-with-lease
```

### 4. दिन का अंत / End of Day

```bash
# सभी changes commit करें
git add .
git commit -m "wip: work in progress at end of day"

# Remote पर push करें (backup)
git push

# या changes को stash करें
git stash save "work in progress"
```

---

## 📝 Commit दिशानिर्देश / Commit Guidelines

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types / प्रकार

| Type | विवरण / Description | Example |
|------|---------------------|---------|
| `feat` | नई सुविधा / New feature | `feat(ai): add Gemini Nano integration` |
| `fix` | बग फिक्स / Bug fix | `fix(auth): resolve Firebase timeout` |
| `docs` | डॉक्यूमेंटेशन / Documentation | `docs(readme): update installation steps` |
| `style` | फॉर्मेटिंग / Code formatting | `style(ui): improve button styling` |
| `refactor` | कोड सुधार / Code improvement | `refactor(services): optimize AI calls` |
| `test` | टेस्ट्स / Tests | `test(emotion): add unit tests` |
| `chore` | टूल/बिल्ड / Build/tools | `chore(deps): update dependencies` |
| `perf` | परफॉर्मेंस / Performance | `perf(ui): reduce widget rebuilds` |
| `ci` | CI/CD | `ci(actions): add release workflow` |

### Scopes / क्षेत्र

```
ai, auth, ui, emotion, festival, contact, privacy, 
service, model, widget, android, ios, web
```

### उदाहरण / Examples

#### अच्छे Commits ✅

```bash
# Feature
git commit -m "feat(cultural-ai): add festival recommendation engine"

# Bug fix
git commit -m "fix(hive): resolve adapter registration timing issue"

# Documentation
git commit -m "docs(contributing): add Hindi translation"

# Refactoring with detailed message
git commit -m "refactor(services): extract AI service interface

- Create OnDeviceAIService interface
- Implement platform-specific services
- Add service locator pattern
- Update all AI service consumers

Closes #123"

# Multiple related changes
git commit -m "feat(privacy): implement sample mode

- Add PermissionManager.isSampleMode flag
- Create JsonDataService for demo data
- Update all permission checks
- Add privacy mode UI indicator

This ensures Google Play Store compliance"
```

#### बुरे Commits ❌

```bash
git commit -m "update"
git commit -m "fix bug"
git commit -m "changes"
git commit -m "wip"
git commit -m "asdfasdf"
```

### Commit Best Practices

1. **छोटे, focused commits करें / Make small, focused commits**
   ```bash
   # अच्छा / Good
   git add lib/services/ai_service.dart
   git commit -m "feat(ai): add AI service interface"
   
   git add lib/services/android_ai_service.dart
   git commit -m "feat(ai): implement Android AI service"
   
   # बुरा / Bad
   git add .
   git commit -m "add all AI stuff"
   ```

2. **Present tense में लिखें / Write in present tense**
   ```bash
   # अच्छा / Good
   "add feature" ✅
   "fix bug" ✅
   
   # बुरा / Bad
   "added feature" ❌
   "fixed bug" ❌
   ```

3. **50 characters तक subject / Subject under 50 characters**
   ```bash
   # अच्छा / Good
   "feat(ai): add Gemini Nano support"
   
   # बुरा / Bad
   "feat(ai): add support for Google's Gemini Nano on-device AI model with offline capabilities"
   ```

---

## 🔄 Pull Request प्रक्रिया / Pull Request Process

### 1. PR बनाने से पहले / Before Creating PR

```bash
# Upstream से sync करें
git checkout main
git pull upstream main

# अपने branch में merge करें
git checkout feature/your-feature
git merge main

# या rebase करें
git rebase main

# Tests run करें
flutter test

# Code analyze करें
flutter analyze

# Format check करें
dart format .

# Build verify करें
flutter build apk --debug
```

### 2. PR बनाना / Creating PR

```bash
# Changes push करें
git push origin feature/your-feature

# GitHub पर जाएं और "Compare & pull request" click करें
# Go to GitHub and click "Compare & pull request"
```

### 3. PR Template भरें / Fill PR Template

```markdown
## विवरण / Description
यह PR Gemini Nano को Android में integrate करता है।
This PR integrates Gemini Nano in Android.

## परिवर्तन का प्रकार / Type of Change
- [x] ✨ New feature

## संबंधित इश्यू / Related Issue
Closes #45

## परिवर्तन / Changes Made
- AndroidGeminiNanoService implementation
- Platform channel setup
- Kotlin native code integration
- Service locator registration

## स्क्रीनशॉट / Screenshots
[Add screenshots]

## टेस्टिंग / Testing
- [x] Tested on Android 14
- [x] Tested on Samsung Galaxy S23
- [x] Unit tests pass
- [x] Privacy Mode tested

## चेकलिस्ट / Checklist
- [x] Code follows style guidelines
- [x] Self-review completed
- [x] Documentation updated
- [x] Tests added
- [x] All tests pass
- [x] Build succeeds
```

### 4. Review Process

```bash
# Review comments के response में changes करें
git add .
git commit -m "refactor(ai): address review comments"
git push

# Additional commits automatically PR में add होंगे
# Additional commits will automatically be added to PR
```

### 5. Squash Commits (Optional)

```bash
# Multiple commits को एक में combine करें
# Combine multiple commits into one
git rebase -i HEAD~3  # Last 3 commits

# Editor में:
# pick abc123 feat(ai): add service
# squash def456 fix(ai): fix initialization
# squash ghi789 refactor(ai): improve code

# Message edit करें और save करें
```

---

## 👀 Code Review / कोड समीक्षा

### Reviewer के लिए / For Reviewers

```bash
# PR checkout करें
git fetch origin
git checkout origin/feature/their-feature

# या PR number से
gh pr checkout 123  # GitHub CLI

# Changes देखें
git log main..HEAD
git diff main

# Local में test करें
flutter run -d chrome
flutter test
flutter analyze
```

### Review Comments

#### अच्छे Comments ✅

```
"यह implementation अच्छा है, लेकिन null safety add करें।
This implementation looks good, but please add null safety."

"Privacy Mode check add करना न भूलें line 45 पर।
Don't forget to add Privacy Mode check at line 45."

"इस function के लिए unit test add कर सकते हैं?
Can you add a unit test for this function?"
```

#### बुरे Comments ❌

```
"This is wrong." ❌
"Fix this." ❌
"Bad code." ❌
```

---

## 🛠️ सामान्य Git कमांड्स / Common Git Commands

### Status और History / Status and History

```bash
# Current status
git status

# Short status
git status -s

# Commit history
git log

# Pretty log
git log --oneline --graph --all --decorate

# Specific file history
git log -- path/to/file.dart

# Who changed what
git blame path/to/file.dart
```

### Changes देखना / Viewing Changes

```bash
# Unstaged changes
git diff

# Staged changes
git diff --staged

# Between branches
git diff main feature/my-feature

# Specific file
git diff main -- lib/services/ai_service.dart

# File at specific commit
git show abc123:lib/services/ai_service.dart
```

### Undoing Changes / Changes को Undo करना

```bash
# Unstage file
git reset HEAD path/to/file.dart

# Discard working directory changes
git checkout -- path/to/file.dart
# या (Git 2.23+)
git restore path/to/file.dart

# Undo last commit (keep changes)
git reset --soft HEAD^

# Undo last commit (discard changes) - सावधानी!
git reset --hard HEAD^

# Revert a commit (create new commit)
git revert abc123
```

### Stashing / अस्थायी सहेजना

```bash
# Current changes को stash करें
git stash

# Message के साथ stash
git stash save "work in progress on AI feature"

# Stash list देखें
git stash list

# Stash apply करें
git stash apply

# Specific stash apply करें
git stash apply stash@{1}

# Stash pop करें (apply + delete)
git stash pop

# Stash delete करें
git stash drop stash@{0}

# सभी stashes clear करें
git stash clear
```

### Syncing / समन्वयन

```bash
# Fetch upstream changes
git fetch upstream

# Fetch all remotes
git fetch --all

# Pull and merge
git pull upstream main

# Pull and rebase
git pull --rebase upstream main

# Push to remote
git push origin feature/my-feature

# Force push (सावधानी से!)
git push --force-with-lease origin feature/my-feature
```

### Branches / शाखाएं

```bash
# सभी branches list करें
git branch -a

# Branch बनाएं
git branch feature/new-feature

# Branch delete करें
git branch -d feature/old-feature

# Force delete
git branch -D feature/old-feature

# Remote branch delete करें
git push origin --delete feature/old-feature

# Branch rename करें
git branch -m old-name new-name
```

### Merging और Rebasing

```bash
# Merge branch
git checkout main
git merge feature/my-feature

# Merge with no fast-forward
git merge --no-ff feature/my-feature

# Abort merge
git merge --abort

# Rebase
git checkout feature/my-feature
git rebase main

# Continue rebase
git rebase --continue

# Skip commit during rebase
git rebase --skip

# Abort rebase
git rebase --abort

# Interactive rebase
git rebase -i HEAD~3
```

---

## 🔧 समस्या निवारण / Troubleshooting

### सामान्य समस्याएं / Common Issues

#### 1. Merge Conflicts / मर्ज संघर्ष

```bash
# Conflict होने पर
git status  # Conflicted files देखें

# Files manually edit करें और conflicts resolve करें
# Markers: <<<<<<<, =======, >>>>>>>

# Resolved files को stage करें
git add resolved-file.dart

# Merge continue करें
git commit

# या merge abort करें
git merge --abort
```

#### 2. Wrong Branch पर काम किया / Worked on Wrong Branch

```bash
# Changes को stash करें
git stash

# Correct branch पर switch करें
git checkout correct-branch

# Stash apply करें
git stash pop
```

#### 3. Accidentally Committed to Main

```bash
# Main पर हैं और commit कर दिया
git log --oneline  # Commit SHA note करें

# New branch बनाएं
git branch feature/my-feature

# Main को reset करें
git reset --hard HEAD^

# Feature branch पर switch करें
git checkout feature/my-feature
```

#### 4. Lost Commits / गुम Commits

```bash
# Reflog देखें (Git garbage collector)
git reflog

# Lost commit को recover करें
git checkout abc123
git checkout -b recovered-branch
```

#### 5. Large Files Accidentally Committed

```bash
# File को history से remove करें
git filter-branch --tree-filter 'rm -f path/to/large-file' HEAD

# या BFG Repo-Cleaner use करें (recommended)
# Download from: https://rtyley.github.io/bfg-repo-cleaner/
```

### Useful Aliases / उपयोगी उपनाम

```bash
# Add to ~/.gitconfig
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.unstage 'reset HEAD --'
git config --global alias.last 'log -1 HEAD'
git config --global alias.visual 'log --oneline --graph --all --decorate'

# Use करें
git st
git co main
git visual
```

---

## 📚 अतिरिक्त संसाधन / Additional Resources

### Git Documentation

- [Official Git Documentation](https://git-scm.com/doc)
- [Git Book (Hindi)](https://git-scm.com/book/hi/v2)
- [GitHub Guides](https://guides.github.com/)

### TrueCircle Specific

- [CONTRIBUTING.md](CONTRIBUTING.md) - योगदान दिशानिर्देश
- [TrueCircle Complete Documentation](TrueCircle_Complete_Documentation.md)
- [Privacy Demo Mode Guide](PRIVACY_DEMO_MODE_GUIDE.md)

### Learning Resources

- [Learn Git Branching](https://learngitbranching.js.org/)
- [Git Immersion](http://gitimmersion.com/)
- [Atlassian Git Tutorials](https://www.atlassian.com/git/tutorials)

---

## 🎯 Best Practices Summary / सारांश

### ✅ DO / करें

- ✅ Small, focused commits करें
- ✅ Meaningful commit messages लिखें
- ✅ अक्सर upstream से sync करें
- ✅ Code review में भाग लें
- ✅ Tests लिखें और run करें
- ✅ Documentation update करें
- ✅ Privacy Mode में test करें
- ✅ Branch naming conventions follow करें

### ❌ DON'T / न करें

- ❌ Main में direct commit न करें
- ❌ Large files commit न करें
- ❌ Secrets या API keys commit न करें
- ❌ Generated files commit न करें
- ❌ Force push public branches पर न करें
- ❌ "wip" या meaningless commits न करें
- ❌ Unrelated changes को एक commit में न करें

---

**Happy Git-ing! 🚀 आनंदमय Git उपयोग! 🚀**

_For questions or help, please open an issue or discussion on GitHub._  
_प्रश्न या सहायता के लिए, कृपया GitHub पर issue या discussion खोलें।_
