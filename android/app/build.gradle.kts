import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Google Services plugin removed for offline-only build
}

android {
    namespace = "com.example.truecircle"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_1_8.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.truecircle"
        // Optimized for mass market devices (₹5-6k phones)
        minSdk = flutter.minSdkVersion  // Android 5.0+ for wider device support
    targetSdk = 35  // Target latest Android SDK for Play Store compliance
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // Do not set ndk.abiFilters when using ABI splits; splits below control ABIs
    }

    // Load signing properties from key.properties if present
    val keystoreProperties = Properties()
    val keystorePropertiesFile = rootProject.file("key.properties")
    if (keystorePropertiesFile.exists()) {
        keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
    }

    signingConfigs {
        if (keystoreProperties.isNotEmpty()) {
            create("release") {
                val storeFilePath = keystoreProperties.getProperty("storeFile")
                if (storeFilePath != null) {
                    storeFile = file(storeFilePath)
                }
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
    release {
            // Use release signing if configured, else fall back to debug signing
            signingConfig = if (signingConfigs.findByName("release") != null)
                signingConfigs.getByName("release")
            else
                signingConfigs.getByName("debug")
            // Disable code shrinking and resource shrinking for offline release builds
            // to avoid R8 removing classes from optional Play Core / deferred
            // components that we don't include. This produces a slightly larger
            // APK but avoids missing-class R8 errors when removing Google
            // Play libraries from the project.
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
        debug {
            isDebuggable = true
            // Removed .debug suffix to match Firebase configuration
            // applicationIdSuffix = ".debug"
        }
    }
    
    // Note: Do not configure Gradle ABI splits here to avoid conflicts with
    // Flutter's --split-per-abi flag which configures splits automatically.
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

// Suppress all Java compilation warnings
tasks.withType<JavaCompile> {
    options.compilerArgs.addAll(listOf("-nowarn"))
    options.isWarnings = false
}
