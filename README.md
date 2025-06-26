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
<img src="https://github.com/acarlosos/environment-php8.3/blob/main/lumen.png" >

Os serviços aqui definidos incluem:

- lumen-app: Contém o aplicativo Laravel e executa uma imagem personalizada do Docker laravel-app.
Ela também define o working_dir no contêiner para /var/www.
- lumen-webserver: Serviço que extrai a imagem nginx:alpine do Docker e expõe as portas 80 e 443.

Cada propriedade container_name define um nome para o contêiner, que corresponde ao nome do serviço.

Para facilitar a comunicação entre contêineres, os serviços estão conectados a uma rede bridge chamada app-backend. Uma rede bridge utiliza um software bridge que permite que os contêineres conectados à mesma rede bridge se comuniquem uns com os outros.
O driver da bridge instala automaticamente regras na máquina do host para que contêineres em redes bridge diferentes não possam se comunicar diretamente entre eles. Isso cria um nível de segurança mais elevado para os aplicativos, garantindo que apenas serviços relacionados possam se comunicar uns com os outros. Isso também significa que você pode definir várias redes e serviços que se conectam a funções relacionadas: os serviços de aplicativo front-end podem usar uma rede frontend, por exemplo, e os serviços back-end podem usar uma rede backend.

