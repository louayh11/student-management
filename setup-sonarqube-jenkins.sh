#!/bin/bash

echo "🔧 CONFIGURATION SONARQUBE + JENKINS"
echo "===================================="

# 1. Vérifier SonarQube
echo ""
echo "📊 1. Vérification SonarQube..."
SONAR_STATUS=$(curl -s http://localhost:9000/api/system/status | grep -o '"status":"[^"]*"' | cut -d'"' -f4)

if [ "$SONAR_STATUS" = "UP" ]; then
    echo "✅ SonarQube est opérationnel"
else
    echo "❌ SonarQube n'est pas accessible"
    echo "💡 Démarrez SonarQube avec:"
    echo "   docker run -d --name sonarqube -p 9000:9000 sonarqube:lts-community"
    exit 1
fi

# 2. Afficher les infos de connexion
echo ""
echo "🔑 2. Connexion SonarQube:"
echo "   URL: http://localhost:9000"
echo "   Login: admin"
echo "   Password: admin"

# 3. Instructions pour le token
echo ""
echo "🎫 3. Créer un token SonarQube:"
echo "   1. Allez sur http://localhost:9000"
echo "   2. Connectez-vous (admin/admin)"
echo "   3. Profil → My Account → Security"
echo "   4. Generate Token:"
echo "      - Name: jenkins-token"
echo "      - Type: User Token"
echo "      - Expires: Never"
echo "   5. COPIEZ LE TOKEN!"

# 4. Instructions Jenkins
echo ""
echo "⚙️ 4. Configuration Jenkins:"
echo "   1. Manage Jenkins → Manage Plugins → Install 'SonarQube Scanner'"
echo "   2. Manage Jenkins → Configure System → SonarQube servers:"
echo "      - Name: SonarQube"
echo "      - Server URL: http://localhost:9000"
echo "      - Server authentication token: [sélectionner sonarqube-token]"
echo "   3. Manage Jenkins → Manage Credentials → Add:"
echo "      - Kind: Secret text"
echo "      - Secret: [votre-token-sonarqube]"
echo "      - ID: sonarqube-token"
echo "   4. Manage Jenkins → Global Tool Configuration → SonarQube Scanner:"
echo "      - Name: SonarQube Scanner"
echo "      - Install automatically: ✅"

# 5. Test de configuration
echo ""
echo "🧪 5. Pour tester la configuration:"
echo "   mvn sonar:sonar -Dsonar.projectKey=test -Dsonar.host.url=http://localhost:9000 -Dsonar.login=YOUR_TOKEN"

echo ""
echo "✅ Configuration terminée! Relancez votre pipeline Jenkins."