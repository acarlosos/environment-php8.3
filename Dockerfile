FROM php:8.3-fpm

# Define o diretório de trabalho
WORKDIR /var/www

# Instala dependências do sistema
RUN apt-get update && apt-get install -y \
    libzip-dev \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libpq-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl

# Limpa o cache do apt
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Instala o Node.js (versão 16)
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash && \
    apt-get install -y nodejs && \
    node -v

# Instala extensões PHP
RUN docker-php-ext-configure gd --with-jpeg --with-freetype && \
    docker-php-ext-install gd zip exif pcntl bcmath pdo_pgsql pgsql

# Instala e ativa o Redis via PECL
RUN pecl install -o -f redis && \
    rm -rf /tmp/pear && \
    docker-php-ext-enable redis

# Instala o Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Cria usuário para rodar a aplicação Laravel
RUN groupadd -g 1000 www && useradd -u 1000 -ms /bin/bash -g www www

# Copia os arquivos da aplicação
COPY ./www /var/www

# Ajusta permissões
COPY --chown=www:www ./www /var/www

# Troca para o usuário não-root
USER www

# Expõe a porta padrão do PHP-FPM
EXPOSE 9000

# Comando padrão ao iniciar o container
CMD ["php-fpm"]
