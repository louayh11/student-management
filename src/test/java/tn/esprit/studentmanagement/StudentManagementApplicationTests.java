package tn.esprit.studentmanagement;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.TestPropertySource;

@SpringBootTest
@TestPropertySource(locations = "classpath:application.properties")
class StudentManagementApplicationTests {

    @Test
    void contextLoads() {
        // Ce test vérifie que le contexte Spring se charge correctement
        // avec la configuration H2 en mémoire pour les tests
    }

    @Test
    void applicationStarts() {
        // Test simple pour vérifier que l'application démarre
        assert true;
    }

}
