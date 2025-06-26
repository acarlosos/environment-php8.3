# Como configurar Laravel, Nginx e Redis com Docker Compose
## Passo 1 — Fazendo download do ambiente de desenvolvimento

Primeiramente faça uma cópia da versão mais recente do Projeto para um diretório chamado environment:

  $ git clone git@github.com:acarlosos/environment-php8.3.git environment

Vá até o diretório environment:

  $ cd environment

Vamos fazer uma cópia do arquivo .env-example para .env:

  $ cp .env-example .env

Inserir as configurações do projeto:

  $ nano .env
  ```
  COMPOSE_PROJECT_NAME=lumen
  COMPOSE_PROJECT_NAME=lumen
  WEBSERVER_PORT=8091
  WEBSERVER_PORT_SECURE=4491
  REDIS_PORT=8901
  ```


Com todos os seus serviços definidos no seu arquivo docker-compose, você precisa emitir um único comando para iniciar todos os contêineres, criar os volumes e configurar e conectar as redes:

    $ docker-compose up -d

Assim que o processo for concluído, utilize o comando a seguir para listar todos os contêineres em execução:
    $ docker ps

Você verá o seguinte resultado com detalhes sobre seus contêineres do lumen-app, lumen-webserver e lumen-redis:

Você pode conseferir se o containner subiu corretamento com o commando docker ps:
    ```$ docker ps```
    ```Output```
    ```
    $ docker ps
    CONTAINER ID   IMAGE              COMMAND                  CREATED          STATUS          PORTS                                         NAMES
    ba4eef28c8c4   redis:alpine       "docker-entrypoint.s…"   26 seconds ago   Up 26 seconds   0.0.0.0:8901->6379/tcp                        lumen-redis
    e8e25be0477d   laravel-app        "docker-php-entrypoi…"   26 seconds ago   Up 26 seconds   9000/tcp                                      lumen-app
    06d93f86c67d   nginx:alpine       "/docker-entrypoint.…"   26 seconds ago   Up 26 seconds   0.0.0.0:8091->80/tcp, 0.0.0.0:4491->443/tcp   lumen-webserver
    ```

## Passo 2 — Clonando o projeto

Em seguida vamos baixar o projeto Lumen dentro da pasta www

    $ git clone git@github.com:plataforma-lumen-arsenal/Lumen.git .

Você pode agora criar o arquivo .env na pasta www.

    $ cd www
    $ cp .env.example .env

Encontre o bloco que especifica o DB_CONNECTION e DATABASE_URL atualize-o para refletir as especificidades da sua configuração. Você modificará os seguintes campos:

O DB_CONNECTION a conexão a ser utilizada.
O DATABASE_URL será a string de conexão do seu banco de dados.

```
DB_CONNECTION=pgsql
DATABASE_URL=postgresql://postgres.heozkgkwpwwhpqftlzwq:738773Dag*@aws-0-sa-east-1.pooler.supabase.com:5432/postgres
```
Salve suas alterações e saia do seu editor.

Usaremos agora o docker-compose exec para instalar os pacotes via composer e definir a chave do aplicativo para o aplicativo Laravel.
Este comando gerará uma chave e a copiará para seu arquivo .env, garantindo que as sessões do seu usuário e os dados criptografados permaneçam seguros:

    $ docker-compose exec -it lumen-app bash
    $ composer install
    $ php artisan key:generate

Para colocar essas configurações em um arquivo de cache, que irá aumentar a velocidade de carregamento do seu aplicativo, execute:

    $ php artisan config:cache

Suas definições da configuração serão carregadas em /var/www/bootstrap/cache/config.php no contêiner.

Como passo final, visite http://localhost:8091 no navegador.
Você verá a seguinte página inicial para seu aplicativo Laravel:
<img src="https://i.ibb.co/rxPRtp4/Home.png" >

## Passo 3 - Criando um usuário para o MySQL

Para criar um novo usuário, execute uma bash shell interativa no contêiner db com o docker-compose exec:

    $ docker-compose exec db bash

Dentro do contêiner, logue na conta administrativa root do MySQL:

    root@6efb373db53c:/# mysql -u root -p

Você será solicitado a inserir a senha para a conta root do MySQL ( secret ).

    mysql> show databases;

Você verá o banco de dados laravel listado no resultado:

```
Output
+--------------------+
| Database           |
+--------------------+
| information_schema |
| project        |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
5 rows in set (0.08 sec)
```

Em seguida, crie a conta de usuário que terá permissão para acessar esse banco de dados.

    mysql> GRANT ALL ON laravel_app.* TO 'new_user'@'%' IDENTIFIED BY 'secret';

Reinicie os privilégios para notificar o servidor MySQL das alterações:

    mysql> FLUSH PRIVILEGES;

Saia do MySQL:

    mysql>exit;

Por fim, saia do contêiner:

    root@6efb373db53c:/# exit

## Passo 4 - Migrando dados e teste com o console Tinker

Primeiramente, teste a conexão com o MySQL executando o comando Laravel artisan migrate, que cria uma tabela migrations no banco de dados de dentro do contêiner:

    $ docker-compose exec app php artisan migrate

Este comando irá migrar as tabelas padrão do Laravel. O resultado que confirma a migração será como este:

```
Output

  INFO  Preparing database.

  Creating migration table ....................................................................................................... 326ms DONE

  INFO  Running migrations.

  2014_10_12_000000_create_users_table ........................................................................................... 164ms DONE
  2014_10_12_100000_create_password_resets_table ................................................................................. 325ms DONE
  2019_08_19_000000_create_failed_jobs_table ...................................................................................... 64ms DONE
  2019_12_14_000001_create_personal_access_tokens_table .......................................................................... 254ms DONE
```

