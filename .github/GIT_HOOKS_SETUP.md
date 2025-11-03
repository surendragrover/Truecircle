# Git Hooks सेटअप / Git Hooks Setup

Git hooks TrueCircle के लिए - Code quality और consistency सुनिश्चित करने के लिए  
Git hooks for TrueCircle - Ensuring code quality and consistency

## 📋 उपलब्ध Hooks / Available Hooks

### 1. Pre-commit Hook

यह hook commit से पहले चलता है और सुनिश्चित करता है:  
This hook runs before commit and ensures:

- Code formatting सही है / Code is properly formatted
- कोई syntax errors नहीं हैं / No syntax errors
- Demo data safe है / Demo data is safe

### 2. Commit-msg Hook

यह hook commit message को validate करता है:  
This hook validates commit message:

- सही format follow करता है / Follows correct format
- Type और scope है / Has type and scope
- Subject meaningful है / Has meaningful subject

### 3. Pre-push Hook

यह hook push से पहले चलता है:  
This hook runs before push:

- सभी tests pass होते हैं / All tests pass
- Build successful है / Build is successful
- कोई TODO/FIXME main branch पर नहीं / No TODO/FIXME on main

## 🚀 Installation / इंस्टॉलेशन

### Option 1: Manual Setup (मैन्युअल सेटअप)

#### Pre-commit Hook

```bash
# Create pre-commit hook
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash

echo "🔍 Running pre-commit checks..."

# Check if Flutter is available
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found. Please install Flutter."
    exit 1
fi

# Format check
echo "📝 Checking code formatting..."
if ! dart format --set-exit-if-changed .; then
    echo "❌ Code formatting issues found."
    echo "Run: dart format ."
    exit 1
fi

# Analyze code
echo "🔍 Analyzing code..."
if ! flutter analyze --no-fatal-infos --no-fatal-warnings; then
    echo "❌ Code analysis failed."
    exit 1
fi

# Check for secrets
echo "🔒 Checking for secrets..."
if git diff --cached --name-only | grep -E "api\.env|\.key|\.pem"; then
    echo "❌ Attempting to commit secret files!"
    echo "Files: api.env, *.key, *.pem should not be committed."
    exit 1
fi

# Check for large files
echo "📦 Checking for large files..."
for file in $(git diff --cached --name-only); do
    if [ -f "$file" ]; then
        size=$(wc -c < "$file")
        if [ $size -gt 1048576 ]; then  # 1MB
            echo "❌ File too large: $file ($(($size / 1024))KB)"
            echo "Consider using Git LFS for large files."
            exit 1
        fi
    fi
done

echo "✅ Pre-commit checks passed!"
exit 0
EOF

# Make executable
chmod +x .git/hooks/pre-commit
```

#### Commit-msg Hook

```bash
# Create commit-msg hook
cat > .git/hooks/commit-msg << 'EOF'
#!/bin/bash

commit_msg_file=$1
commit_msg=$(cat "$commit_msg_file")

# Regex for conventional commits
regex="^(feat|fix|docs|style|refactor|test|chore|perf|ci|build|revert)(\(.+\))?: .{1,50}"

echo "🔍 Validating commit message..."

if ! echo "$commit_msg" | grep -qE "$regex"; then
    echo "❌ Invalid commit message format!"
    echo ""
    echo "Expected format:"
    echo "  <type>(<scope>): <subject>"
    echo ""
    echo "Types: feat, fix, docs, style, refactor, test, chore, perf, ci, build, revert"
    echo ""
    echo "Examples:"
    echo "  feat(ai): add Gemini Nano support"
    echo "  fix(auth): resolve Firebase timeout"
    echo "  docs(readme): update installation steps"
    echo ""
    echo "Current message:"
    echo "$commit_msg"
    exit 1
fi

echo "✅ Commit message validated!"
exit 0
EOF

# Make executable
chmod +x .git/hooks/commit-msg
```

#### Pre-push Hook

```bash
# Create pre-push hook
cat > .git/hooks/pre-push << 'EOF'
#!/bin/bash

echo "🚀 Running pre-push checks..."

# Check if we're pushing to main
current_branch=$(git symbolic-ref HEAD | sed -e 's,.*/\(.*\),\1,')

if [ "$current_branch" = "main" ]; then
    echo "⚠️  Warning: Pushing to main branch!"
    read -p "Are you sure? (y/N): " confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        echo "❌ Push cancelled."
        exit 1
    fi
fi

# Run tests
echo "🧪 Running tests..."
if ! flutter test; then
    echo "❌ Tests failed!"
    exit 1
fi

# Build check
echo "🏗️  Checking build..."
if ! flutter build apk --debug --quiet; then
    echo "❌ Build failed!"
    exit 1
fi

echo "✅ Pre-push checks passed!"
exit 0
EOF

# Make executable
chmod +x .git/hooks/pre-push
```

