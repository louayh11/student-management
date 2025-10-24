#!/bin/bash

echo "🔍 VÉRIFICATION INTÉGRATION SONARQUBE"
echo "===================================="

echo ""
echo "📊 1. Vérification SonarQube Web Interface..."
echo "   → Ouvrez: http://localhost:9000"
echo "   → Login: admin / admin"
echo "   → Recherchez le projet 'student-management'"
echo ""

echo "✅ SIGNES D'INTÉGRATION RÉUSSIE:"
echo "   - Projet 'student-management' visible dans la liste"
echo "   - Dernière analyse avec timestamp récent"
echo "   - Métriques affichées (Bugs, Vulnerabilities, Code Smells)"
echo "   - Quality Gate status (PASSED/FAILED)"
echo ""

echo "❌ SIGNES D'ÉCHEC:"
echo "   - Aucun projet 'student-management'"
echo "   - Dernière analyse très ancienne"
echo "   - Message d'erreur sur la page projet"
echo ""

# Test API SonarQube
echo "🧪 2. Test API SonarQube..."
RESPONSE=$(curl -s -u admin:admin "http://localhost:9000/api/projects/search?projects=student-management")

if echo "$RESPONSE" | grep -q "student-management"; then
    echo "✅ Projet trouvé via API SonarQube"
    
    # Récupérer les métriques
    METRICS=$(curl -s -u admin:admin "http://localhost:9000/api/measures/component?component=student-management&metricKeys=bugs,vulnerabilities,code_smells,coverage,ncloc")
    
    if echo "$METRICS" | grep -q "bugs"; then
        echo "✅ Métriques disponibles via API"
        echo "📊 Détails des métriques:"
        echo "$METRICS" | python3 -m json.tool 2>/dev/null || echo "$METRICS"
    else
        echo "⚠️ Projet trouvé mais métriques manquantes"
    fi
else
    echo "❌ Projet NON trouvé via API"
    echo "Response: $RESPONSE"
fi