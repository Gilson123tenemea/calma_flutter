plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.calma"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }


    defaultConfig {
        applicationId = "com.example.calma"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode.toInt()
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    configurations.all {
        resolutionStrategy {
            force("androidx.core:core-ktx:1.12.0")
        }
    }
    dependencies {
        implementation(platform("com.google.firebase:firebase-bom:32.3.1"))
        implementation("com.google.firebase:firebase-messaging-ktx")
        implementation("androidx.core:core-ktx:1.12.0")
    }
    subprojects {
        afterEvaluate {
            if (this is Project) {
                extensions.findByType<com.android.build.gradle.BaseExtension>()?.apply {
                    compileOptions {
                        sourceCompatibility = JavaVersion.VERSION_11
                        targetCompatibility = JavaVersion.VERSION_11
                    }
                }
            }
        }
    }

}

flutter {
    source = "../.."
}
