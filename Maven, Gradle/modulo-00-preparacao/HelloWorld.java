// ============================================================
// ARQUIVO: HelloWorld.java
// LOCAL: src/main/java/com/curso/HelloWorld.java
//
// O QUE ESTE ARQUIVO FAZ:
// Classe Java simples para testar que o ambiente está
// configurado corretamente. Use este arquivo para validar
// que o JDK, Maven e Gradle conseguem compilar Java.
// ============================================================

// O package deve espelhar a estrutura de diretórios:
// src/main/java/com/curso/HelloWorld.java → package com.curso
package com.curso;

/**
 * Classe de verificação do ambiente de desenvolvimento.
 *
 * COMO COMPILAR E EXECUTAR:
 *
 * Manualmente (sem build tool):
 *   javac -d target/classes src/main/java/com/curso/HelloWorld.java
 *   java -cp target/classes com.curso.HelloWorld
 *
 * Com Maven (após criar o pom.xml do Módulo 1):
 *   mvn compile
 *   mvn exec:java -Dexec.mainClass="com.curso.HelloWorld"
 *
 * Com Gradle (após criar o build.gradle do Módulo 5):
 *   ./gradlew run
 */
public class HelloWorld {

    // main é o ponto de entrada da aplicação Java
    // String[] args = argumentos passados via linha de comando (ex: java App arg1 arg2)
    public static void main(String[] args) {
        System.out.println("=== Verificação do Ambiente ===");

        // Imprime a versão do Java em execução
        // Útil para validar que a JVM correta está sendo usada
        System.out.println("Java Version : " + System.getProperty("java.version"));

        // Mostra o fornecedor do JDK (Oracle, Eclipse Adoptium, Amazon Corretto, etc.)
        System.out.println("Java Vendor  : " + System.getProperty("java.vendor"));

        // Mostra o sistema operacional
        System.out.println("OS           : " + System.getProperty("os.name"));

        System.out.println("================================");
        System.out.println("Ambiente configurado com SUCESSO!");
    }
}
