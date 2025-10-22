# Configuration Docker Hub pour Jenkins

## 🐳 **CONFIGURATION REQUISE POUR DOCKER HUB PUSH**

### **ÉTAPE 1 : Créer le repository sur Docker Hub**

1. **Connectez-vous sur** https://hub.docker.com
2. **Cliquez sur "Create Repository"**
3. **Nom du repository** : `student-management`
4. **Visibilité** : Public ou Private (selon votre choix)
5. **Cliquez "Create"**

L'URL finale sera : `https://hub.docker.com/r/louay11/student-management`

### **ÉTAPE 2 : Configurer les credentials dans Jenkins**

#### **Via l'interface Jenkins :**

1. **Aller dans Jenkins** → "Manage Jenkins" → "Manage Credentials"
2. **Sélectionner** "System" → "Global credentials (unrestricted)"
3. **Cliquer** "Add Credentials"
4. **Configurer :**
   - **Kind** : Username with password
   - **Scope** : Global
   - **Username** : `louay11`
   - **Password** : `[votre-mot-de-passe-docker-hub]`
   - **ID** : `docker-hub-credentials`
   - **Description** : `Docker Hub Credentials for louayh11`
5. **Sauvegarder**

#### **Via script Groovy (alternative) :**

```groovy
// Script à exécuter dans Jenkins → Manage Jenkins → Script Console
import jenkins.model.*
import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.common.*
import com.cloudbees.plugins.credentials.domains.*
import com.cloudbees.plugins.credentials.impl.*

domain = Domain.global()
store = Jenkins.instance.getExtensionList('com.cloudbees.plugins.credentials.SystemCredentialsProvider')[0].getStore()

usernameAndPassword = new UsernamePasswordCredentialsImpl(
  CredentialsScope.GLOBAL,
  "docker-hub-credentials",
  "Docker Hub Credentials for louayh11",
  "louayh11",
  "VOTRE_MOT_DE_PASSE_DOCKER_HUB"
)

store.addCredentials(domain, usernameAndPassword)
```

### **ÉTAPE 3 : Vérifier la configuration**

Une fois les credentials configurés, le pipeline :
1. ✅ **Build** l'image localement
2. ✅ **Login** sur Docker Hub avec vos credentials
3. ✅ **Push** `louayh11/student-management:BUILD_NUMBER`
4. ✅ **Push** `louayh11/student-management:latest`
5. ✅ **Logout** de Docker Hub

### **🔒 SÉCURITÉ IMPORTANTE**

- ✅ **Utilisez un token d'accès** au lieu du mot de passe principal
- ✅ **Créez un token sur** https://hub.docker.com/settings/security
- ✅ **Utilisez ce token comme "password"** dans Jenkins

### **🧪 TEST MANUEL**

Pour tester manuellement :
```bash
# Login
docker login -u louayh11

# Tag l'image
docker tag student-management:latest louayh11/student-management:latest

# Push
docker push louayh11/student-management:latest

# Logout
docker logout
```

### **❌ TROUBLESHOOTING**

Si erreur `denied: requested access to the resource is denied` :
1. Vérifiez que le repository `louayh11/student-management` existe
2. Vérifiez vos credentials Jenkins
3. Vérifiez que vous êtes connecté : `docker login -u louayh11`

### **📊 RÉSULTAT**

Après configuration, vos images seront disponibles sur :
- `docker pull louay11/student-management:latest`
- `docker pull louay11/student-management:BUILD_NUMBER`