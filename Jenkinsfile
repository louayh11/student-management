pipeline {
    agent any
    
    tools {
        maven 'Maven-3.9.0' // Nom de votre installation Maven dans Jenkins
        jdk 'JDK-17'        // Nom de votre installation JDK dans Jenkins
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Récupération du code source...'
                checkout scm
            }
        }
        
        stage('Clean') {
            steps {
                echo 'Nettoyage du projet...'
                bat 'mvn clean'
            }
        }
        
        stage('Compile') {
            steps {
                echo 'Compilation du projet...'
                bat 'mvn compile'
            }
        }
        
        stage('Test') {
            steps {
                echo 'Exécution des tests...'
                bat 'mvn test'
            }
            post {
                always {
                    // Publication des résultats de tests
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }
        
        stage('Package') {
            steps {
                echo 'Création du package JAR...'
                bat 'mvn package -DskipTests'
            }
        }
        
        stage('Archive') {
            steps {
                echo 'Archivage des artifacts...'
                archiveArtifacts artifacts: 'target/*.jar', allowEmptyArchive: true
            }
        }
    }
    
    post {
        always {
            echo 'Pipeline terminé!'
            cleanWs() // Nettoie l'espace de travail
        }
        success {
            echo 'Build réussi! ✅'
        }
        failure {
            echo 'Build échoué! ❌'
        }
    }
}