#!/bin/bash

echo "🚀 INSTALLATION KUBERNETES (MINIKUBE) SUR UBUNTU"
echo "==============================================="

# Vérification des prérequis
echo ""
echo "📋 1. Vérification du système..."
echo "OS: $(lsb_release -d | cut -f2)"
echo "Architecture: $(uname -m)"
echo "RAM: $(free -h | grep Mem | awk '{print $2}')"
echo "CPU cores: $(nproc)"

# Mise à jour du système
echo ""
echo "📦 2. Mise à jour du système..."
sudo apt update && sudo apt upgrade -y

# Installation des dépendances
echo ""
echo "🔧 3. Installation des dépendances..."
sudo apt install -y curl wget apt-transport-https ca-certificates gnupg lsb-release

# Installation de Docker (si pas déjà installé)
echo ""
echo "🐳 4. Vérification/Installation de Docker..."
if ! command -v docker &> /dev/null; then
    echo "Installation de Docker..."
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io
    sudo usermod -aG docker $USER
    echo "✅ Docker installé"
else
    echo "✅ Docker déjà installé"
fi

# Installation de kubectl
echo ""
echo "⚙️ 5. Installation de kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
echo "✅ kubectl installé: $(kubectl version --client --short 2>/dev/null || echo 'OK')"

# Installation de Minikube
echo ""
echo "☸️ 6. Installation de Minikube..."
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
chmod +x minikube-linux-amd64
sudo mv minikube-linux-amd64 /usr/local/bin/minikube
echo "✅ Minikube installé: $(minikube version --short)"

echo ""
echo "🎉 INSTALLATION TERMINÉE!"
echo "========================"
echo ""
echo "📋 Prochaines étapes:"
echo "1. Redémarrez votre session (pour Docker group)"
echo "2. Lancez: minikube start"
echo "3. Testez: kubectl get nodes"
echo ""
echo "💡 Commandes utiles:"
echo "   minikube start    # Démarrer le cluster"
echo "   minikube stop     # Arrêter le cluster"  
echo "   minikube status   # Statut du cluster"
echo "   kubectl get nodes # Voir les nœuds"