#!/bin/bash

echo "🔍 DIAGNOSTIC COMPLET JENKINS ↔ SONARQUBE"
echo "========================================="

echo ""
echo "📊 1. Vérification SonarQube..."
SONAR_STATUS=$(curl -s http://localhost:9000/api/system/status)
echo "Status SonarQube: $SONAR_STATUS"

if echo "$SONAR_STATUS" | grep -q '"status":"UP"'; then
    echo "✅ SonarQube opérationnel"
else
    echo "❌ SonarQube non accessible"
    exit 1
fi

echo ""
echo "🔑 2. Test d'authentification avec token..."
TOKEN="squ_1363364553b90b454d114a30fce94ead1548e5da"
AUTH_TEST=$(curl -s -H "Authorization: Bearer $TOKEN" "http://localhost:9000/api/authentication/validate")
echo "Test authentification: $AUTH_TEST"

if echo "$AUTH_TEST" | grep -q '"valid":true'; then
    echo "✅ Token SonarQube valide"
else
    echo "❌ Token SonarQube invalide ou expiré"
    echo "💡 Régénérez le token dans SonarQube"
fi

echo ""
echo "🔧 3. Vérifications Jenkins nécessaires..."
echo ""
echo "Dans Jenkins (http://localhost:8080), vérifiez:"
echo ""
echo "A. PLUGIN SONARQUBE SCANNER:"
echo "   → Manage Jenkins → Manage Plugins → Installed"
echo "   → Rechercher 'SonarQube Scanner'"
echo "   → Status: ✅ Installé et activé"
echo ""
echo "B. CREDENTIALS:"
echo "   → Manage Jenkins → Manage Credentials → System → Global"
echo "   → ID: sonarqube-token"
echo "   → Type: Secret text"
echo "   → Secret: $TOKEN"
echo ""
echo "C. SERVER CONFIGURATION:"
echo "   → Manage Jenkins → Configure System → SonarQube servers"
echo "   → Name: SonarQube (exactement ce nom)"
echo "   → Server URL: http://localhost:9000"
echo "   → Server authentication token: sonarqube-token"
echo "   → ⚠️ CLIQUEZ SUR 'Test Connection' → Doit afficher SUCCESS"
echo ""
echo "D. TOOL CONFIGURATION:"
echo "   → Manage Jenkins → Global Tool Configuration → SonarQube Scanner"
echo "   → Name: SonarQube Scanner"
echo "   → Install automatically: ✅ Coché"
echo ""

echo "🧪 4. Test manuel Maven + SonarQube..."
echo ""
echo "Copiez cette commande sur votre VM (dans le répertoire du projet):"
echo ""
echo "mvn clean compile sonar:sonar \\"
echo "  -Dsonar.projectKey=student-management \\"
echo "  -Dsonar.host.url=http://localhost:9000 \\"
echo "  -Dsonar.login=$TOKEN"
echo ""
echo "Si cette commande réussit manuellement mais échoue dans Jenkins,"
echo "alors le problème est dans la configuration Jenkins."

echo ""
echo "📋 5. CHECKLIST CONFIGURATION:"
echo "=============================="
echo "□ Plugin SonarQube Scanner installé"
echo "□ Token ajouté dans credentials avec ID 'sonarqube-token'"
echo "□ Serveur configuré avec nom 'SonarQube'"
echo "□ URL serveur: http://localhost:9000 (avec :9000)"
echo "□ Token sélectionné dans la configuration serveur"
echo "□ Test Connection = SUCCESS"
echo "□ SonarQube Scanner tool configuré"
echo ""
echo "Si tous les □ sont cochés ✅ mais que ça échoue encore:"
echo "🔄 Redémarrez Jenkins: sudo systemctl restart jenkins"