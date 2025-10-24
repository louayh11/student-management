# 🚀 GUIDE D'INSTALLATION KUBERNETES - STUDENT MANAGEMENT

## 📋 INSTALLATION EN 4 ÉTAPES SIMPLES

### ÉTAPE 1: Copier les scripts sur votre VM
```bash
# Sur votre VM Ubuntu, copiez ces fichiers depuis votre repository GitHub
# Ou transférez-les depuis Windows
```

### ÉTAPE 2: Installation de Kubernetes
```bash
# Rendre le script exécutable
chmod +x install-kubernetes.sh

# Lancer l'installation (prend ~5-10 minutes)
./install-kubernetes.sh

# IMPORTANT: Redémarrer votre session après l'installation
exit
# Reconnectez-vous à votre VM
```

### ÉTAPE 3: Démarrer Kubernetes
```bash
# Rendre le script exécutable
chmod +x start-kubernetes.sh

# Démarrer Minikube et configurer le cluster
./start-kubernetes.sh
```

### ÉTAPE 4: Configurer Jenkins
```bash
# Configurer Jenkins pour utiliser Kubernetes
chmod +x configure-jenkins-k8s.sh
./configure-jenkins-k8s.sh
```

## ✅ VÉRIFICATION DE L'INSTALLATION

### Test 1: Kubernetes fonctionne
```bash
kubectl get nodes
# Résultat attendu: 1 node "Ready"

minikube status
# Résultat attendu: "Running"
```

### Test 2: Déploiement manuel
```bash
# Test du déploiement
./deploy-k8s.sh latest

# Vérification
kubectl get all -n student-management
```

### Test 3: Jenkins + Kubernetes
1. **Allez sur Jenkins:** http://localhost:8080
2. **Lancez un build** avec paramètre `DEPLOY_TO_K8S=true`
3. **Vérifiez** que le stage Kubernetes passe en SUCCESS

## 🌐 ACCÈS À L'APPLICATION

Une fois déployée sur Kubernetes:

### Méthode 1: Port-forward (Simple)
```bash
kubectl port-forward service/student-management-service 8080:80 -n student-management
# Accès: http://localhost:8080
```

### Méthode 2: Ingress (Avancé)
```bash
# Ajouter à /etc/hosts
echo "$(minikube ip) student-management.local" | sudo tee -a /etc/hosts

# Accès: http://student-management.local
```

### Méthode 3: Minikube service
```bash
minikube service student-management-service -n student-management
# Ouvre automatiquement l'URL dans le navigateur
```

## 📊 MONITORING ET DEBUG

### Voir les pods
```bash
kubectl get pods -n student-management
kubectl logs -f deployment/student-management-app -n student-management
```

### Dashboard Kubernetes
```bash
minikube dashboard
# Ouvre l'interface web de Kubernetes
```

### Scaling
```bash
# Scaler manuellement
kubectl scale deployment student-management-app --replicas=5 -n student-management

# Voir l'autoscaling
kubectl get hpa -n student-management
```

## 🗑️ NETTOYAGE

### Supprimer l'application
```bash
kubectl delete namespace student-management
```

### Arrêter Kubernetes
```bash
minikube stop
```

### Supprimer complètement
```bash
minikube delete
```

## 🚨 TROUBLESHOOTING

### Problème: Minikube ne démarre pas
```bash
# Vérifier Docker
sudo systemctl status docker

# Redémarrer Docker
sudo systemctl restart docker

# Réessayer Minikube
minikube delete
minikube start
```

### Problème: Jenkins ne peut pas accéder à kubectl
```bash
# Relancer la configuration
./configure-jenkins-k8s.sh

# Vérifier les permissions
sudo ls -la /var/lib/jenkins/.kube/
```

### Problème: Pods en erreur
```bash
# Voir les logs détaillés
kubectl describe pod <POD_NAME> -n student-management
kubectl logs <POD_NAME> -n student-management
```

## 🎉 RÉSULTAT FINAL

Après installation complète, vous aurez:

```
✅ Kubernetes cluster (Minikube)
✅ Jenkins intégré avec Kubernetes  
✅ Pipeline automatisé complet:
   Git → Jenkins → Tests → SonarQube → Docker → Kubernetes → SUCCESS!
✅ Application déployée avec auto-scaling
✅ Monitoring et observabilité
```

**Votre pipeline DevOps sera alors 100% complet et professionnel !** 🚀