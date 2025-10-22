#!/bin/bash
# Script pour créer automatiquement le repository Docker Hub
# Usage: ./create-docker-repo.sh [DOCKER_USERNAME] [DOCKER_PASSWORD] [REPO_NAME]

DOCKER_USERNAME=${1:-louayh11}
DOCKER_PASSWORD=$2
REPO_NAME=${3:-student-management}

if [ -z "$DOCKER_PASSWORD" ]; then
    echo "❌ Usage: $0 [username] <password> [repo_name]"
    echo "   Exemple: $0 louayh11 my_password student-management"
    exit 1
fi

echo "🔑 Login Docker Hub..."
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

if [ $? -eq 0 ]; then
    echo "✅ Login réussi"
    
    # Créer une image temporaire pour initialiser le repo
    echo "📦 Création d'une image temporaire..."
    cat > Dockerfile.temp << EOF
FROM alpine:latest
RUN echo "Repository initialization" > /tmp/init.txt
CMD ["cat", "/tmp/init.txt"]
EOF
    
    docker build -f Dockerfile.temp -t ${DOCKER_USERNAME}/${REPO_NAME}:init .
    
    echo "🚀 Push initial pour créer le repository..."
    docker push ${DOCKER_USERNAME}/${REPO_NAME}:init
    
    if [ $? -eq 0 ]; then
        echo "✅ Repository ${DOCKER_USERNAME}/${REPO_NAME} créé avec succès !"
        echo "🗑️  Nettoyage..."
        docker rmi ${DOCKER_USERNAME}/${REPO_NAME}:init
        rm -f Dockerfile.temp
    else
        echo "❌ Échec de création du repository"
        rm -f Dockerfile.temp
        exit 1
    fi
else
    echo "❌ Échec du login Docker Hub"
    exit 1
fi

echo "🎉 Prêt ! Vous pouvez maintenant relancer votre pipeline Jenkins"