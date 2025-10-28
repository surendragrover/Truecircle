plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.truecircle"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.truecircle"
        // Optimized for mass market devices (₹5-6k phones)
        minSdk = flutter.minSdkVersion  // Android 5.0+ for wider device support
        targetSdk = 34  // Latest for Play Store compatibility
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // Multi-architecture support for all device types
        // Keep APK smaller by targeting only ARM ABIs (most Android devices)
        ndk {
            abiFilters.clear()
            abiFilters += listOf("armeabi-v7a", "arm64-v8a")
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
        debug {
            isDebuggable = true
            applicationIdSuffix = ".debug"
        }
    }
    
    // Universal APK for development; enable per-ABI splits for release builds via:
    // flutter build apk --split-per-abi
    splits {
        abi {
            isEnable = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // TensorFlow Lite runtime for on-device models
    implementation("org.tensorflow:tensorflow-lite:2.14.0")
    // Optional support library (commented to keep minimal);
    // uncomment if you later parse metadata or use support tasks
    // implementation("org.tensorflow:tensorflow-lite-support:0.4.4")
}

// Suppress Java compilation warnings for Firebase plugins
tasks.withType<JavaCompile> {
    options.compilerArgs.addAll(listOf("-Xlint:-options", "-Xlint:-deprecation", "-Xlint:-unchecked"))
}
