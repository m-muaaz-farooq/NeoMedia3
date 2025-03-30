import com.android.build.gradle.internal.tasks.factory.dependsOn

plugins {
    alias(libs.plugins.android.library)
    alias(libs.plugins.kotlin.android)
}

android {
    namespace = "com.muaaz.neomedia3"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    defaultConfig {
        minSdk = 24

        externalNativeBuild {
            cmake {
                cppFlags += ""
            }
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )

            ndk {
                abiFilters += listOf("armeabi-v7a", "arm64-v8a", "x86_64", "x86")
            }
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    externalNativeBuild {
        cmake {
            version = "3.22.1"
            path = file("src/main/cpp/CMakeLists.txt")
        }
    }

    /*sourceSets {
        sourceSets["main"].jniLibs.srcDirs("src/main/jniLibs")
    }*/
}

val ffmpegSetup by tasks.registering(Exec::class) {
    workingDir = file("../ffmpeg")
    // export ndk path and run bash script
    environment("ANDROID_SDK_HOME", android.sdkDirectory.absolutePath)
    environment("ANDROID_NDK_HOME", android.ndkDirectory.absolutePath)
    commandLine("bash", "setupOriginal.sh")
}
tasks.preBuild.dependsOn(ffmpegSetup)

dependencies {
    implementation(libs.androidx.media3.exoplayer)
    implementation(libs.google.errorprone.annotations)
    implementation(libs.androidx.annotation)
    compileOnly(libs.checker.qual)
    compileOnly(libs.kotlin.annotations.jvm)
}