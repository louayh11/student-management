# Student Management System

Ce projet est une application Spring Boot pour la gestion d'étudiants développée avec Java.

## Structure du projet

- **Entités** : Student, Course, Department, Enrollment
- **Contrôleurs** : Gestion des API REST pour les étudiants, départements et inscriptions
- **Services** : Logique métier pour la gestion des entités
- **Repositories** : Accès aux données avec Spring Data JPA

## Technologies utilisées

- Spring Boot
- Spring Data JPA
- Maven
- Java

## Comment exécuter le projet

```bash
# Compiler le projet
./mvnw clean compile

# Exécuter l'application
./mvnw spring-boot:run
```

## Structure des packages

```
tn.esprit.studentmanagement/
├── controllers/        # Contrôleurs REST
├── entities/          # Entités JPA
├── repositories/      # Repositories Spring Data
└── services/          # Services métier
```

## Auteur

Projet développé dans le cadre d'un exercice académique.
