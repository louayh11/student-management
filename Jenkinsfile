pipeline {
    agent any
    
    // Utilisation des outils par défaut disponibles sur l'agent
    // Si vous avez configuré des outils spécifiques dans Jenkins, 
    // remplacez 'any' par le nom exact de vos installations
    
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
                script {
                    if (isUnix()) {
                        sh 'mvn clean'
                    } else {
                        bat 'mvn clean'
                    }
                }
            }
        }
        
        stage('Compile') {
            steps {
                echo 'Compilation du projet...'
                script {
                    if (isUnix()) {
                        sh 'mvn compile'
                    } else {
                        bat 'mvn compile'
                    }
                }
            }
        }
        
        stage('Test') {
            steps {
                echo 'Exécution des tests...'
                script {
                    if (isUnix()) {
                        sh 'mvn test'
                    } else {
                        bat 'mvn test'
                    }
                }
            }
            post {
                always {
                    // Publication des résultats de tests si disponibles
                    script {
                        if (fileExists('target/surefire-reports')) {
                            junit allowEmptyResults: true, testDataPublishers: [], testResults: 'target/surefire-reports/*.xml'
                        } else {
                            echo 'Aucun rapport de test trouvé'
                        }
                    }
                }
            }
        }
        
        stage('Package') {
            steps {
                echo 'Création du package JAR...'
                script {
                    if (isUnix()) {
                        sh 'mvn package -DskipTests'
                    } else {
                        bat 'mvn package -DskipTests'
                    }
                }
            }
        }
        
        stage('Archive') {
            steps {
                echo 'Archivage des artifacts...'
                archiveArtifacts artifacts: 'target/*.jar', allowEmptyArchive: true
            }
        }
        
        stage('Docker Build & Push') {
            steps {
                echo 'Construction de l\'image Docker...'
                script {
                    // Définir le nom de l'image avec timestamp
                    def imageTag = "student-management:${env.BUILD_NUMBER}"
                    def latestTag = "student-management:latest"
                    
                    if (isUnix()) {
                        // Build de l'image Docker
                        sh "docker build -t ${imageTag} -t ${latestTag} ."
                        
                        // Optionnel: Push vers un registry (décommentez si vous avez un registry)
                        // sh "docker push ${imageTag}"
                        // sh "docker push ${latestTag}"
                        
                        // Afficher les images créées
                        sh "docker images | grep student-management"
                        
                    } else {
                        // Build de l'image Docker sur Windows
                        bat "docker build -t ${imageTag} -t ${latestTag} ."
                        
                        // Optionnel: Push vers un registry (décommentez si vous avez un registry)
                        // bat "docker push ${imageTag}"
                        // bat "docker push ${latestTag}"
                        
                        // Afficher les images créées
                        bat "docker images | findstr student-management"
                    }
                }
            }
            post {
                success {
                    echo "Image Docker créée avec succès: student-management:${env.BUILD_NUMBER}"
                }
                failure {
                    echo "Échec de la création de l'image Docker"
                }
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