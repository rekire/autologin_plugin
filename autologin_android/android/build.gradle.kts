plugins {
    id "com.android.library"
    id "kotlin-android"
}

group 'eu.rekisoft.flutter.autologin'
version '1.0-SNAPSHOT'

rootProject.allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

android {
    namespace 'eu.rekisoft.flutter.autologin'
    compileSdk 34

    sourceSets {
        main.java.srcDirs += 'src/main/kotlin'
    }
    defaultConfig {
        minSdkVersion 16
    }
    lintOptions {
        disable 'InvalidPackage'
    }

    sourceCompatibility = JavaVersion.VERSION_1_8
    targetCompatibility = JavaVersion.VERSION_1_8

    kotlinOptions {
        jvmTarget = '1.8'
    }
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.9.22"
    implementation 'com.google.android.gms:play-services-auth:21.0.0'
    implementation 'org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3'

    implementation 'androidx.activity:activity:1.8.2'
    implementation 'androidx.lifecycle:lifecycle-runtime-ktx:2.7.0'
    implementation 'androidx.credentials:credentials:1.2.1'

    // optional - needed for credentials support from play services, for devices running
    // Android 13 and below.
    implementation 'androidx.credentials:credentials-play-services-auth:1.2.1'

    implementation 'com.google.android.gms:play-services-auth-blockstore:16.2.0'
}
