# Configuration SonarQube + Jenkins

## 🔍 **INSTALLATION SONARQUBE**

### **Méthode Rapide :**
```bash
# Sur votre machine virtuelle
docker pull sonarqube:lts-community
docker run -d --name sonarqube -p 9000:9000 sonarqube:lts-community

# Vérifier l'installation
docker logs sonarqube
```

### **Méthode Complète (avec PostgreSQL) :**
```bash
# Utiliser le docker-compose fourni
docker-compose -f docker-compose-sonarqube.yml up -d

# Attendre le démarrage (2-3 minutes)
docker-compose -f docker-compose-sonarqube.yml logs sonarqube
```

## 🌐 **ACCÈS SONARQUBE**

1. **Ouvrir** : http://VOTRE-VM-IP:9000
2. **Login** : `admin` / `admin`
3. **Changer le mot de passe** lors de la première connexion

## 🔧 **CONFIGURATION JENKINS**

### **ÉTAPE 1 : Installer le Plugin SonarQube**
1. Jenkins → "Manage Jenkins" → "Manage Plugins"
2. Onglet "Available"
3. Chercher "SonarQube Scanner"
4. Installer et redémarrer Jenkins

### **ÉTAPE 2 : Configurer SonarQube Server**
1. Jenkins → "Manage Jenkins" → "Configure System"
2. Section "SonarQube servers"
3. Ajouter :
   - **Name** : `SonarQube`
   - **Server URL** : `http://VOTRE-VM-IP:9000`
   - **Server authentication token** : Créer un token dans SonarQube

### **ÉTAPE 3 : Créer un Token SonarQube**
1. Dans SonarQube : User → My Account → Security
2. Générer un token : `jenkins-token`
3. Copier le token

### **ÉTAPE 4 : Ajouter le Token dans Jenkins**
1. Jenkins → "Manage Jenkins" → "Manage Credentials"
2. Add Credentials :
   - **Kind** : Secret text
   - **Secret** : [votre-token-sonarqube]
   - **ID** : `sonarqube-token`

### **ÉTAPE 5 : Configurer SonarQube Scanner**
1. Jenkins → "Manage Jenkins" → "Global Tool Configuration"
2. Section "SonarQube Scanner"
3. Ajouter :
   - **Name** : `SonarQube Scanner`
   - **Install automatically** : Coché

## 📊 **UTILISATION**

Une fois configuré, le pipeline Jenkins :
1. ✅ **Compile** le projet
2. ✅ **Execute** les tests
3. 🔍 **Analyse** le code avec SonarQube
4. ⚡ **Vérifie** le Quality Gate
5. 📦 **Continue** vers Docker si OK

## 🎯 **RÉSULTATS SONARQUBE**

Le dashboard SonarQube affichera :
- **Bugs** détectés
- **Vulnerabilités** de sécurité
- **Code Smells** (mauvaises pratiques)
- **Coverage** des tests
- **Duplications** de code

## 🚀 **COMMANDES MANUELLES (TEST)**

```bash
# Test manuel de l'analyse SonarQube
mvn sonar:sonar \
  -Dsonar.projectKey=student-management \
  -Dsonar.host.url=http://VOTRE-VM-IP:9000 \
  -Dsonar.login=VOTRE-TOKEN
```

## ❌ **TROUBLESHOOTING**

**Erreur "SonarQube server not found"** :
- Vérifiez que SonarQube tourne : `docker ps | grep sonar`
- Testez l'URL : `curl http://VOTRE-VM-IP:9000`

**Erreur de token** :
- Recréez le token dans SonarQube
- Vérifiez les credentials Jenkins

**Quality Gate failed** :
- C'est normal pour un nouveau projet
- Configurez les règles dans SonarQube selon vos besoins