# Configuration Docker pour Jenkins

## ⚠️ Problème de Permission Docker

Si vous voyez cette erreur dans Jenkins :
```
ERROR: permission denied while trying to connect to the Docker daemon socket
```

## 🔧 Solution Rapide

### Méthode 1 : Script Automatique
```bash
# Exécuter le script de configuration
chmod +x configure-docker.sh
sudo ./configure-docker.sh
```

### Méthode 2 : Configuration Manuelle
```bash
# 1. Ajouter jenkins au groupe docker
sudo usermod -aG docker jenkins

# 2. Changer les permissions du socket Docker
sudo chmod 666 /var/run/docker.sock

# 3. Redémarrer Docker
sudo systemctl restart docker

# 4. Redémarrer Jenkins
sudo systemctl restart jenkins

# 5. Tester
sudo -u jenkins docker --version
```

### Méthode 3 : Configuration Permanente
Pour une solution permanente, éditer `/etc/docker/daemon.json` :
```json
{
  "group": "docker",
  "live-restore": true
}
```

Puis redémarrer Docker :
```bash
sudo systemctl restart docker
```

## 🚀 Test du Pipeline

Après la configuration, le pipeline Jenkins devrait :
1. ✅ Compiler l'application
2. ✅ Exécuter les tests  
3. ✅ Créer le package JAR
4. ✅ **Construire l'image Docker**
5. ✅ Archiver les artifacts

## 🐳 Utilisation Docker

### Build Manuel
```bash
docker build -t student-management:latest .
```

### Run avec Docker
```bash
docker run -p 8089:8089 student-management:latest
```

### Déploiement avec Docker Compose
```bash
docker-compose up -d
```

## 📊 Vérifications

```bash
# Vérifier que jenkins est dans le groupe docker
groups jenkins

# Vérifier les permissions du socket Docker
ls -la /var/run/docker.sock

# Tester Docker en tant que jenkins
sudo -u jenkins docker ps
```

## 🔍 Troubleshooting

Si le problème persiste :
1. Vérifier que Docker est en cours d'exécution : `sudo systemctl status docker`
2. Vérifier les logs Jenkins : `sudo journalctl -u jenkins -f`
3. Redémarrer complètement la machine si nécessaire