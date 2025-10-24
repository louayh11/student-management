#!/bin/bash

echo "🚀 DÉMARRAGE KUBERNETES POUR STUDENT-MANAGEMENT"
echo "==============================================="

# Fonction de vérification
check_requirements() {
    echo "🔍 Vérification des prérequis..."
    
    # Vérifier kubectl
    if ! command -v kubectl &> /dev/null; then
        echo "❌ kubectl non installé. Lancez d'abord: ./install-kubernetes.sh"
        exit 1
    fi
    
    # Vérifier minikube
    if ! command -v minikube &> /dev/null; then
        echo "❌ minikube non installé. Lancez d'abord: ./install-kubernetes.sh"
        exit 1
    fi
    
    echo "✅ Prérequis OK"
}

# Fonction de démarrage de Minikube
start_minikube() {
    echo ""
    echo "☸️ Démarrage de Minikube..."
    
    # Vérifier si Minikube est déjà en cours
    if minikube status | grep -q "Running"; then
        echo "✅ Minikube déjà en cours d'exécution"
    else
        echo "🚀 Démarrage de Minikube avec configuration optimisée..."
        minikube start \
            --memory=4096 \
            --cpus=2 \
            --disk-size=20g \
            --driver=docker \
            --kubernetes-version=stable
        
        if [ $? -eq 0 ]; then
            echo "✅ Minikube démarré avec succès"
        else
            echo "❌ Erreur lors du démarrage de Minikube"
            exit 1
        fi
    fi
}

# Fonction d'activation des addons
enable_addons() {
    echo ""
    echo "🔧 Activation des addons nécessaires..."
    
    # Ingress controller (pour l'accès externe)
    echo "📡 Activation de l'Ingress..."
    minikube addons enable ingress
    
    # Dashboard (optionnel, pour le monitoring)
    echo "📊 Activation du Dashboard..."
    minikube addons enable dashboard
    
    # Metrics server (pour l'autoscaling)
    echo "📈 Activation du Metrics Server..."
    minikube addons enable metrics-server
    
    echo "✅ Addons activés"
}

# Fonction de vérification du cluster
verify_cluster() {
    echo ""
    echo "🧪 Vérification du cluster..."
    
    # Attendre que le cluster soit prêt
    echo "⏳ Attente que le cluster soit prêt..."
    kubectl wait --for=condition=Ready nodes --all --timeout=300s
    
    # Afficher les informations du cluster
    echo ""
    echo "📊 Informations du cluster:"
    echo "=========================="
    kubectl cluster-info
    
    echo ""
    echo "🔗 Nœuds disponibles:"
    kubectl get nodes -o wide
    
    echo ""
    echo "📦 Addons actifs:"
    minikube addons list | grep enabled
}

# Fonction d'information post-installation
post_install_info() {
    echo ""
    echo "🎉 KUBERNETES PRÊT POUR STUDENT-MANAGEMENT!"
    echo "==========================================="
    
    echo ""
    echo "🌐 Accès au cluster:"
    echo "   Dashboard: minikube dashboard"
    echo "   Service URL: minikube service <service-name> -n <namespace>"
    
    echo ""
    echo "🚀 Déployer votre application:"
    echo "   1. Via Jenkins: Cochez 'DEPLOY_TO_K8S' dans le build"
    echo "   2. Via script: ./deploy-k8s.sh latest"
    echo "   3. Manuel: kubectl apply -f k8s/"
    
    echo ""
    echo "📋 Commandes utiles:"
    echo "   minikube status           # Statut du cluster"
    echo "   minikube stop            # Arrêter le cluster"
    echo "   minikube delete          # Supprimer le cluster"
    echo "   kubectl get all          # Voir toutes les ressources"
    echo "   kubectl get pods -A      # Voir tous les pods"
    
    echo ""
    echo "🔧 Configuration Jenkins:"
    echo "   Le cluster est maintenant prêt pour vos déploiements!"
    echo "   Jenkins utilisera automatiquement cette configuration kubectl."
}

# Exécution principale
main() {
    check_requirements
    start_minikube
    enable_addons
    verify_cluster
    post_install_info
    
    echo ""
    echo "✅ Kubernetes est maintenant opérationnel pour votre projet!"
}

# Gestion des erreurs
set -e
trap 'echo "❌ Erreur détectée. Vérifiez les logs ci-dessus."' ERR

# Lancer le script
main "$@"