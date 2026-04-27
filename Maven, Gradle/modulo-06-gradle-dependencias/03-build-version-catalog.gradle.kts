// ============================================================
// ARQUIVO: 03-build-version-catalog.gradle.kts
// USO: Kotlin DSL — demonstra como usar o Version Catalog
//      (libs.versions.toml) no build.gradle.kts
//
// PRÉ-REQUISITO: Ter o arquivo gradle/libs.versions.toml
// ============================================================

plugins {
    java
    // Usando plugin do Version Catalog (declarado em libs.versions.toml)
    alias(libs.plugins.shadow)
    alias(libs.plugins.versions)
}

group = "com.curso"
version = "1.0.0-SNAPSHOT"

java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(21)
    }
}

repositories {
    mavenCentral()
}

dependencies {
    // ─────────────────────────────────────────────────────────
    // Usando o Version Catalog com type-safe accessors:
    // libs.gson           = com.google.code.gson:gson:2.10.1
    // libs.guava          = com.google.guava:guava:32.1.3-jre
    // libs.slf4j.api      = org.slf4j:slf4j-api:2.0.9
    //                       (o - vira . no accessor)
    //
    // IDEs como IntelliJ IDEA oferecem AUTOCOMPLETE completo!
    // ─────────────────────────────────────────────────────────
    implementation(libs.gson)
    implementation(libs.guava)

    // Bundle: adiciona slf4j-api + logback-classic de uma vez
    implementation(libs.bundles.logging)

    compileOnly(libs.lombok)
    annotationProcessor(libs.lombok)

    runtimeOnly(libs.h2)

    // Bundle de testes: junit-jupiter + mockito-core + assertj-core
    testImplementation(libs.bundles.testing)
    testRuntimeOnly(libs.junit.platform.launcher)
}

tasks.named<Test>("test") {
    useJUnitPlatform()
    testLogging {
        events("passed", "skipped", "failed")
    }
}

/*
  ═══════════════════════════════════════════════════════════
  CONVENÇÃO DE NOMES DO VERSION CATALOG:
  
  No TOML (libs.versions.toml):
    slf4j-api = { group = "org.slf4j", name = "slf4j-api", ... }
    junit-jupiter-api = { ... }
  
  No build.gradle.kts (Kotlin DSL):
    libs.slf4j.api          → hífens viram pontos
    libs.junit.jupiter.api  → hífens viram pontos
  
  No build.gradle (Groovy DSL):
    libs.slf4j.api
    libs.junit.jupiter.api

  VANTAGENS DO VERSION CATALOG:
  ✅ Uma fonte única de verdade para versões
  ✅ Type-safe accessors (autocomplete na IDE)
  ✅ Compartilhado entre todos os módulos (single file)
  ✅ Referência por nome legível em vez de strings magicas
  ✅ Bundles agrupam dependências relacionadas
  ✅ Plugins também podem ser gerenciados aqui

  COMANDOS PARA ATUALIZAR VERSÕES:
  # Plugin versions (com.github.ben-manes.versions):
  ./gradlew dependencyUpdates
  # Mostra quais libs têm versões mais novas disponíveis
  ═══════════════════════════════════════════════════════════
*/
