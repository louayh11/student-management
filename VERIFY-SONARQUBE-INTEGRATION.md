# 🔍 VÉRIFICATION INTÉGRATION JENKINS + SONARQUBE

## ✅ CHECKLIST CONFIGURATION JENKINS

### 1. Plugin SonarQube Scanner
**Vérifier:** Jenkins → Manage Jenkins → Manage Plugins → Installed plugins
- [ ] `SonarQube Scanner` installé et activé
- [ ] Version récente (4.x ou plus)

### 2. Credentials SonarQube
**Vérifier:** Jenkins → Manage Jenkins → Manage Credentials → System → Global
- [ ] Credential avec ID `sonarqube-token` existe
- [ ] Type `Secret text`
- [ ] Description contient "SonarQube"

### 3. Serveur SonarQube
**Vérifier:** Jenkins → Manage Jenkins → Configure System → SonarQube servers
- [ ] Serveur nommé `SonarQube` configuré
- [ ] URL: `http://localhost:9000`
- [ ] Token sélectionné: `sonarqube-token`
- [ ] **Test Connection** réussi (bouton dans l'interface)

### 4. SonarQube Scanner Tool
**Vérifier:** Jenkins → Manage Jenkins → Global Tool Configuration → SonarQube Scanner
- [ ] Tool nommé `SonarQube Scanner` configuré
- [ ] Installation automatique activée
- [ ] Version sélectionnée

## 🧪 TESTS D'INTÉGRATION

### Test 1: Configuration Jenkins
```bash
# Dans Jenkins, aller à Configure System → SonarQube servers
# Cliquer sur "Test Connection" à côté de votre serveur
# Résultat attendu: "Success" ou ✅
```

### Test 2: Build de Test
1. **Créer un job de test Jenkins:**
   - New Item → Pipeline
   - Pipeline script:
```groovy
pipeline {
    agent any
    stages {
        stage('Test SonarQube') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    echo "✅ SonarQube environment configuré"
                    echo "SONAR_HOST_URL: ${env.SONAR_HOST_URL}"
                    echo "SONAR_AUTH_TOKEN: [MASKED]"
                }
            }
        }
    }
}
```

### Test 3: Pipeline Principal
**Lancer votre pipeline student-management et vérifier:**

✅ **SUCCÈS - Signes positifs:**
```
[Pipeline] withSonarQubeEnv
Setting environment variable SONAR_HOST_URL
Setting environment variable SONAR_AUTH_TOKEN
[Pipeline] sh
+ mvn sonar:sonar ...
[INFO] Analysis report uploaded in XXXms
[INFO] ANALYSIS SUCCESSFUL
```

❌ **ÉCHEC - Signes négatifs:**
```
ERROR: SonarQube server 'SonarQube' not found
ERROR: Unable to locate 'report-task.txt'
ERROR: script returned exit code 1
```

## 📊 VÉRIFICATIONS POST-BUILD

### Dans SonarQube (http://localhost:9000):
1. **Projet visible:** student-management dans la liste
2. **Analyse récente:** Timestamp correspond au build Jenkins
3. **Métriques:** Bugs, Vulnerabilities, Code Smells affichés
4. **Quality Gate:** Status PASSED/FAILED visible

### Dans Jenkins:
1. **Console Output:** Messages SonarQube sans erreur
2. **Build Status:** SUCCESS (pas UNSTABLE)
3. **SonarQube Quality Gate:** Plugin affiche le statut (optionnel)

## 🎯 COMMANDES DE DIAGNOSTIC RAPIDE

### Test SonarQube accessible:
```bash
curl http://localhost:9000/api/system/status
# Attendu: {"status":"UP"}
```

### Test projet existe:
```bash
curl -u admin:admin "http://localhost:9000/api/projects/search?projects=student-management"
# Attendu: JSON contenant "student-management"
```

### Test dernière analyse:
```bash
curl -u admin:admin "http://localhost:9000/api/project_analyses/search?project=student-management&ps=1"
# Attendu: JSON avec analyses récentes
```

## 🚨 TROUBLESHOOTING RAPIDE

**Problème:** "SonarQube server not found"
**Solution:** Vérifier nom exact dans Configure System

**Problème:** "Unable to locate report-task.txt"  
**Solution:** Vérifier token et permissions SonarQube

**Problème:** "Connection refused"
**Solution:** Vérifier SonarQube running sur port 9000

**Problème:** "Authentication error"
**Solution:** Régénérer token SonarQube et mettre à jour Jenkins