-- Script d'initialisation pour la base de données Student Management
-- Ce script sera exécuté automatiquement lors de la création du container MySQL

USE studentdb;

-- Insertion de données de test pour les départements
INSERT INTO department (name, description) VALUES 
('Informatique', 'Département des Sciences Informatiques'),
('Mathématiques', 'Département de Mathématiques'),
('Physique', 'Département de Physique')
ON DUPLICATE KEY UPDATE description = VALUES(description);

-- Insertion de données de test pour les cours
INSERT INTO course (name, credits, department_id) VALUES 
('Programmation Java', 3, 1),
('Structures de Données', 4, 1),
('Algèbre Linéaire', 3, 2),
('Analyse', 4, 2),
('Mécanique Quantique', 5, 3)
ON DUPLICATE KEY UPDATE credits = VALUES(credits);

-- Insertion de données de test pour les étudiants
INSERT INTO student (first_name, last_name, email, birth_date, department_id) VALUES 
('Ahmed', 'Ben Ali', 'ahmed.benali@esprit.tn', '2000-05-15', 1),
('Fatma', 'Trabelsi', 'fatma.trabelsi@esprit.tn', '1999-12-20', 1),
('Mohamed', 'Gharbi', 'mohamed.gharbi@esprit.tn', '2001-03-10', 2),
('Amira', 'Sassi', 'amira.sassi@esprit.tn', '2000-08-25', 2),
('Youssef', 'Mejri', 'youssef.mejri@esprit.tn', '1999-11-30', 3)
ON DUPLICATE KEY UPDATE email = VALUES(email);

-- Vérification des données insérées
SELECT 'Départements créés:' as Info;
SELECT * FROM department;

SELECT 'Cours créés:' as Info;
SELECT * FROM course;

SELECT 'Étudiants créés:' as Info;
SELECT * FROM student;