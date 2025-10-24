# 🚀 GUIDE KUBERNETES - STUDENT MANAGEMENT

## 📋 PRÉREQUIS

### 1. Cluster Kubernetes
Vous avez besoin d'un cluster Kubernetes fonctionnel. Options :

#### Option A: Minikube (Local)
```bash
# Installation Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Démarrer Minikube
minikube start --memory=4096 --cpus=2
minikube addons enable ingress
```

#### Option B: Kind (Local)
```bash
# Installation Kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Créer cluster
kind create cluster --name student-management
```

#### Option C: Cloud (AWS EKS, GKE, AKS)
Suivez la documentation de votre provider cloud.

### 2. kubectl
```bash
# Installation kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```

### 3. Ingress Controller (Nginx)
```bash
# Pour Minikube
minikube addons enable ingress

# Pour autres clusters
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml
```

## 🚀 DÉPLOIEMENT

### Méthode 1: Pipeline Jenkins (Automatique)
1. **Lancez un build Jenkins**
2. **Cochez "DEPLOY_TO_K8S"** dans les paramètres
3. **Le pipeline déploiera automatiquement**

### Méthode 2: Script manuel
```bash
# Rendre exécutable
chmod +x deploy-k8s.sh

# Déployer avec la dernière version
./deploy-k8s.sh latest

# Déployer avec un tag spécifique
./deploy-k8s.sh 27
```

### Méthode 3: kubectl direct
```bash
# Appliquer tous les manifests
kubectl apply -f k8s/

# Ou un par un
kubectl apply -f k8s/00-namespace-config.yaml
kubectl apply -f k8s/01-mysql.yaml
kubectl apply -f k8s/02-application.yaml
kubectl apply -f k8s/03-ingress.yaml
kubectl apply -f k8s/04-scaling.yaml
```

## 🔧 CONFIGURATION

### Variables d'environnement
Modifiez `k8s/00-namespace-config.yaml` pour ajuster :
- URL de la base de données
- Utilisateur/mot de passe
- Configuration Spring Boot

### Scaling
```bash
# Scaling manuel
kubectl scale deployment student-management-app --replicas=5 -n student-management

# Auto-scaling configuré dans 04-scaling.yaml
# Min: 2 replicas, Max: 10 replicas
# Trigger: CPU > 70% ou Memory > 80%
```

### Ingress/Accès
1. **Ajoutez à votre /etc/hosts :**
   ```
   <CLUSTER_IP> student-management.local
   ```

2. **Ou utilisez port-forward :**
   ```bash
   kubectl port-forward service/student-management-service 8080:80 -n student-management
   ```

## 📊 MONITORING ET DEBUG

### Status général
```bash
kubectl get all -n student-management
```

### Logs
```bash
# Logs de l'application
kubectl logs -f deployment/student-management-app -n student-management

# Logs MySQL
kubectl logs -f deployment/mysql -n student-management

# Logs d'un pod spécifique
kubectl logs <POD_NAME> -n student-management
```

### Debug
```bash
# Décrire les pods
kubectl describe pods -n student-management

# Entrer dans un pod
kubectl exec -it deployment/student-management-app -n student-management -- /bin/sh

# Events du namespace
kubectl get events -n student-management --sort-by='.lastTimestamp'
```

### Métriques
```bash
# HPA status
kubectl get hpa -n student-management

# Resource usage
kubectl top pods -n student-management
kubectl top nodes
```

## 🔧 MAINTENANCE

### Mise à jour
```bash
# Nouvelle version de l'image
kubectl set image deployment/student-management-app student-management=louay11/student-management:NEW_TAG -n student-management

# Restart deployment
kubectl rollout restart deployment/student-management-app -n student-management

# Rollback
kubectl rollout undo deployment/student-management-app -n student-management
```

### Nettoyage
```bash
# Supprimer l'application
kubectl delete -f k8s/

# Ou supprimer le namespace complet
kubectl delete namespace student-management
```

## 🌐 ACCÈS À L'APPLICATION

Une fois déployée, l'application est accessible via :

1. **Ingress URL :** http://student-management.local
2. **Port-forward :** http://localhost:8080 (après port-forward)
3. **NodePort :** http://<NODE_IP>:<NODE_PORT>

### Endpoints disponibles
- **Application :** `/`
- **Health check :** `/actuator/health`
- **API Students :** `/api/students`
- **API Departments :** `/api/departments`
- **API Enrollments :** `/api/enrollments`

## 🎯 ARCHITECTURE DÉPLOYÉE

```
Internet
    ↓
[Ingress Controller]
    ↓
[Student Management Service] (Load Balancer)
    ↓
[Student Management Pods] (3 replicas + HPA)
    ↓
[MySQL Service]
    ↓
[MySQL Pod] (avec Persistent Volume)
```

## 🚨 TROUBLESHOOTING

### Problèmes courants

1. **Pods en CrashLoopBackOff**
   ```bash
   kubectl logs <POD_NAME> -n student-management
   kubectl describe pod <POD_NAME> -n student-management
   ```

2. **MySQL ne démarre pas**
   ```bash
   kubectl logs deployment/mysql -n student-management
   # Vérifiez les PVC
   kubectl get pvc -n student-management
   ```

3. **Application ne se connecte pas à MySQL**
   ```bash
   # Vérifiez la connectivité réseau
   kubectl exec -it deployment/student-management-app -n student-management -- nc -zv mysql-service 3306
   ```

4. **Ingress ne fonctionne pas**
   ```bash
   kubectl get ingress -n student-management
   kubectl describe ingress student-management-ingress -n student-management
   ```

## 🎉 SUCCÈS !

Si tout fonctionne, vous devriez voir :
- ✅ Tous les pods "Running"
- ✅ Services accessibles
- ✅ Application répond sur l'URL configurée
- ✅ Base de données MySQL opérationnelle
- ✅ Auto-scaling fonctionnel