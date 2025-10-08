# .github Directory / .github निर्देशिका

GitHub विशिष्ट फ़ाइलें और वर्कफ़्लोज़ का संग्रह  
Collection of GitHub-specific files and workflows

## 📂 संरचना / Structure

```
.github/
├── ISSUE_TEMPLATE/          # Issue templates
│   ├── bug_report.md       # बग रिपोर्ट टेम्पलेट
│   ├── feature_request.md  # फीचर अनुरोध टेम्पलेट
│   └── config.yml          # Issue template configuration
├── workflows/               # GitHub Actions workflows
│   ├── ci.yml              # Continuous Integration
│   ├── release.yml         # Release builds
│   └── demo-token-guard.yml # Security checks
├── pull_request_template.md # PR टेम्पलेट
├── copilot-instructions.md  # AI instructions
├── FUNDING.yml             # Sponsorship information
├── GIT_HOOKS_SETUP.md      # Git hooks guide
├── GIT_QUICK_REFERENCE.md  # Quick reference card
└── README.md               # This file
```

---

## 📝 फ़ाइलों का विवरण / File Descriptions

### Issue Templates (ISSUE_TEMPLATE/)

#### bug_report.md
**उद्देश्य / Purpose:** बग रिपोर्ट के लिए structured template

**उपयोग / Usage:**
- GitHub पर "New Issue" → "Bug Report" चुनें
- Template automatically भर जाएगा
- सभी sections भरें (Description, Steps, Environment, etc.)

**विशेषताएं / Features:**
- ✅ Bilingual (Hindi/English)
- ✅ Environment details section
- ✅ Privacy Mode consideration
- ✅ Screenshot placeholder
- ✅ Logs section

#### feature_request.md
**उद्देश्य / Purpose:** नई सुविधा के सुझाव के लिए template

**उपयोग / Usage:**
- GitHub पर "New Issue" → "Feature Request" चुनें
- Problem statement और solution describe करें
- Platform support और privacy impact specify करें

**विशेषताएं / Features:**
- ✅ Problem-solution format
- ✅ Use cases section
- ✅ Technical considerations
- ✅ Cultural considerations
- ✅ Priority levels

#### config.yml
**उद्देश्य / Purpose:** Issue template configuration

**फीचर्स / Features:**
- Quick links to documentation
- Contact links for discussions
- Privacy guide reference

---

### Workflows (workflows/)

#### ci.yml - Continuous Integration

**ट्रिगर्स / Triggers:**
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop`
- Manual workflow dispatch

**Jobs / कार्य:**

1. **📊 Code Analysis**
   - Flutter analyze
   - Dart format check
   - ~15 minutes

2. **🧪 Run Tests**
   - Unit tests
   - Coverage report
   - Upload to Codecov
   - ~20 minutes

3. **🤖 Build Android APK**
   - Debug APK build
   - Artifact upload
   - ~30 minutes

4. **🌐 Build Web**
   - Web release build
   - Artifact upload
   - ~20 minutes

5. **🔒 Security Checks**
   - Demo token guard
   - Secret scanning
   - ~15 minutes

6. **📋 CI Summary**
   - Generate status report
   - Always runs

**Artifacts / आर्टिफैक्ट्स:**
- `android-debug-apk` (7 days retention)
- `web-build` (7 days retention)

#### release.yml - Release Build

**ट्रिगर्स / Triggers:**
- Git tags: `v*.*.*` (e.g., v1.0.0)
- Manual workflow dispatch with version input

**Jobs / कार्य:**

1. **📦 Create Release**
   - Generate changelog
   - Create GitHub release
   - ~5 minutes

2. **🤖 Build Android Release**
   - Release APK
   - App Bundle (.aab)
   - Upload to release
   - ~40 minutes

3. **🌐 Build Web Release**
   - Production web build
   - Create tarball
   - Upload to release
   - ~30 minutes

4. **🖥️ Build Windows Release**
   - Windows executable
   - Create ZIP archive
   - Upload to release
   - ~40 minutes

5. **📢 Notify Release**
   - Status summary
   - Always runs

**Release Assets / रिलीज़ संपत्तियां:**
- `truecircle-vX.X.X-android.apk`
- `truecircle-vX.X.X-android.aab`
- `truecircle-vX.X.X-web.tar.gz`
- `truecircle-vX.X.X-windows.zip`

#### demo-token-guard.yml - Security Guard

**उद्देश्य / Purpose:** Demo data और tokens की सुरक्षा

**ट्रिगर्स / Triggers:**
- Push to `main`
- Pull requests to `main`
- Manual dispatch

**Checks / जांच:**
- Demo token validation
- Secrets scanning
- ~10 minutes

---

### Pull Request Template

**फ़ाइल / File:** `pull_request_template.md`

**उद्देश्य / Purpose:** Consistent और comprehensive PR descriptions

**Sections / अनुभाग:**

1. **विवरण / Description**
   - Changes का overview
   - Bilingual format

2. **परिवर्तन का प्रकार / Type of Change**
   - Bug fix
   - New feature
   - Breaking change
   - Documentation
   - UI/UX
   - Refactoring
   - Performance
   - Privacy/Security

3. **संबंधित इश्यू / Related Issue**
   - Issue linking
   - Closes/Fixes syntax

4. **परिवर्तन / Changes Made**
   - Detailed change list

5. **स्क्रीनशॉट / Screenshots**
   - Before/After comparison
   - UI changes visualization

6. **टेस्टिंग / Testing**
   - Test configuration
   - Test cases checklist
   - Platform testing

7. **चेकलिस्ट / Checklist**
   - Code quality checks
   - Documentation updates
   - Build verification
   - Privacy compliance
   - Bilingual testing

8. **Privacy Considerations**
   - Privacy Mode compliance
   - Demo data usage
   - Permission requirements

9. **अतिरिक्त संदर्भ / Additional Context**
   - Extra information for reviewers

---

### Other Files / अन्य फ़ाइलें

#### copilot-instructions.md
**उद्देश्य / Purpose:** GitHub Copilot के लिए project-specific instructions

**Content / सामग्री:**
- Project overview
- Architecture patterns
- Code conventions
- Privacy requirements
- Platform-specific guidelines

#### FUNDING.yml
**उद्देश्य / Purpose:** Sponsorship और funding information

#### GIT_HOOKS_SETUP.md
**उद्देश्य / Purpose:** Git hooks का setup guide

**Hooks / हुक्स:**
- Pre-commit: Format और analyze checks
- Commit-msg: Message validation
- Pre-push: Tests और build checks

#### GIT_QUICK_REFERENCE.md
**उद्देश्य / Purpose:** Quick reference card for common Git commands

**Sections / अनुभाग:**
- Getting started
- Branches
- Commits
- Syncing
- Viewing
- Undoing
- TrueCircle-specific workflows

---

## 🚀 उपयोग / Usage

### Creating an Issue

1. GitHub repository में जाएं
2. "Issues" tab click करें
3. "New Issue" button click करें
4. Template चुनें (Bug Report / Feature Request)
5. Template भरें
6. "Submit new issue" click करें

### Creating a Pull Request

1. अपने feature branch को push करें
2. GitHub पर repository में जाएं
3. "Compare & pull request" button दिखेगा
4. PR template automatically भर जाएगा
5. सभी sections complete करें
6. "Create pull request" click करें

### Running Workflows Manually

```bash
# GitHub UI में:
# Actions tab → Workflow चुनें → "Run workflow"

