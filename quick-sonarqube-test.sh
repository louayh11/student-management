#!/bin/bash

echo "🎯 TEST RAPIDE INTÉGRATION SONARQUBE (3 étapes)"
echo "==============================================="

# Étape 1: SonarQube accessible
echo ""
echo "📊 ÉTAPE 1: Vérification SonarQube..."
STATUS=$(curl -s http://localhost:9000/api/system/status | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
if [ "$STATUS" = "UP" ]; then
    echo "✅ SonarQube UP et accessible"
else
    echo "❌ SonarQube non accessible - Vérifiez: docker ps | grep sonarqube"
    exit 1
fi

# Étape 2: Projet existe dans SonarQube
echo ""
echo "🔍 ÉTAPE 2: Recherche projet student-management..."
PROJECT_EXISTS=$(curl -s -u admin:admin "http://localhost:9000/api/projects/search?projects=student-management" | grep -c "student-management")
if [ "$PROJECT_EXISTS" -gt 0 ]; then
    echo "✅ Projet 'student-management' trouvé dans SonarQube"
    
    # Obtenir la dernière analyse
    LAST_ANALYSIS=$(curl -s -u admin:admin "http://localhost:9000/api/project_analyses/search?project=student-management&ps=1" | grep -o '"date":"[^"]*"' | head -1 | cut -d'"' -f4)
    if [ -n "$LAST_ANALYSIS" ]; then
        echo "📅 Dernière analyse: $LAST_ANALYSIS"
    else
        echo "⚠️ Aucune analyse trouvée pour ce projet"
    fi
else
    echo "❌ Projet 'student-management' NON trouvé"
    echo "💡 Le projet sera créé lors de la première analyse"
fi

# Étape 3: Test Jenkins (simulation)
echo ""
echo "🔧 ÉTAPE 3: Test configuration Jenkins..."
echo "⚠️ VÉRIFICATION MANUELLE REQUISE:"
echo ""
echo "Dans Jenkins (http://localhost:8080):"
echo "1. Manage Jenkins → Configure System → SonarQube servers"
echo "2. Cliquez sur 'Test Connection' à côte de votre serveur SonarQube"
echo "3. Résultat attendu: ✅ 'Success'"
echo ""
echo "Si 'Test Connection' montre SUCCESS, alors:"
echo "✅ Intégration Jenkins ↔ SonarQube OK"
echo ""
echo "Si 'Test Connection' échoue:"
echo "❌ Vérifiez token et configuration"

# Résumé
echo ""
echo "📋 RÉSUMÉ:"
echo "=========="
if [ "$STATUS" = "UP" ] && [ "$PROJECT_EXISTS" -gt 0 ]; then
    echo "✅ SonarQube: Opérationnel"
    echo "✅ Projet: Existant avec analyses"
    echo "🔧 Jenkins: Testez 'Test Connection' manuellement"
    echo ""
    echo "🚀 PRÊT POUR PIPELINE COMPLET!"
elif [ "$STATUS" = "UP" ]; then
    echo "✅ SonarQube: Opérationnel"
    echo "⚠️ Projet: Sera créé à la première analyse"
    echo "🔧 Jenkins: Testez 'Test Connection' manuellement"
    echo ""
    echo "🧪 LANCEZ UN BUILD POUR CRÉER LE PROJET!"
else
    echo "❌ SonarQube: Non accessible"
    echo "💡 Démarrez SonarQube: docker run -d -p 9000:9000 sonarqube:lts-community"
fi