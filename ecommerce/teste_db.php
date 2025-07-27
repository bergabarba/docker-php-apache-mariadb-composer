<?php
         // test_db.php
    
         // Desativa o cache para garantir que estamos vendo o resultado mais recente.
         header("Cache-Control: no-store, no-cache, must-revalidate, max-age=0");
         header("Cache-Control: post-check=0, pre-check=0", false);
         header("Pragma: no-cache");
    
         echo "<pre>";
        echo "Tentando conectar ao banco de dados...\n";
   
        $host = 'db'; // O nome do serviço no docker-compose
        $db   = 'db_ecommerce'; // O banco de dados que você definiu
        $user = 'root';
        $pass = 'Senhasuperforte2025@'; // <-- COLOQUE A SENHA DO SEU docker-compose.yml AQUI!
        $charset = 'utf8mb4';
   
        $dsn = "mysql:host=$host;dbname=$db;charset=$charset";
        $options = [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES   => false,
        ];
   
        try {
             $pdo = new PDO($dsn, $user, $pass, $options);
             echo "SUCESSO! Conexão com o banco de dados '" . $db . "' estabelecida.\n";
        } catch (\PDOException $e) {
             echo "FALHA NA CONEXÃO: " . $e->getMessage() . "\n";
             // Mostra o rastreamento do erro para mais detalhes.
             echo "\nStack trace:\n" . $e->getTraceAsString();
        }
   
        echo "</pre>";