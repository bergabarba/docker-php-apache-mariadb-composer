# Ambiente de Desenvolvimento Docker com aplicacao de exemplo para E-commerce com PHP e Slim
# O projeto de estudos para ilustrar a configuracao do ambiente de desenvolvimento git abaixo
#  github do projeto (https://github.com/hcodebr/ecommerce)

Este guia documenta a configuração de um ambiente de desenvolvimento local conteinerizado para uma aplicação de e-commerce feita em PHP, utilizando o micro-framework Slim, um servidor web Apache e um banco de dados MariaDB.

---

## Índice

1.  [Estrutura do Projeto](#1-estrutura-do-projeto)
2.  [Pré-requisitos](#2-pr%C3%A9-requisitos)
3.  [Como Iniciar o Ambiente](#3-como-iniciar-o-ambiente)
4.  [Acesso aos Serviços](#4-acesso-aos-servi%C3%A7os)
5.  [Detalhes da Configuração](#5-detalhes-da-configura%C3%A7%C3%A3o)
    *   [O Orquestrador: `docker-compose.yml`](#o-orquestrador-docker-composeyml)
    *   [A Imagem Customizada: `Dockerfile`](#a-imagem-customizada-dockerfile)
    *   [Configuração do Apache: `vhost.conf`](#configura%C3%A7%C3%A3o-do-apache-vhostconf)
6.  [Fluxo de Trabalho de Desenvolvimento](#6-fluxo-de-trabalho-de-desenvolvimento)

---

### 1. Estrutura do Projeto

A organização dos arquivos foi pensada para separar a configuração do ambiente do código da aplicação.

```
docker-ecommerce/
├── docker-compose.yml   # Orquestra todos os contêineres
├── Dockerfile           # Receita para construir a imagem do Apache+PHP
│
├── ecommerce/           # Pasta raiz do seu código-fonte PHP
│   └── ... (seu projeto Slim, com composer.json, etc.)
│
└── docker/
    ├── apache/
    │   └── vhost.conf   # Configuração do Virtual Host do Apache
    └── mariadb/
        └── init/
            └── 01-grant.sql # Script para permissões do banco
```

### 2. Pré-requisitos

*   **Docker Desktop** instalado e em execução.

### 3. Como Iniciar o Ambiente

1.  Abra um terminal na pasta raiz `docker-ecommerce`.
2.  Execute o comando para construir as imagens e iniciar os contêineres em background:

    ```bash
    docker-compose up -d --build
    ```

Para parar o ambiente, execute:
```bash
docker-compose down
```

### 4. Acesso aos Serviços

*   **Aplicação Web:** [http://localhost:8080](http://localhost:8080)
*   **Banco de Dados (via cliente SQL como DBeaver/HeidiSQL):**
    *   **Host:** `127.0.0.1` ou `localhost`
    *   **Porta:** `3306`
    *   **Usuário:** `root`
    *   **Senha:** `Senhasuperforte2025@`

### 5. Detalhes da Configuração

#### O Orquestrador: `docker-compose.yml`

Este arquivo define e conecta nossos serviços (`web` e `db`).

*   **`services.web`**: O contêiner da aplicação.
    *   `build`: Constrói uma imagem a partir do `Dockerfile` local.
    *   `volumes: - ./ecommerce:/var/www/html`: **Ponto-chave para o desenvolvimento.** Sincroniza a pasta local `ecommerce` com a pasta `/var/www/html` dentro do contêiner. Alterações no código são refletidas instantaneamente.
    *   `ports: - "8080:80"`: Expõe a porta 80 do contêiner na porta 8080 do seu computador.
*   **`services.db`**: O contêiner do banco de dados.
    *   `image: mariadb:10.4`: Usa a imagem oficial do MariaDB.
    *   `environment`: Define as credenciais do banco de dados que serão usadas na primeira inicialização.
    *   `volumes: - db_data:/var/lib/mysql`: Garante que os dados do banco persistam mesmo que o contêiner seja destruído.
    *   `volumes: - ./docker/mariadb/init:/docker-entrypoint-initdb.d`: Mapeia um script SQL para dentro do contêiner, que será executado na primeira inicialização para conceder permissões de acesso remoto ao usuário `root`.
*   **`networks: - app-network`**: Cria uma rede privada onde os contêineres se comunicam. **É por isso que no código PHP, o host do banco deve ser `db`**.

#### A Imagem Customizada: `Dockerfile`

Este arquivo cria a imagem do servidor web com as configurações exatas para o projeto.

*   `FROM php:7.4.33-apache`: Usa a imagem oficial do PHP com Apache como base.
*   `RUN a2enmod rewrite`: Habilita o módulo de reescrita de URL do Apache, essencial para as rotas do Slim funcionarem.
*   `RUN docker-php-ext-install pdo pdo_mysql`: Instala as extensões PHP para comunicação com o banco de dados.
*   `COPY docker/apache/vhost.conf ...`: Substitui a configuração padrão do Apache pela nossa, que contém as regras para o Slim.
*   `WORKDIR /var/www/html`: Define o diretório de trabalho padrão do contêiner.

#### Configuração do Apache: `vhost.conf`

Este arquivo ajusta o Apache para trabalhar com o padrão "Front Controller" do Slim, garantindo performance e funcionalidade.

*   **`RewriteEngine On` e `RewriteRule`**: Esta é a regra principal. Ela intercepta todas as requisições que não são para arquivos ou pastas existentes (como imagens ou CSS) e as redireciona para o `index.php`. A partir daí, o Slim assume o controle do roteamento.
*   **`AllowOverride None`**: Esta diretiva melhora a performance ao instruir o Apache a não procurar por arquivos `.htaccess`, já que todas as regras necessárias estão centralizadas neste arquivo.

### 6. Fluxo de Trabalho de Desenvolvimento

*   **Para alterações no código PHP/HTML/CSS (dentro da pasta `ecommerce`):**
    *   Apenas salve o arquivo. As mudanças são refletidas instantaneamente graças ao mapeamento de volume. Atualize a página no navegador para ver o resultado.

*   **Para alterações na estrutura do ambiente:**
    *   Você **precisa** reconstruir a imagem com `docker-compose up -d --build` se alterar um dos seguintes arquivos:
        *   `Dockerfile`
        *   `docker-compose.yml`
        *   `docker/apache/vhost.conf`
        *   `composer.json` (para instalar novas dependências)

---

### 7. Comandos Úteis (Cheatsheet)

Todos os comandos devem ser executados a partir da pasta raiz `docker-ecommerce`.

*   **Acessar o terminal do contêiner web (Apache/PHP):**
    ```bash
    docker-compose exec web bash
    ```

*   **Executar comandos do Composer (ex: `update`):**
    ```bash
    docker-compose exec web composer update
    ```

*   **Acessar o terminal do contêiner do banco de dados:**
    ```bash
    docker-compose exec db bash
    ```

*   **Importar um backup do banco de dados:**
    Supondo que seu arquivo de backup esteja em `ecommerce/sql/backup-final.sql`.
    ```bash
    docker-compose exec -T db mysql -u root -p'Senhasuperforte2025@' db_ecommerce < ecommerce/sql/backup-final.sql
    ```
    *   **`-T`**: Desabilita a alocação de um pseudo-TTY, o que é recomendado para redirecionamento de arquivos.
    *   **`-p'Senhasuperforte2025@'`**: Note que não há espaço entre o `-p` e a senha.

*   **Ver os logs dos contêineres em tempo real:**
    ```bash
    # Ver logs de todos os serviços
    docker-compose logs -f

    # Ver logs apenas do serviço web
    docker-compose logs -f web
    ```
