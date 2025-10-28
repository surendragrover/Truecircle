# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.embedding.**  { *; }

# Google Play Core (for split APKs compatibility)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# TensorFlow Lite
-keep class org.tensorflow.lite.** { *; }
-keep class org.tensorflow.** { *; }

# Hive
-keep class hive.** { *; }
-keep class com.example.truecircle.models.** { *; }

# Keep app-specific classes
-keep class com.example.truecircle.** { *; }

# General rules for reflection
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses