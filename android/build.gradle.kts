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

// Fix for older Flutter plugins (e.g. isar_flutter_libs 3.1.0+1) that do not
// declare an Android `namespace`, which is required since AGP 8. We hook the
// moment the Android Gradle plugin is applied to each module and, if no
// namespace is set, derive one from the module's manifest `package` (or its
// Gradle group). Using `plugins.withId` runs before AGP finalizes the DSL, so
// it avoids the "already evaluated" timing issue that `afterEvaluate` hits with
// the `evaluationDependsOn(":app")` block below.
subprojects {
    fun injectNamespaceIfMissing() {
        val androidExtension = project.extensions.findByName("android")
        if (androidExtension is com.android.build.gradle.BaseExtension &&
            androidExtension.namespace == null
        ) {
            val manifestFile = file("src/main/AndroidManifest.xml")
            val packageFromManifest =
                if (manifestFile.exists()) {
                    Regex("package=\"([^\"]+)\"")
                        .find(manifestFile.readText())
                        ?.groupValues
                        ?.getOrNull(1)
                } else {
                    null
                }
            androidExtension.namespace =
                packageFromManifest
                    ?: project.group.toString().ifBlank { "com.example.${project.name}" }
        }
    }
    plugins.withId("com.android.library") { injectNamespaceIfMissing() }
    plugins.withId("com.android.application") { injectNamespaceIfMissing() }
}

// Certains plugins anciens (ex. isar_flutter_libs 3.1.0+1) compilent leur
// module Android avec un compileSdk < 31, ce qui provoque au build release :
//   "resource android:attr/lStar not found" (tâche verifyReleaseResources).
// On aligne le compileSdk des modules LIBRAIRIE sur celui de `:app` (géré par
// Flutter) — donc sur une plateforme SDK déjà installée. `:app` n'est pas
// touché. Repli sur 34 si la valeur de `:app` ne peut être lue.
subprojects {
    if (project.name != "app") {
        afterEvaluate {
            val androidExtension = project.extensions.findByName("android")
            if (androidExtension is com.android.build.gradle.BaseExtension) {
                val appAndroid =
                    rootProject.project(":app").extensions.findByName("android")
                        as? com.android.build.gradle.BaseExtension
                // `compileSdkVersion` de :app vaut p.ex. "android-35" ; on en
                // extrait le niveau d'API en Int (overload non ambigu) et on
                // l'applique au module librairie. Repli sur 34 si illisible.
                val level = appAndroid?.compileSdkVersion
                    ?.substringAfter("android-")
                    ?.toIntOrNull()
                androidExtension.compileSdkVersion(level ?: 34)
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
