#!/bin/bash

echo "🔧 CONFIGURATION JENKINS POUR KUBERNETES"
echo "========================================"

# Variables
JENKINS_USER="jenkins"
KUBE_CONFIG_PATH="/var/lib/jenkins/.kube"

echo ""
echo "📋 Configuration de kubectl pour Jenkins..."

# Créer le répertoire .kube pour jenkins
echo "📁 Création du répertoire kubectl pour Jenkins..."
sudo mkdir -p $KUBE_CONFIG_PATH

# Copier la configuration kubectl
echo "📄 Copie de la configuration kubectl..."
sudo cp ~/.kube/config $KUBE_CONFIG_PATH/config

# Changer les permissions
echo "🔐 Configuration des permissions..."
sudo chown -R $JENKINS_USER:$JENKINS_USER $KUBE_CONFIG_PATH
sudo chmod 600 $KUBE_CONFIG_PATH/config

# Vérifier que Jenkins peut accéder à kubectl
echo ""
echo "🧪 Test de l'accès kubectl pour Jenkins..."
sudo -u jenkins kubectl cluster-info

if [ $? -eq 0 ]; then
    echo "✅ Jenkins peut maintenant accéder à Kubernetes!"
else
    echo "❌ Problème d'accès kubectl pour Jenkins"
    echo "💡 Solutions possibles:"
    echo "   1. Redémarrez Jenkins: sudo systemctl restart jenkins"
    echo "   2. Vérifiez les permissions du fichier config"
    echo "   3. Relancez ce script après le redémarrage"
fi

echo ""
echo "🔄 Redémarrage de Jenkins..."
sudo systemctl restart jenkins

echo ""
echo "⏳ Attente que Jenkins redémarre..."
sleep 10

echo ""
echo "✅ Configuration terminée!"
echo ""
echo "📋 Prochaines étapes:"
echo "1. Allez sur Jenkins: http://localhost:8080"
echo "2. Lancez un build avec DEPLOY_TO_K8S=true"
echo "3. Le stage Kubernetes devrait maintenant fonctionner!"