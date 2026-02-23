import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    // END: FlutterFire Configuration
    id("kotlin-android")
     id("kotlin-parcelize") 
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// 🔐 Load keystore values from keys.env
val keystorePropertiesFile = rootProject.file("../keys.env")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}


android {
    namespace = "com.hertzworkz.hrtz_hrms"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        // ✅ Enable core library desugaring(for Local Notification Plugin)
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.hertzworkz.hrtz_hrms"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 26
        targetSdk = 35
       
        versionCode = 5
        versionName = "1.0.5"
         // Enable multidex
        multiDexEnabled = true
    }

     // 🔐 Signing configuration (copied from other app, translated for Kotlin DSL)
    signingConfigs {
        create("release") {
            storeFile = file(keystoreProperties["KEYSTORE_PATH"] ?: "")
            storePassword = keystoreProperties["KEYSTORE_STORE_PASSWORD"] as String? ?: ""
            keyAlias = keystoreProperties["KEY_ALIAS"] as String? ?: ""
            keyPassword = keystoreProperties["KEY_PASSWORD"] as String? ?: ""
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }

         getByName("debug") {
            // Optional: sign debug with same release key for easier testing
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Updated core library desugaring dependency to version 2.1.4 or higher
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}