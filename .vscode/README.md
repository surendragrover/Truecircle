# VS Code Configuration for TrueCircle

This directory contains VS Code workspace settings optimized for TrueCircle Flutter development.

## Problem Solved

**Issue**: VS Code was hanging/freezing repeatedly (VS कोड बार बार हैंग होने की समस्या)

**Root Causes**:
1. VS Code was watching and indexing build artifacts (`.dart_tool`, `build/`, `android/build/`)
2. Git was tracking temporary build files
3. Missing file watcher exclusions
4. No recommended extensions configured

## Files in this Directory

### `settings.json`
Workspace-specific settings that:
- Exclude build folders from Dart analysis
- Configure file watchers to ignore build artifacts
- Optimize editor performance for Flutter development
- Set up proper formatting and code actions

### `launch.json`
Debug configurations for:
- Flutter app (profile mode)
- Dart tests
- Multiple Flutter modes (debug, profile, release)

### `extensions.json`
Recommended VS Code extensions for TrueCircle development:
- `dart-code.dart-code` - Dart language support
- `dart-code.flutter` - Flutter framework support
- Additional quality-of-life extensions

### `README.md` (this file)
Documentation for VS Code setup and configuration

## Performance Optimizations Applied

### 1. File Watcher Exclusions
Prevents VS Code from watching:
- `.dart_tool/` - Dart build cache
- `build/` - Flutter build outputs
- `android/build/`, `ios/build/` - Platform-specific builds
- `.gradle/` - Gradle cache
- `ios/Pods/` - CocoaPods dependencies

### 2. Search Exclusions
Speeds up "Find in Files" by excluding:
- Generated code (`*.g.dart`, `*.freezed.dart`)
- Build artifacts
- Dependency lock files

### 3. Dart Analysis Exclusions
Reduces analyzer workload by excluding build directories

### 4. Editor Optimizations
- Format on save enabled
- Quick suggestions optimized
- Word-based suggestions disabled for Dart (uses LSP instead)

## Installation Steps

1. **Install Recommended Extensions**
   - Open Command Palette (Ctrl+Shift+P / Cmd+Shift+P)
   - Type: "Extensions: Show Recommended Extensions"
   - Click "Install All" button

2. **Reload VS Code**
   - Close and reopen VS Code to apply all settings
   - Or use Command Palette: "Developer: Reload Window"

3. **Verify Settings Applied**
   - Check that build folders are excluded from File Explorer
   - Run "Flutter: Run Flutter Doctor" to verify setup

## Common Issues & Solutions

### Issue: VS Code Still Slow After Setup
**Solution**: 
```bash
# Clean build artifacts
flutter clean
rm -rf .dart_tool build

# Restart VS Code
```

### Issue: Dart Analysis Not Working
**Solution**:
- Check Output panel (View > Output)
- Select "Dart Analysis Server" from dropdown
- Look for errors in analysis server

### Issue: Extensions Not Loading
**Solution**:
- Disable and re-enable Dart/Flutter extensions
- Check for extension conflicts
- Update to latest extension versions

## Additional Performance Tips

1. **Disable Unused Extensions**: Only keep extensions you actively use
2. **Increase VS Code Memory**: Add to VS Code settings:
   ```json
   "files.maxMemoryForLargeFilesMB": 4096
   ```
3. **Use Flutter DevTools**: For debugging instead of heavy VS Code features
4. **Regular Cleanup**: Run `flutter clean` periodically

## Hindi Documentation / हिंदी दस्तावेज़ीकरण

### समस्या का समाधान
VS Code के हैंग होने की समस्या को ठीक करने के लिए:

1. **Build Folders को Exclude किया गया**: `.dart_tool`, `build/` folders को VS Code द्वारा monitor नहीं किया जाएगा
2. **Git से Build Files हटाई गईं**: अनावश्यक files को Git tracking से हटा दिया गया
3. **Performance Settings**: Editor को optimize किया गया Flutter development के लिए
4. **Recommended Extensions**: सही extensions की list तैयार की गई

### उपयोग
1. VS Code को बंद करें और फिर से खोलें
2. Recommended extensions install करें
3. अब VS Code smooth चलेगा बिना हैंग हुए

## Support

For issues specific to this workspace configuration:
1. Check VS Code Output panel for errors
2. Run `flutter doctor -v` to verify Flutter setup
3. Review this README for common solutions
4. Check TrueCircle main documentation for project-specific help

---

**Last Updated**: October 2024
**Flutter Version**: >=3.0.0 <4.0.0
**VS Code Version**: Latest stable recommended
