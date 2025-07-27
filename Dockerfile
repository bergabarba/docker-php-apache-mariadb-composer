FROM php:7.4-apache

# 1. HABILITAR MÓDULOS DO APACHE
# A maioria dos módulos que você listou já vem habilitado por padrão.
# Vamos garantir que os mais importantes (e os que não são padrão) estejam ativos.
RUN a2enmod rewrite  

# 2. INSTALAR DEPENDÊNCIAS DO SISTEMA E EXTENSÕES PHP
# Instala libs necessárias para extensões comuns e o cliente do MySQL
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    unzip \
    default-mysql-client \
    && rm -rf /var/lib/apt/lists/*

# Instala as extensões PHP mais comuns para aplicações web
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd pdo pdo_mysql mysqli zip

# 3. INSTALAR COMPOSER
# Instala o Composer globalmente na imagem.
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 3. CONFIGURAÇÕES PERSONALIZADAS
# Copia o arquivo de configuração do Virtual Host para o Apache
COPY docker/apache/vhost.conf /etc/apache2/sites-available/000-default.conf

# Copia um arquivo php.ini customizado (opcional, mas recomendado)
COPY docker/php/php.ini /usr/local/etc/php/php.ini

# Define o diretório de trabalho
WORKDIR /var/www/html

# 5. COPIAR O CÓDIGO-FONTE DA APLICAÇÃO
# Finalmente, copia o resto do código-fonte.
COPY ecommerce/ .

# Expõe a porta 80 (padrão do Apache)
EXPOSE 80