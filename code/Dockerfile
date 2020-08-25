FROM php:7.3-apache

# System dependencies
RUN set -eux; \
	\
	apt-get update; \
	apt-get install -y --no-install-recommends \
		git \
		librsvg2-bin \
		imagemagick \
		# Required for SyntaxHighlighting
		python3 \
	; \
	rm -rf /var/lib/apt/lists/*

# Install the PHP extensions we need
RUN set -eux; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	\
	apt-get update; \
	apt-get install -y --no-install-recommends \
		libicu-dev \
	; \
	\
	docker-php-ext-install -j "$(nproc)" \
		intl \
		mbstring \
		mysqli \
		opcache \
	; \
	\
	pecl install apcu-5.1.18; \
	docker-php-ext-enable \
		apcu \
	; \
	\
	# reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
	apt-mark auto '.*' > /dev/null; \
	apt-mark manual $savedAptMark; \
	ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
		| awk '/=>/ { print $3 }' \
		| sort -u \
		| xargs -r dpkg-query -S \
		| cut -d: -f1 \
		| sort -u \
		| xargs -rt apt-mark manual; \
	\
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	rm -rf /var/lib/apt/lists/*

# Enable Short URLs
RUN set -eux; \
	a2enmod rewrite; \
	{ \
		echo '<Directory /var/www/html>'; \
		echo '  RewriteEngine On'; \
		echo '  RewriteCond %{REQUEST_FILENAME} !-f'; \
		echo '  RewriteCond %{REQUEST_FILENAME} !-d'; \
		echo '  RewriteRule ^ %{DOCUMENT_ROOT}/index.php [L]'; \
		echo '</Directory>'; \
	} > "$APACHE_CONFDIR/conf-available/short-url.conf"; \
	a2enconf short-url

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=60'; \
		echo 'opcache.fast_shutdown=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

# SQLite Directory Setup
RUN set -eux; \
	mkdir -p /var/www/data; \
	chown -R www-data:www-data /var/www/data


# Version
ENV MEDIAWIKI_MAJOR_VERSION 1.34
ENV MEDIAWIKI_BRANCH REL1_34
ENV MEDIAWIKI_VERSION 1.34.2
ENV MEDIAWIKI_SHA512 ea95b46b746c0c180b5cb3b8a2263a2f94207eadbb1638c2113e97b1503c3f0a4d82a2107ce4cabca4790512b81564bda49defe30ac0fdb9bddf3230d6201f8b

ENV MEDIAWIKI_SERVER wiki.example.com:30220
ENV MEDIAWIKI_SITENAME WikiExample
ENV MEDIAWIKI_DB_HOST database-1.cj1ahnxn7jkv.ap-south-1.rds.amazonaws.com
ENV MEDIAWIKI_DB_PORT 3306
ENV MEDIAWIKI_DB_NAME mediawiki
ENV MEDIAWIKI_DEFAULT_SKIN timeless
ENV MEDIAWIKI_DB_PASSWORD MeD1aWik1
ENV MEDIAWIKI_DB_USER dbadmin

workdir /var/www/html

# MediaWiki setup
volume /var/www/html
COPY . /var/www/html
RUN chown -R www-data:www-data extensions skins cache images
