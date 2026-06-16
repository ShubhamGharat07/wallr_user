allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// ── Namespace fix for legacy plugins (AGP 8+) ──────────────────────────
// Older plugins like `async_wallpaper` declare `package` in their
// AndroidManifest but no `namespace` in build.gradle, which AGP 8+ rejects.
// This reads the manifest's package and sets it as the namespace so the
// build doesn't fail — without touching the global pub cache.
// NOTE: must run BEFORE the evaluationDependsOn(":app") block below, which
// force-evaluates subprojects and would make afterEvaluate throw.
subprojects {
    afterEvaluate {
        val androidExtension = project.extensions.findByName("android")
        if (androidExtension is com.android.build.gradle.BaseExtension) {
            if (androidExtension.namespace == null) {
                val manifestFile = androidExtension.sourceSets
                    .getByName("main")
                    .manifest
                    .srcFile
                if (manifestFile.exists()) {
                    val packageMatch = Regex("package=\"(.+?)\"")
                        .find(manifestFile.readText())
                    val packageName = packageMatch?.groupValues?.get(1)
                    if (packageName != null) {
                        androidExtension.namespace = packageName
                    }
                }
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