Assim que a migração for concluída, você pode fazer uma consulta para verificar se está devidamente conectado ao banco de dados usando o comando tinker:

    $ docker-compose exec app php artisan tinker

Teste a conexão do MySQL obtendo os dados que acabou de migrar:

    >>> \DB::table('migrations')->get();

Você verá um resultado que se parece com este:

```
Output
= Illuminate\Support\Collection {#6154
    all: [
      {#6163
        +"id": 1,
        +"migration": "2014_10_12_000000_create_users_table",
        +"batch": 1,
      },
      {#6165
        +"id": 2,
        +"migration": "2014_10_12_100000_create_password_resets_table",
        +"batch": 1,
      },
      {#6166
        +"id": 3,
        +"migration": "2019_08_19_000000_create_failed_jobs_table",
        +"batch": 1,
      },
      {#6167
        +"id": 4,
        +"migration": "2019_12_14_000001_create_personal_access_tokens_table",
        +"batch": 1,
      },
    ],
  }
>>>
```
Para sair digite o comando abaixo:
    $ exit
## O arquivo do Docker Compose

No arquivo docker-compose, você tem três serviços: app, webserver e db.  Certifique-se de substituir a senha root para o MYSQL_ROOT_PASSWORD, definida como uma variável de ambiente sob o serviço db, por uma senha forte da sua escolha:

```
~/laravel-app/docker-compose.yml

version: '3'
services:

  #PHP Service
  app:
    build:
      context: .
      dockerfile: Dockerfile
    image: digitalocean.com/php
    container_name: app
    restart: unless-stopped
    tty: true
    environment:
      SERVICE_NAME: app
      SERVICE_TAGS: dev
    working_dir: /var/www
    volumes:
      - ./www:/var/www
      - ./php/local.ini:/usr/local/etc/php/conf.d/local.ini
    networks:
      - app-backend

  #Nginx Service
  webserver:
    image: nginx:alpine
    container_name: webserver
    restart: unless-stopped
    tty: true
    ports:
      - "8081:80"
      - "4431:443"
    volumes:
      - ./www:/var/www
      - ./nginx/conf.d/:/etc/nginx/conf.d/
    networks:
      - app-backend

  #MySQL Service
  db:
    image: mysql:8
    container_name: db
    restart: unless-stopped
    tty: true
    ports:
      - "3306:3306"
    environment:
      MYSQL_DATABASE: ${DB_DATABASE}
      MYSQL_ROOT_PASSWORD: ${DB_PASSWORD}
      MYSQL_PASSWORD: ${DB_PASSWORD}
      MYSQL_USER: ${DB_USERNAME}
      SERVICE_TAGS: dev
      SERVICE_NAME: mysql
    volumes:
      - dbdata:/var/lib/mysql
      - ./mysql/my.cnf:/etc/mysql/my.cnf
    networks:
      - app-backend

#Docker Networks
networks:
  app-backend:
    driver: bridge

#Volumes
volumes:
  dbdata:
    driver: local

```
Os serviços aqui definidos incluem:

- app: Contém o aplicativo Laravel e executa uma imagem personalizada do Docker laravel-app, que você definirá no Passo 4. Ela também define o working_dir no contêiner para /var/www.
- webserver: Serviço extrai a imagem nginx:alpine do Docker e expõe as portas 80 e 443.
- db: Serviço extrai a imagem mysql:8 do Docker e define algumas variáveis de ambiente, incluindo um banco de dados chamado laravel_app para o seu aplicativo e a senha da** root** do banco de dados. Você pode dar o nome que quiser ao banco de dados e deve substituir o your_mysql_root_password pela senha forte escolhida. Esta definição de serviço também mapeia a porta 3306 no host para a porta 3306 no contêiner.

Cada propriedade container_name define um nome para o contêiner, que corresponde ao nome do serviço.

Para facilitar a comunicação entre contêineres, os serviços estão conectados a uma rede bridge chamada app-backend. Uma rede bridge utiliza um software bridge que permite que os contêineres conectados à mesma rede bridge se comuniquem uns com os outros. O driver da bridge instala automaticamente regras na máquina do host para que contêineres em redes bridge diferentes não possam se comunicar diretamente entre eles. Isso cria um nível de segurança mais elevado para os aplicativos, garantindo que apenas serviços relacionados possam se comunicar uns com os outros. Isso também significa que você pode definir várias redes e serviços que se conectam a funções relacionadas: os serviços de aplicativo front-end podem usar uma rede frontend, por exemplo, e os serviços back-end podem usar uma rede backend.

## Persistindo os dados

O Docker tem recursos poderosos e convenientes para persistir os dados. No nosso aplicativo, vamos usar volumes e bind mounts para persistir o banco de dados, o aplicativo e os arquivos de configuração. Os volumes oferecem flexibilidade para backups e persistência além do ciclo de vida de um contêiner, enquanto os bind mounts facilitam alterações no código durante o desenvolvimento, fazendo alterações nos arquivos do host ou diretórios imediatamente disponíveis nos seus contêineres. Nossa configuração usa ambos.

```
~/laravel-app/docker-compose.yml
...
#MySQL Service
db:
  ...
    volumes:
      - dbdata:/var/lib/mysql
    networks:
      - app-backend
  ...

```
