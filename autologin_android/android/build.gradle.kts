group = "eu.rekisoft.flutter.autologin"
version = "1.0-SNAPSHOT"

buildscript {
  val kotlinVersion = "2.3.20"
  repositories {
    google()
    mavenCentral()
  }

  dependencies {
    classpath("com.android.tools.build:gradle:9.0.1")
    classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
  }
}

allprojects {
  repositories {
    google()
    mavenCentral()
  }
}

plugins {
  id("com.android.library")
}

android {
  namespace = "eu.rekisoft.flutter.autologin"

  compileSdk = 36

  compileOptions {
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
  }

  sourceSets {
    getByName("main") {
      java.srcDirs("src/main/kotlin")
    }
    getByName("test") {
      java.srcDirs("src/test/kotlin")
    }
  }

  defaultConfig {
    minSdk = 24
  }

  testOptions {
    unitTests {
      isIncludeAndroidResources = true
      all {
        it.useJUnitPlatform()

        it.outputs.upToDateWhen { false }

        it.testLogging {
          events("passed", "skipped", "failed", "standardOut", "standardError")
          showStandardStreams = true
        }
      }
    }
  }
}

kotlin {
  compilerOptions {
    jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
  }
}

dependencies {
  implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.9.22")
  implementation("com.google.android.gms:play-services-auth:21.0.0")
  implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")
  implementation("androidx.activity:activity:1.8.2")
  implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.7.0")
  implementation("androidx.credentials:credentials:1.2.1")


  // optional - needed for credentials support from play services, for devices running
  // Android 13 and below.
  implementation("androidx.credentials:credentials-play-services-auth:1.2.1")
  implementation("com.google.android.gms:play-services-auth-blockstore:16.2.0")


  //testImplementation("org.jetbrains.kotlin:kotlin-test")
  //testImplementation("org.mockito:mockito-core:5.0.0")
}
