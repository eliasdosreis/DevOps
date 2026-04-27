// ============================================================
// ARQUIVO: 01-build-minimo.gradle.kts
// USO: Kotlin DSL — renomeie para build.gradle.kts
//
// O QUE ESTE ARQUIVO FAZ:
// Versão KOTLIN DSL do build.gradle mínimo.
// Funcionalmente idêntico ao 01-build-minimo.gradle,
// mas escrito em Kotlin em vez de Groovy.
//
// KOTLIN DSL vs GROOVY DSL:
// Vantagens do Kotlin DSL:
//   ✅ Type-safety: erros detectados em tempo de compilação
//   ✅ Autocomplete completo nas IDEs (IntelliJ IDEA)
//   ✅ Refactoring mais seguro
//   ✅ É a direção do futuro do Gradle
// Desvantagens:
//   ❌ Build um pouco mais lento na primeira execução
//   ❌ Sintaxe um pouco mais verbosa em alguns casos
//   ❌ Exemplos online ainda são maioria em Groovy
//
// RECOMENDAÇÃO SENIOR: Use Kotlin DSL em TODOS os projetos novos.
// ============================================================

// ─────────────────────────────────────────────────────────────
// SEÇÃO: plugins
// Kotlin DSL: sintaxe é a mesma! (plugins {} block é igual)
// ─────────────────────────────────────────────────────────────
plugins {
    java   // equivalent to id("java") ou id 'java' no Groovy
    // application  // descomente se tiver main()
}

// ─────────────────────────────────────────────────────────────
// DIFERENÇA Kotlin vs Groovy:
// Groovy: group = 'com.curso'           (sem tipo explícito)
// Kotlin: group = "com.curso"           (aspas duplas, type-safe)
// Nota: strings em Kotlin usam " não '
// ─────────────────────────────────────────────────────────────

group = "com.curso"
version = "1.0.0-SNAPSHOT"

// ─────────────────────────────────────────────────────────────
// SEÇÃO: java (configuração do Java toolchain)
// Kotlin DSL: sintaxe identica ao Groovy para blocos de config
// ─────────────────────────────────────────────────────────────
java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(21)
    }
}

// ─────────────────────────────────────────────────────────────
// SEÇÃO: repositories
// ─────────────────────────────────────────────────────────────
repositories {
    mavenCentral()
}

// ─────────────────────────────────────────────────────────────
// SEÇÃO: dependencies
// Kotlin DSL: strings entre aspas duplas obrigatoriamente
// ─────────────────────────────────────────────────────────────
dependencies {
    implementation("com.google.code.gson:gson:2.10.1")

    testImplementation("org.junit.jupiter:junit-jupiter:5.10.1")
    testRuntimeOnly("org.junit.platform:junit-platform-launcher")
}

// ─────────────────────────────────────────────────────────────
// SEÇÃO: tasks configuration
// Kotlin DSL: tasks.named<TaskType>("taskName") { ... }
// A grande diferença: você especifica o TIPO da task
// Isso permite autocomplete total na IDE!
// ─────────────────────────────────────────────────────────────
tasks.named<Test>("test") {
    useJUnitPlatform()

    testLogging {
        events("passed", "skipped", "failed")
    }
}

// ─────────────────────────────────────────────────────────────
// DIFERENÇAS SINTÁTICAS GROOVY vs KOTLIN:
//
// Groovy DSL:                     Kotlin DSL:
// id 'java'                   →   id("java") ou java
// group = 'com.curso'         →   group = "com.curso"
// version = '1.0'             →   version = "1.0"
// implementation '...'        →   implementation("...")
// tasks.named('test') { }     →   tasks.named<Test>("test") { }
// apply plugin: 'java'        →   apply(plugin = "java")
// ─────────────────────────────────────────────────────────────
