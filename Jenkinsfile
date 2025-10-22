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
        
        stage('SonarQube Analysis') {
            steps {
                echo 'Analyse de qualité de code avec SonarQube...'
                script {
                    try {
                        // Configuration SonarQube avec token
                        withSonarQubeEnv('SonarQube') {
                            if (isUnix()) {
                                sh '''
                                    mvn sonar:sonar \
                                        -Dsonar.projectKey=student-management \
                                        -Dsonar.projectName="Student Management System" \
                                        -Dsonar.projectVersion=${BUILD_NUMBER} \
                                        -Dsonar.sources=src/main/java \
                                        -Dsonar.tests=src/test/java \
                                        -Dsonar.java.binaries=target/classes \
                                        -Dsonar.junit.reportPaths=target/surefire-reports
                                '''
                            } else {
                                bat '''
                                    mvn sonar:sonar ^
                                        -Dsonar.projectKey=student-management ^
                                        -Dsonar.projectName="Student Management System" ^
                                        -Dsonar.projectVersion=%BUILD_NUMBER% ^
                                        -Dsonar.sources=src/main/java ^
                                        -Dsonar.tests=src/test/java ^
                                        -Dsonar.java.binaries=target/classes ^
                                        -Dsonar.junit.reportPaths=target/surefire-reports
                                '''
                            }
                        }
                        
                        // Attendre les résultats de Quality Gate
                        timeout(time: 5, unit: 'MINUTES') {
                            def qg = waitForQualityGate()
                            if (qg.status != 'OK') {
                                echo "⚠️ Quality Gate failed: ${qg.status}"
                                currentBuild.result = 'UNSTABLE'
                            } else {
                                echo "✅ Quality Gate passed!"
                            }
                        }
                        
                    } catch (Exception e) {
                        echo "❌ SonarQube analysis failed: ${e.getMessage()}"
                        echo "📋 Configuration requise:"
                        echo "1. Installer SonarQube: docker run -d -p 9000:9000 sonarqube:lts-community"
                        echo "2. Configurer SonarQube dans Jenkins (Manage Jenkins → Configure System)"
                        echo "3. Créer un token SonarQube et l'ajouter dans Jenkins credentials"
                        currentBuild.result = 'UNSTABLE'
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
                    // Définir le nom de l'image avec le repository Docker Hub
                    // Note: Assurez-vous que le username correspond aux credentials Jenkins
                    def dockerRepo = "louay11/student-management"  // Corrigé pour correspondre au login
                    def imageTag = "${dockerRepo}:${env.BUILD_NUMBER}"
                    def latestTag = "${dockerRepo}:latest"
                    def localTag = "student-management:latest"
                    
                    try {
                        if (isUnix()) {
                            // Vérifier si Docker est accessible
                            sh "docker --version"
                            
                            // Build de l'image Docker (version locale d'abord)
                            sh "docker build -t ${localTag} -t ${imageTag} -t ${latestTag} ."
                            
                            // Afficher les images créées
                            sh "docker images | grep -E '(student-management|louayh11)'"
                            
                            // Push vers Docker Hub avec credentials
                            withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', 
                                           usernameVariable: 'DOCKER_USER', 
                                           passwordVariable: 'DOCKER_PASS')]) {
                                sh """
                                    echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin
                                    
                                    # Vérifier si le repository existe, sinon le créer avec un push initial
                                    if ! docker manifest inspect ${latestTag} > /dev/null 2>&1; then
                                        echo "🆕 Repository n'existe pas, création automatique..."
                                        docker push ${imageTag}
                                        echo "✅ Repository créé avec la première image"
                                    fi
                                    
                                    # Push normal
                                    docker push ${imageTag}
                                    docker push ${latestTag}
                                    docker logout
                                """
                            }
                            
                        } else {
                            // Build de l'image Docker sur Windows
                            bat "docker --version"
                            bat "docker build -t ${localTag} -t ${imageTag} -t ${latestTag} ."
                            bat "docker images | findstr student-management"
                            
                            // Push vers Docker Hub avec credentials (Windows)
                            withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', 
                                           usernameVariable: 'DOCKER_USER', 
                                           passwordVariable: 'DOCKER_PASS')]) {
                                bat """
                                    echo %DOCKER_PASS% | docker login -u %DOCKER_USER% --password-stdin
                                    docker push ${imageTag}
                                    docker push ${latestTag}
                                    docker logout
                                """
                            }
                        }
                    } catch (Exception e) {
                        echo "❌ Erreur Docker: ${e.getMessage()}"
                        echo "📋 CAUSES POSSIBLES:"
                        echo "1. Permissions Docker - Exécuter sur le serveur:"
                        echo "   sudo usermod -aG docker jenkins"
                        echo "   sudo systemctl restart jenkins"
                        echo "2. Image Docker introuvable - Vérifier le Dockerfile"
                        echo "3. Problème réseau - Vérifier la connexion Docker Hub"
                        echo "⚠️  Le pipeline continue malgré l'échec Docker"
                        currentBuild.result = 'UNSTABLE'
                    }
                }
            }
            post {
                success {
                    echo "🎉 SUCCESS: Images Docker créées et poussées !"
                    echo "📦 Images disponibles:"
                    echo "   - louay11/student-management:${env.BUILD_NUMBER}"
                    echo "   - louay11/student-management:latest"
                    echo "🐳 Usage: docker pull louay11/student-management:latest"
                }
                failure {
                    echo "❌ Stage Docker échoué"
                    echo "📋 Vérifiez:"
                    echo "   1. Repository Docker Hub : louayh11/student-management"
                    echo "   2. Credentials Jenkins : docker-hub-credentials"
                    echo "   3. Connexion réseau Docker Hub"
                }
                unstable {
                    echo "⚠️  Stage Docker instable - Configuration requise"
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