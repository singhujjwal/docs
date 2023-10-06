# Gradle build system for Java projects
## Language options
* Groovy & Kotlin

## Project

Any thing unqualified and at global level are part of project, If you see any unqualified object always check the 
Project API properties/documentation.
If the name is unqualified then it can be 
* A task
* A Property on Project
* An extra property defined elsewhere
* A property of an implicit object within a block.
* A local variable defined earlier in the build script.

Use ext to define extra properties and available to project but 
not to the sub gradle files directly can be accessed by `Project.get("a")`

```
ext {
    x = "Ujjwal"
    y = "Singh"
}
```

## Dependencies 

Sometimes these need to be loaded before the plugins closure and can be loaded by the `buildscript` construct.

Here you are specifying the dependency for the build process itself and not for application
These build dependencies are used to enable and configure various Gradle plugins, tasks, and tools. 


e.g.
```
dependencies {
    classpath group: 'gradle.plugin.com.github.lkishalmi.gatling', name: 'gradle-gatling-plugin', version: '3.3.0'
}
```

## Plugins

```
plugins {
    id 'com.x.y.z' version 'x.a.a'
}
```

Can also apply latest plugins by excluding fully defined plugin name as
```
apply plugin: 'checkstyle'
apply plugin: 'java'
apply plugin: 'idea'
```

## Repositories

```
repositories {
    maven {
        name = "development"
        url "url1"
    }
    maven {
        name = "snapshots"
        url "url2/snapshots"
    }
    maven {
        name = "releases"
        url "url2/releases"
    }
}
```



## Task
A plain 
```
task {
    doLast {
        println("Hello Task")
    }
}
```

is immediately configured and executed as part of the build script evaluation phase.
Suitable for tasks that need to run during the configuration phase, such as defining properties or 
performing setup tasks for other tasks. 

```
tasks.register('myTask') {
    // Configuration for the task
}

```
is not immediately configured or executed during the configuration phase. Instead, it is registered and remains inactive until the execution phase of the build. 

`sourceCompatibility` can be set optionally to indicate java version compatibility.

`apply from: somefile.gradle` can be used to break `build.gradle` into separate files, this can be also used inside conditionals.




