
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newSubprojectBuildDir: Directory =
    rootProject.layout.buildDirectory.dir("../../build").get()

rootProject.layout.buildDirectory.value(newSubprojectBuildDir)

subprojects {
    project.layout.buildDirectory.value(newSubprojectBuildDir.dir(project.name))
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
