FROM ubuntu:22.04

ARG WWWGROUP=1000
ARG WWWUSER=1000
ARG NODE_VERSION=20
ARG POSTGRES_VERSION=15

WORKDIR /var/www

ENV DEBIAN_FRONTEND noninteractive
ENV TZ=UTC
ENV SUPERVISOR_PHP_COMMAND="php -d variables_order=EGPCS /var/www/artisan serve --host=0.0.0.0 --port=80"

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install required system packages and set ZSH shell
RUN apt-get update \
    && mkdir -p /etc/apt/keyrings \
    && apt-get upgrade -y \
    && apt-get install -y gnupg gosu curl ca-certificates zip unzip git \
    supervisor sqlite3 libcap2-bin libpng-dev python2 dnsutils \
    librsvg2-bin fswatch wget tar zsh vim

# Add APT repository for PHP
RUN curl -sS 'https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x14aa40ec0831756756d7f66c4f4ea0aae5267a6c' | gpg --dearmor | tee /etc/apt/keyrings/ppa_ondrej_php.gpg > /dev/null \
    && echo "deb [signed-by=/etc/apt/keyrings/ppa_ondrej_php.gpg] https://ppa.launchpadcontent.net/ondrej/php/ubuntu jammy main" > /etc/apt/sources.list.d/ppa_ondrej_php.list

# Install PHP 8.3 along with required extensions
RUN apt-get update \
    && apt-get install -y php8.3-bcmath php8.3-bz2 php8.3-cli php8.3-common \
    php8.3-curl php8.3-decimal php8.3-dev php8.3-gd php8.3-gmp \
    php8.3-gnupg php8.3-grpc php8.3-igbinary php8.3-imagick php8.3-imap \
    php8.3-intl php8.3-ldap php8.3-mbstring php8.3-memcached \
    php8.3-mongodb php8.3-msgpack php8.3-mysql php8.3-opcache php8.3-pcov \
    php8.3-pgsql php8.3-readline php8.3-redis php8.3-soap php8.3-sqlite3 \
    php8.3-swoole php8.3-uuid php8.3-vips php8.3-xdebug php8.3-xml \
    php8.3-xmlrpc php8.3-xsl php8.3-yaml php8.3-zip

# Install and setup Composer
RUN curl -sLS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer

# Install and setup Node, NPM, Yarn, PNPM and Bun
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_VERSION.x nodistro main" > /etc/apt/sources.list.d/nodesource.list \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | tee /etc/apt/keyrings/yarn.gpg >/dev/null \
    && echo "deb [signed-by=/etc/apt/keyrings/yarn.gpg] https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list \
    && apt-get update \
    && apt-get install -y nodejs yarn \
    && npm install -g npm \
    && npm install -g pnpm \
    && npm install -g bun

# Install MySQL and PostgreSQL client packages
RUN curl -sS https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | tee /etc/apt/keyrings/pgdg.gpg >/dev/null \
    && echo "deb [signed-by=/etc/apt/keyrings/pgdg.gpg] http://apt.postgresql.org/pub/repos/apt jammy-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
    && apt-get update \
    && apt-get install -y mysql-client \
    && apt-get install -y postgresql-client-$POSTGRES_VERSION

# Clean unused cached packages
RUN apt-get -y autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN setcap "cap_net_bind_service=+ep" /usr/bin/php8.3

# Register new group and user for sail
RUN groupadd --force -g $WWWGROUP sail
RUN useradd -ms /usr/bin/zsh --no-user-group -g $WWWGROUP -u 1337 sail

# Install OMZ for sail user and set theme and plugins
RUN gosu sail sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.5/zsh-in-docker.sh)" -- \
    -t robbyrussell \
    -p git \
    -p 'history-substring-search' \
    -a 'alias artisan="php artisan"' \
    -a 'alias pint="./vendor/bin/pint"'

# Mark CWD safe for git
RUN git config --global --add safe.directory /var/www

COPY start-container /usr/local/bin/start-container
COPY post-create-container /usr/local/bin/post-create-container
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY php.ini /etc/php/8.3/cli/conf.d/99-sail.ini
RUN chmod +x /usr/local/bin/start-container
RUN chmod +x /usr/local/bin/post-create-container

EXPOSE 8000

ENTRYPOINT ["start-container"]
