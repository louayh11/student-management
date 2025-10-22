# Dockerfile multi-stage pour optimiser la taille de l'image
FROM openjdk:17-jdk-alpine as builder

# Créer un répertoire de travail
WORKDIR /app

# Copier les fichiers Maven
COPY pom.xml .
COPY mvnw .
COPY .mvn .mvn

# Télécharger les dépendances (étape mise en cache)
RUN chmod +x ./mvnw && ./mvnw dependency:go-offline -B

# Copier le code source
COPY src src

# Construire l'application
RUN ./mvnw clean package -DskipTests

# Étape finale - image de production légère
FROM openjdk:17-jre-alpine

# Créer un utilisateur non-root pour la sécurité
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

# Définir le répertoire de travail
WORKDIR /app

# Copier le JAR depuis l'étape de build
COPY --from=builder /app/target/student-management-*.jar app.jar

# Changer le propriétaire des fichiers
RUN chown -R appuser:appgroup /app

# Basculer vers l'utilisateur non-root
USER appuser

# Exposer le port
EXPOSE 8089

# Variables d'environnement pour la configuration
ENV SPRING_PROFILES_ACTIVE=docker
ENV JAVA_OPTS=""

# Commande de démarrage avec optimisations JVM
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -Djava.security.egd=file:/dev/./urandom -jar app.jar"]

# Métadonnées
LABEL maintainer="louayh11"
LABEL description="Student Management System - Spring Boot Application"
LABEL version="1.0"