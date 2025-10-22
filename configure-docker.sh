#!/bin/bash
# Script de configuration Docker pour Jenkins
# Ce script doit être exécuté avec des privilèges sudo sur le serveur Jenkins

echo "🔧 Configuration Docker pour Jenkins..."

# Vérifier si Docker est installé
if ! command -v docker &> /dev/null; then
    echo "❌ Docker n'est pas installé. Installation..."
    # Installation Docker (Ubuntu/Debian)
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    rm get-docker.sh
else
    echo "✅ Docker est déjà installé"
fi

# Créer le groupe docker s'il n'existe pas
if ! getent group docker > /dev/null 2>&1; then
    echo "📝 Création du groupe docker..."
    sudo groupadd docker
else
    echo "✅ Le groupe docker existe déjà"
fi

# Ajouter l'utilisateur jenkins au groupe docker
echo "👥 Ajout de l'utilisateur jenkins au groupe docker..."
sudo usermod -aG docker jenkins

# Changer les permissions du socket Docker
echo "🔐 Configuration des permissions Docker..."
sudo chmod 666 /var/run/docker.sock

# Optionnel: Changer le propriétaire du socket Docker
sudo chown root:docker /var/run/docker.sock

# Redémarrer les services
echo "🔄 Redémarrage des services..."
sudo systemctl restart docker

# Attendre que Docker soit prêt
sleep 5

# Vérifier la configuration
echo "🧪 Test de la configuration..."
if sudo -u jenkins docker --version; then
    echo "✅ Configuration Docker réussie!"
    echo "🔄 Redémarrez Jenkins pour appliquer les changements:"
    echo "   sudo systemctl restart jenkins"
else
    echo "❌ Problème de configuration détecté"
fi

echo ""
echo "📋 COMMANDES MANUELLES SI NÉCESSAIRE:"
echo "1. Ajouter jenkins au groupe docker:"
echo "   sudo usermod -aG docker jenkins"
echo ""
echo "2. Redémarrer Docker:"
echo "   sudo systemctl restart docker"
echo ""
echo "3. Redémarrer Jenkins:"
echo "   sudo systemctl restart jenkins"
echo ""
echo "4. Tester manuellement:"
echo "   sudo -u jenkins docker --version"
echo ""
echo "5. Si le problème persiste, exécuter:"
echo "   sudo chmod 666 /var/run/docker.sock"