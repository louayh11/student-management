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
            when {
                // Exécuter seulement si SonarQube est configuré
                expression { return env.SONAR_HOST_URL != null || fileExists('sonar-project.properties') }
            }
            steps {
                echo 'Analyse de qualité de code avec SonarQube...'
                script {
                    try {
                        // Vérifier que SonarQube est accessible
                        if (isUnix()) {
                            sh 'curl -f http://localhost:9000/api/system/status || echo "SonarQube non accessible"'
                        }
                        
                        // Configuration SonarQube avec token
                        withSonarQubeEnv('SonarQube') {
                            if (isUnix()) {
                                sh '''
                                    mvn clean compile sonar:sonar \
                                        -Dsonar.projectKey=student-management \
                                        -Dsonar.projectName="Student Management System" \
                                        -Dsonar.projectVersion=${BUILD_NUMBER} \
                                        -Dsonar.sources=src/main/java \
                                        -Dsonar.tests=src/test/java \
                                        -Dsonar.java.binaries=target/classes \
                                        -Dsonar.junit.reportPaths=target/surefire-reports/*.xml \
                                        -Dsonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml
                                '''
                            } else {
                                bat '''
                                    mvn clean compile sonar:sonar ^
                                        -Dsonar.projectKey=student-management ^
                                        -Dsonar.projectName="Student Management System" ^
                                        -Dsonar.projectVersion=%BUILD_NUMBER% ^
                                        -Dsonar.sources=src/main/java ^
                                        -Dsonar.tests=src/test/java ^
                                        -Dsonar.java.binaries=target/classes ^
                                        -Dsonar.junit.reportPaths=target/surefire-reports/*.xml
                                '''
                            }
                        }
                        
                        // Attendre les résultats de Quality Gate (optionnel)
                        timeout(time: 3, unit: 'MINUTES') {
                            try {
                                def qg = waitForQualityGate()
                                if (qg.status != 'OK') {
                                    echo "⚠️ Quality Gate failed: ${qg.status}"
                                    echo "📊 Consultez les détails sur: http://localhost:9000"
                                    currentBuild.result = 'UNSTABLE'
                                } else {
                                    echo "✅ Quality Gate passed!"
                                }
                            } catch (Exception qgError) {
                                echo "⚠️ Quality Gate check échoué, mais analyse envoyée à SonarQube"
                                echo "📊 Vérifiez manuellement: http://localhost:9000"
                            }
                        }
                        
                    } catch (Exception e) {
                        echo "❌ SonarQube analysis failed: ${e.getMessage()}"
                        echo ""
                        echo "📋 CONFIGURATION REQUISE:"
                        echo "1. ✅ SonarQube installé: docker run -d -p 9000:9000 sonarqube:lts-community"
                        echo "2. 🔧 Configurer Jenkins:"
                        echo "   - Manage Jenkins → Configure System → SonarQube servers"
                        echo "   - Name: SonarQube, URL: http://localhost:9000"
                        echo "3. 🔑 Créer token SonarQube:"
                        echo "   - http://localhost:9000 → My Account → Security → Generate Token"
                        echo "   - Ajouter dans Jenkins credentials avec ID: sonarqube-token"
                        echo "4. 🛠️ Installer plugin: SonarQube Scanner"
                        echo ""
                        echo "⚠️ Le pipeline continue sans analyse SonarQube"
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
                                
                                // Login Docker Hub
                                sh "echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin"
                                
                                // Push des images
                                sh "docker push ${imageTag}"
                                sh "docker push ${latestTag}"
                                
                                // Logout
                                sh "docker logout"
                                
                                // Confirmation du succès
                                echo "✅ Images poussées avec succès sur Docker Hub!"
                                echo "📦 ${imageTag}"
                                echo "📦 ${latestTag}"
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
                                
                                // Login Docker Hub
                                bat "echo %DOCKER_PASS% | docker login -u %DOCKER_USER% --password-stdin"
                                
                                // Push des images
                                bat "docker push ${imageTag}"
                                bat "docker push ${latestTag}"
                                
                                // Logout
                                bat "docker logout"
                                
                                // Confirmation du succès
                                echo "✅ Images poussées avec succès sur Docker Hub!"
                                echo "📦 ${imageTag}"
                                echo "📦 ${latestTag}"
                            }
                        }
                    } catch (Exception e) {
                        echo "❌ Erreur Docker: ${e.getMessage()}"
                        
                        // Vérifier si les images ont quand même été poussées avec succès
                        def pushSucceeded = false
                        try {
                            if (isUnix()) {
                                def result = sh(script: "docker manifest inspect ${latestTag}", returnStatus: true)
                                pushSucceeded = (result == 0)
                            }
                        } catch (Exception manifestError) {
                            // Ignorer l'erreur de vérification
                        }
                        
                        if (pushSucceeded) {
                            echo "✅ Malgré l'erreur, les images ont été poussées avec succès !"
                            echo "� Vérifiez: https://hub.docker.com/r/louay11/student-management"
                        } else {
                            echo "�📋 CAUSES POSSIBLES:"
                            echo "1. Permissions Docker - Exécuter sur le serveur:"
                            echo "   sudo usermod -aG docker jenkins"
                            echo "   sudo systemctl restart jenkins"
                            echo "2. Image Docker introuvable - Vérifier le Dockerfile"
                            echo "3. Problème réseau - Vérifier la connexion Docker Hub"
                            currentBuild.result = 'UNSTABLE'
                        }
                        echo "⚠️  Le pipeline continue malgré l'échec Docker"
                    }
                }
            }
            post {
                success {
                    echo "🎉 SUCCESS: Images Docker créées et poussées !"
                    echo "📦 Images disponibles sur Docker Hub:"
                    echo "   - louay11/student-management:${env.BUILD_NUMBER}"
                    echo "   - louay11/student-management:latest"
                    echo "🐳 Usage: docker pull louay11/student-management:latest"
                    echo "🌐 Voir sur: https://hub.docker.com/r/louay11/student-management"
                }
                failure {
                    echo "❌ Stage Docker échoué"
                    echo "📋 Vérifiez:"
                    echo "   1. Repository Docker Hub : louay11/student-management"
                    echo "   2. Credentials Jenkins : docker-hub-credentials"
                    echo "   3. Connexion réseau Docker Hub"
                }
                unstable {
                    echo "⚠️  Stage Docker instable - mais push peut avoir réussi, vérifiez Docker Hub"
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