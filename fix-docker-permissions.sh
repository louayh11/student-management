#!/bin/bash
# Script de configuration post-démarrage pour Docker + Jenkins
# À placer dans /etc/init.d/ ou comme service systemd

echo "🔧 Configuration Docker + Jenkins post-démarrage..."

# Attendre que Docker soit prêt
sleep 10

# Vérifier que Docker fonctionne
if ! docker ps > /dev/null 2>&1; then
    echo "❌ Docker n'est pas démarré"
    sudo systemctl start docker
    sleep 5
fi

# Configurer les permissions du socket Docker
sudo chmod 666 /var/run/docker.sock
sudo chown root:docker /var/run/docker.sock

# Vérifier que jenkins est dans le groupe docker
if ! groups jenkins | grep -q docker; then
    echo "📝 Ajout de jenkins au groupe docker..."
    sudo usermod -aG docker jenkins
fi

# Redémarrer Jenkins pour appliquer les permissions
sudo systemctl restart jenkins

# Test final
sleep 10
if sudo -u jenkins docker ps > /dev/null 2>&1; then
    echo "✅ Configuration Docker + Jenkins OK"
else
    echo "❌ Problème de configuration persistant"
fi

echo "🎉 Script terminé"