### Option 2: Automated Setup Script (स्वचालित सेटअप)

Create a setup script:

```bash
# Create setup-hooks.sh
cat > setup-hooks.sh << 'EOF'
#!/bin/bash

echo "🔧 Setting up Git hooks for TrueCircle..."

# Create hooks directory if it doesn't exist
mkdir -p .git/hooks

# Download hooks from repository
curl -o .git/hooks/pre-commit https://raw.githubusercontent.com/surendragrover/Truecircle/main/.github/hooks/pre-commit
curl -o .git/hooks/commit-msg https://raw.githubusercontent.com/surendragrover/Truecircle/main/.github/hooks/commit-msg
curl -o .git/hooks/pre-push https://raw.githubusercontent.com/surendragrover/Truecircle/main/.github/hooks/pre-push

# Make executable
chmod +x .git/hooks/pre-commit
chmod +x .git/hooks/commit-msg
chmod +x .git/hooks/pre-push

echo "✅ Git hooks installed successfully!"
echo ""
echo "To disable hooks temporarily, use: git commit --no-verify"
EOF

# Make executable
chmod +x setup-hooks.sh

# Run it
./setup-hooks.sh
```

## 🛠️ Usage / उपयोग

### Normal Workflow (सामान्य वर्कफ़्लो)

```bash
# Hooks automatically run
git add .
git commit -m "feat(ai): add new feature"
git push
```

### Skip Hooks (Hooks को Skip करना)

```bash
# Skip pre-commit
git commit --no-verify -m "wip: work in progress"

# Skip pre-push
git push --no-verify
```

### Test Hooks Manually (Hooks को मैन्युअली टेस्ट करना)

```bash
# Test pre-commit
.git/hooks/pre-commit

# Test commit-msg
echo "feat(ai): test message" > /tmp/msg.txt
.git/hooks/commit-msg /tmp/msg.txt

# Test pre-push
.git/hooks/pre-push
```

## 🔧 Customization / कस्टमाइजेशन

### Disable Specific Checks (विशिष्ट Checks को बंद करना)

Edit hooks in `.git/hooks/` and comment out sections:

```bash
# Comment out formatting check
# if ! dart format --set-exit-if-changed .; then
#     echo "❌ Code formatting issues found."
#     exit 1
# fi
```

### Add Custom Checks (कस्टम Checks जोड़ना)

```bash
# Add privacy mode check in pre-commit
echo "🔒 Checking Privacy Mode..."
if grep -r "PermissionManager.isSampleMode = false" lib/; then
    echo "❌ Privacy Mode must always be true!"
    exit 1
fi
```

## 📊 Hook Flow / Hook प्रवाह

```
git commit
    ↓
pre-commit hook
    ├── Format check
    ├── Analyze code
    ├── Check secrets
    └── Check file sizes
    ↓
commit-msg hook
    └── Validate message format
    ↓
Commit created ✅

git push
    ↓
pre-push hook
    ├── Run tests
    ├── Check build
    └── Confirm main push
    ↓
Push to remote ✅
```

## 🚨 Troubleshooting / समस्या निवारण

### Hook not running (Hook नहीं चल रहा)

```bash
# Check if executable
ls -la .git/hooks/

# Make executable
chmod +x .git/hooks/pre-commit
chmod +x .git/hooks/commit-msg
chmod +x .git/hooks/pre-push
```

### Hook failing unexpectedly (Hook अप्रत्याशित रूप से fail हो रहा)

```bash
# Run manually to see error
.git/hooks/pre-commit

# Check Flutter installation
flutter doctor

# Check Git version
git --version
```

### Disable all hooks temporarily (सभी hooks अस्थायी रूप से बंद करना)

```bash
# Rename hooks directory
mv .git/hooks .git/hooks.disabled

# Re-enable later
mv .git/hooks.disabled .git/hooks
```

## 📚 Best Practices

1. **Always test hooks locally** before sharing
2. **Keep hooks fast** (< 10 seconds)
3. **Provide clear error messages** in Hindi and English
4. **Allow skip option** for emergencies
5. **Document any custom hooks** in this file

## 🔗 Additional Resources

- [Git Hooks Documentation](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks)
- [Husky (for Node.js projects)](https://typicode.github.io/husky/)
- [Pre-commit framework](https://pre-commit.com/)

---

**Note:** Git hooks are local to your repository and not pushed to remote.  
Each developer needs to install them separately.

**नोट:** Git hooks आपके local repository में होते हैं और remote पर push नहीं होते।  
प्रत्येक developer को इन्हें अलग से install करना होगा।
