# GitHub Secrets Configuration

## Required Secrets for GitHub Actions

To enable automated deployment, you need to configure the following secrets in your GitHub repository:

### 🔧 Setup Instructions:

1. **Go to GitHub Repository Settings:**
   - Navigate to: `https://github.com/surendragrover/Truecircle/settings/secrets/actions`

2. **Add Required Secrets:**

### 📱 Firebase App Distribution (Optional)
```
Name: FIREBASE_APP_ID
Value: 1:239213685086:android:f25587f9c1c2b5df1107cf
```

```
Name: CREDENTIAL_FILE_CONTENT
Value: [Content of google-services.json file]
```

### 🌐 Firebase Hosting (Optional)
```
Name: FIREBASE_SERVICE_ACCOUNT_TRUECIRCLE_DBCDB
Value: [Firebase Service Account JSON]
```

### 🚀 Current Configuration:

- **Project ID:** truecircle-dbcdb
- **App ID:** 1:239213685086:android:f25587f9c1c2b5df1107cf
- **Package Name:** com.example.truecircle

### ⚡ Quick Setup (No Secrets Required):

The current workflow is configured to work without secrets for basic APK building. 

**What works without secrets:**
- ✅ Flutter build and analyze
- ✅ APK generation
- ✅ Basic CI/CD pipeline

**What needs secrets:**
- 📱 Firebase App Distribution upload
- 🌐 Firebase Hosting deployment
- 📊 Advanced Firebase features

### 🔒 Security Note:

Never commit actual secret values to your repository. All sensitive data should be stored in GitHub Secrets.

### 📚 References:

- [GitHub Secrets Documentation](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Firebase App Distribution](https://firebase.google.com/docs/app-distribution)
- [Firebase Hosting](https://firebase.google.com/docs/hosting)