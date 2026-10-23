#!/usr/bin/env python3
"""
Patch on_audio_query_android plugin to be compatible with:
- Android Gradle Plugin 8.x (requires namespace)
- Java 17 (jvmTarget alignment)
"""
import os
import glob

NEW_BUILD_GRADLE = """group 'com.lucasjosino.on_audio_query'
version '1.0-SNAPSHOT'

buildscript {
    ext.kotlin_version = '1.9.0'
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.1.0'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }
}

rootProject.allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

apply plugin: 'com.android.library'
apply plugin: 'kotlin-android'

android {
    namespace 'com.lucasjosino.on_audio_query'
    compileSdkVersion 34

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = '17'
    }

    defaultConfig {
        minSdkVersion 21
    }
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"
    implementation 'com.google.code.gson:gson:2.10.1'
}
"""

def find_pub_cache():
    paths = [
        os.path.expanduser("~/.pub-cache"),
        "/home/runner/.pub-cache",
    ]
    for p in paths:
        if os.path.exists(p):
            return p
    return None

pub_cache = find_pub_cache()
if not pub_cache:
    print("ERROR: pub-cache not found!")
    exit(1)

print(f"pub-cache found at: {pub_cache}")

# Find on_audio_query_android package(s)
pattern = os.path.join(pub_cache, "hosted", "**", "on_audio_query_android-*")
pkg_dirs = glob.glob(pattern, recursive=True)

if not pkg_dirs:
    pattern2 = os.path.join(pub_cache, "**", "on_audio_query_android*")
    pkg_dirs = [d for d in glob.glob(pattern2, recursive=True) if os.path.isdir(d)]

print(f"Found {len(pkg_dirs)} on_audio_query_android directories")

for pkg_dir in pkg_dirs:
    print(f"\nPatching: {pkg_dir}")
    
    # Rewrite build.gradle
    build_gradle = os.path.join(pkg_dir, "android", "build.gradle")
    if os.path.exists(build_gradle):
        with open(build_gradle, "w") as f:
            f.write(NEW_BUILD_GRADLE)
        print(f"  Rewrote: {build_gradle}")
    else:
        print(f"  WARNING: build.gradle not found at {build_gradle}")
    
    # Fix AndroidManifest.xml - remove deprecated package attribute
    for manifest in glob.glob(os.path.join(pkg_dir, "**", "AndroidManifest.xml"), recursive=True):
        with open(manifest, "r") as f:
            content = f.read()
        if 'package="com.lucasjosino.on_audio_query"' in content:
            content = content.replace(' package="com.lucasjosino.on_audio_query"', '')
            with open(manifest, "w") as f:
                f.write(content)
            print(f"  Fixed manifest: {manifest}")

print("\nPatching complete!")
