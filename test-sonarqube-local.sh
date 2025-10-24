#!/bin/bash

echo "🧪 TEST SONARQUBE LOCAL"
echo "======================"

# Vérifier SonarQube
echo "📊 1. Vérification SonarQube..."
SONAR_STATUS=$(curl -s http://localhost:9000/api/system/status | grep -o '"status":"[^"]*"' | cut -d'"' -f4)

if [ "$SONAR_STATUS" = "UP" ]; then
    echo "✅ SonarQube opérationnel"
else
    echo "❌ SonarQube non accessible"
    exit 1
fi

# Aller dans le répertoire du projet
echo ""
echo "📁 2. Navigation vers le projet..."
PROJECT_DIR=$(find /home -name "student-management" -type d 2>/dev/null | head -1)

if [ -z "$PROJECT_DIR" ]; then
    echo "❌ Répertoire student-management non trouvé"
    echo "💡 Naviguez manuellement vers votre projet et exécutez:"
    echo "   mvn clean compile sonar:sonar -Dsonar.projectKey=student-management -Dsonar.host.url=http://localhost:9000 -Dsonar.login=squ_1363364553b90b454d114a30fce94ead1548e5da"
    exit 1
fi

echo "✅ Projet trouvé: $PROJECT_DIR"
cd "$PROJECT_DIR"

# Vérifier pom.xml
if [ ! -f "pom.xml" ]; then
    echo "❌ pom.xml non trouvé dans $PROJECT_DIR"
    exit 1
fi

echo "✅ pom.xml trouvé"

# Lancer l'analyse SonarQube
echo ""
echo "🔍 3. Lancement analyse SonarQube..."
mvn clean compile sonar:sonar \
    -Dsonar.projectKey=student-management \
    -Dsonar.projectName="Student Management System" \
    -Dsonar.host.url=http://localhost:9000 \
    -Dsonar.login=squ_1363364553b90b454d114a30fce94ead1548e5da \
    -Dsonar.sources=src/main/java \
    -Dsonar.tests=src/test/java \
    -Dsonar.java.binaries=target/classes

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ ANALYSE SONARQUBE RÉUSSIE!"
    echo "📊 Consultez les résultats: http://localhost:9000"
    echo "🔍 Projet: student-management"
else
    echo ""
    echo "❌ Échec de l'analyse SonarQube"
    exit 1
fi