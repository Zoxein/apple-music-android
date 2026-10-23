#!/usr/bin/env python3
"""
Surgically patch on_audio_query_android plugin to be compatible with:
- Android Gradle Plugin 8.x (requires namespace)
- Java 17 (jvmTarget alignment)
- Keep all existing dependencies (lifecycle, coroutines, gson, etc.)
"""
import os
import glob

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

pattern = os.path.join(pub_cache, "hosted", "**", "on_audio_query_android-*")
pkg_dirs = glob.glob(pattern, recursive=True)

if not pkg_dirs:
    pattern2 = os.path.join(pub_cache, "**", "on_audio_query_android*")
    pkg_dirs = [d for d in glob.glob(pattern2, recursive=True) if os.path.isdir(d)]

print(f"Found {len(pkg_dirs)} on_audio_query_android directories")

for pkg_dir in pkg_dirs:
    print(f"\nPatching: {pkg_dir}")
    build_gradle = os.path.join(pkg_dir, "android", "build.gradle")
    
    if os.path.exists(build_gradle):
        with open(build_gradle, "r", encoding="utf-8") as f:
            content = f.read()
        
        # 1. Add namespace
        if "namespace" not in content:
            content = content.replace("android {", "android {\n    namespace 'com.lucasjosino.on_audio_query'")
            print("  Added namespace")
        
        # 2. Update Java compatibility to 17
        if "JavaVersion.VERSION_1_8" in content:
            content = content.replace("JavaVersion.VERSION_1_8", "JavaVersion.VERSION_17")
            print("  Updated Java compatibility to 17")
        elif "compileOptions {" not in content:
            content = content.replace("android {", "android {\n    compileOptions {\n        sourceCompatibility JavaVersion.VERSION_17\n        targetCompatibility JavaVersion.VERSION_17\n    }")
            print("  Added compileOptions for Java 17")

        # 3. Update kotlinOptions jvmTarget to 17
        if "jvmTarget = '1.8'" in content:
            content = content.replace("jvmTarget = '1.8'", "jvmTarget = '17'")
            print("  Updated jvmTarget to 17")
        elif 'jvmTarget = "1.8"' in content:
            content = content.replace('jvmTarget = "1.8"', 'jvmTarget = "17"')
            print("  Updated jvmTarget to 17")
        elif "kotlinOptions {" not in content:
            content = content.replace("android {", "android {\n    kotlinOptions {\n        jvmTarget = '17'\n    }")
            print("  Added kotlinOptions for JVM 17")
        
        # 4. Ensure lifecycle and coroutines dependencies are present
        if "lifecycle-viewmodel-ktx" not in content:
            content = content.replace(
                "dependencies {",
                "dependencies {\n    implementation 'androidx.lifecycle:lifecycle-viewmodel-ktx:2.4.0'\n    implementation 'org.jetbrains.kotlinx:kotlinx-coroutines-android:1.5.2'\n    implementation 'androidx.core:core-ktx:1.7.0'"
            )
            print("  Ensured lifecycle & coroutine dependencies")
            
        with open(build_gradle, "w", encoding="utf-8") as f:
            f.write(content)
        print(f"  Saved patched {build_gradle}")
    
    # Fix AndroidManifest.xml - remove deprecated package attribute
    for manifest in glob.glob(os.path.join(pkg_dir, "**", "AndroidManifest.xml"), recursive=True):
        with open(manifest, "r", encoding="utf-8") as f:
            m_content = f.read()
        if 'package="com.lucasjosino.on_audio_query"' in m_content:
            m_content = m_content.replace(' package="com.lucasjosino.on_audio_query"', '')
            with open(manifest, "w", encoding="utf-8") as f:
                f.write(m_content)
            print(f"  Fixed manifest: {manifest}")

print("\nPatching complete!")
