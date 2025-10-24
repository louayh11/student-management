#!/bin/bash

echo "🚀 DÉPLOIEMENT KUBERNETES - STUDENT MANAGEMENT"
echo "=============================================="

# Variables
NAMESPACE="student-management"
APP_NAME="student-management"
IMAGE_TAG=${1:-latest}

echo ""
echo "📋 Configuration:"
echo "   Namespace: $NAMESPACE"
echo "   Application: $APP_NAME"
echo "   Image Tag: $IMAGE_TAG"

# Fonction de vérification kubectl
check_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        echo "❌ kubectl n'est pas installé ou pas dans le PATH"
        echo "💡 Installez kubectl: https://kubernetes.io/docs/tasks/tools/"
        exit 1
    fi
    
    if ! kubectl cluster-info &> /dev/null; then
        echo "❌ Pas de connexion à un cluster Kubernetes"
        echo "💡 Configurez votre kubeconfig ou démarrez votre cluster"
        exit 1
    fi
    
    echo "✅ kubectl configuré et cluster accessible"
}

# Fonction de déploiement
deploy_kubernetes() {
    echo ""
    echo "🔧 Déploiement des ressources Kubernetes..."
    
    # Appliquer les manifests dans l'ordre
    echo "📝 Application du namespace et configuration..."
    kubectl apply -f k8s/00-namespace-config.yaml
    
    echo "🗄️ Déploiement de MySQL..."
    kubectl apply -f k8s/01-mysql.yaml
    
    echo "⏳ Attente que MySQL soit prêt..."
    kubectl wait --for=condition=ready pod -l app=mysql -n $NAMESPACE --timeout=300s
    
    echo "🚀 Déploiement de l'application..."
    # Mettre à jour l'image avec le tag spécifié
    sed "s|louay11/student-management:latest|louay11/student-management:$IMAGE_TAG|g" k8s/02-application.yaml | kubectl apply -f -
    
    echo "🌐 Configuration de l'ingress..."
    kubectl apply -f k8s/03-ingress.yaml
    
    echo "📊 Configuration de l'auto-scaling..."
    kubectl apply -f k8s/04-scaling.yaml
    
    echo ""
    echo "⏳ Attente que l'application soit prête..."
    kubectl wait --for=condition=ready pod -l app=$APP_NAME -n $NAMESPACE --timeout=300s
}

# Fonction de vérification du déploiement
verify_deployment() {
    echo ""
    echo "🔍 Vérification du déploiement..."
    
    echo ""
    echo "📦 Pods:"
    kubectl get pods -n $NAMESPACE
    
    echo ""
    echo "🌐 Services:"
    kubectl get services -n $NAMESPACE
    
    echo ""
    echo "📊 Deployments:"
    kubectl get deployments -n $NAMESPACE
    
    echo ""
    echo "🔗 Ingress:"
    kubectl get ingress -n $NAMESPACE
    
    # Vérifier les logs de l'application
    echo ""
    echo "📋 Logs récents de l'application:"
    kubectl logs -l app=$APP_NAME -n $NAMESPACE --tail=10
}

# Fonction d'information post-déploiement
post_deployment_info() {
    echo ""
    echo "🎉 DÉPLOIEMENT TERMINÉ!"
    echo "======================"
    
    echo ""
    echo "🔗 Accès à l'application:"
    echo "   URL: http://student-management.local"
    echo "   (Ajoutez cette ligne à votre /etc/hosts:)"
    echo "   <CLUSTER_IP> student-management.local"
    
    echo ""
    echo "📊 Commandes utiles:"
    echo "   Logs:      kubectl logs -f deployment/$APP_NAME -n $NAMESPACE"
    echo "   Status:    kubectl get all -n $NAMESPACE"
    echo "   Shell:     kubectl exec -it deployment/$APP_NAME -n $NAMESPACE -- /bin/sh"
    echo "   Port-forward: kubectl port-forward service/$APP_NAME-service 8080:80 -n $NAMESPACE"
    
    echo ""
    echo "🔧 Scaling manuel:"
    echo "   Scale up:  kubectl scale deployment $APP_NAME-app --replicas=5 -n $NAMESPACE"
    echo "   Scale down: kubectl scale deployment $APP_NAME-app --replicas=2 -n $NAMESPACE"
    
    echo ""
    echo "🗑️ Suppression:"
    echo "   kubectl delete namespace $NAMESPACE"
}

# Exécution principale
main() {
    echo "🚀 Début du déploiement Kubernetes..."
    
    check_kubectl
    deploy_kubernetes
    verify_deployment
    post_deployment_info
    
    echo ""
    echo "✅ Déploiement Kubernetes terminé avec succès!"
}

# Lancer le déploiement
main "$@"