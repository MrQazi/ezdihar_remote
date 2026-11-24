plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.narsun.ezdihar_remote"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.narsun.ezdihar_remote"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // The app is never published to a store: every build (debug and release,
    // local and CI) is signed with the debug key committed at
    // android/app/debug.keystore (standard debug credentials). One shared key
    // means any build installs over any other without uninstalling first.
    signingConfigs {
        getByName("debug") {
            storeFile = file("debug.keystore")
            storePassword = "android"
            keyAlias = "androiddebugkey"
            keyPassword = "android"
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
}

flutter {
    source = "../.."
}

// Flutter's tool expects app-<buildType>.apk, so keep that file and add a
// copy named ezdihar_remote_<buildType>.apk next to it.
androidComponents {
    onVariants { variant ->
        val buildType = variant.buildType ?: return@onVariants
        val cap = buildType.replaceFirstChar { it.uppercase() }
        val copyApk = tasks.register<Copy>("copy${cap}NamedApk") {
            val apkDir = layout.buildDirectory.dir("outputs/apk/$buildType")
            from(apkDir) { include("app-$buildType.apk") }
            from(apkDir) {
                include("app-$buildType.apk")
                rename { "ezdihar_remote_$buildType.apk" }
            }
            into(layout.buildDirectory.dir("outputs/flutter-apk"))
        }
        tasks.matching { it.name == "assemble$cap" }.configureEach {
            finalizedBy(copyApk)
        }
    }
}
