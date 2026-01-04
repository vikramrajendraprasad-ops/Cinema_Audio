
import java.util.Properties
import java.io.FileInputStream

val flutterRoot = rootProject.projectDir.parentFile

apply {
    from("${flutterRoot}/packages/flutter_tools/gradle/flutter.gradle")
}

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "com.example.cinema_audio"
    compileSdk = 33

    defaultConfig {
        applicationId = "com.example.cinema_audio"
        minSdk = 21
        targetSdk = 33
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = false
        }
    }
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.7.10")
}