# या GitHub CLI से:
gh workflow run ci.yml
gh workflow run release.yml --field version=1.0.0
```

### Checking Workflow Status

```bash
# GitHub CLI से
gh run list
gh run view <run-id>
gh run watch <run-id>

# या GitHub UI में:
# Actions tab → Workflow run चुनें
```

---

## 🔧 Customization / कस्टमाइज़ेशन

### Modifying CI Workflow

```yaml
# .github/workflows/ci.yml में edit करें

jobs:
  new-job:
    name: 🎯 Custom Job
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Custom Step
        run: echo "Custom command"
```

### Adding New Issue Template

```bash
# New file बनाएं:
.github/ISSUE_TEMPLATE/custom_template.md

# Format:
---
name: Template Name
about: Template description
title: '[PREFIX] '
labels: label1, label2
assignees: ''
---

# Template content
```

### Modifying PR Template

```bash
# Edit करें:
.github/pull_request_template.md

# Add new sections या modify existing ones
```

---

## 📊 Workflow Status Badges

Add to README.md:

```markdown
![CI](https://github.com/surendragrover/Truecircle/actions/workflows/ci.yml/badge.svg)
![Release](https://github.com/surendragrover/Truecircle/actions/workflows/release.yml/badge.svg)
![Demo Token Guard](https://github.com/surendragrover/Truecircle/actions/workflows/demo-token-guard.yml/badge.svg)
```

---

## 🔒 Security / सुरक्षा

### Secrets Management

GitHub Secrets (Settings → Secrets and variables → Actions):

- `GITHUB_TOKEN` - Automatically provided
- अन्य secrets यहाँ add करें / Add other secrets here

### Token Guard

Demo token guard workflow सुनिश्चित करता है:
- Demo data integrity
- No real credentials committed
- Privacy compliance

---

## 📚 Resources / संसाधन

### GitHub Actions
- [Actions Documentation](https://docs.github.com/en/actions)
- [Workflow Syntax](https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions)
- [Flutter Action](https://github.com/marketplace/actions/flutter-action)

### Issue Templates
- [Issue Templates Guide](https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests)
- [Template Syntax](https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/syntax-for-issue-forms)

### Pull Request Templates
- [PR Templates Guide](https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/creating-a-pull-request-template-for-your-repository)

---

## 🤝 Contributing / योगदान

इन files को improve करने के लिए:

1. Issue खोलें या मौजूदा issue में comment करें
2. Changes के लिए PR बनाएं
3. Review process का पालन करें

---

## 📞 सहायता / Support

- 📚 [Git Workflow Guide](../GIT_WORKFLOW_GUIDE.md)
- 📖 [Contributing Guidelines](../CONTRIBUTING.md)
- 💬 [GitHub Discussions](https://github.com/surendragrover/Truecircle/discussions)

---

**इन workflows को maintain करके TrueCircle की code quality और consistency सुनिश्चित होती है!**  
**Maintaining these workflows ensures TrueCircle's code quality and consistency!**

🚀 Happy Contributing! आनंदमय योगदान! 🚀
