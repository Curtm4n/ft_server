FROM debian:buster

RUN apt-get update && apt-get install -y \
	nginx \
	mariadb-server \
	php-fpm \
	php-mysql \
	php-mbstring \
	php-zip \
	php-gd \
	php-curl \
	php-intl \
	php-soap \
	php-xml \
	php-xmlrpc \
	curl \
	wget

#Add my own index.html and a php page
COPY srcs/nginx/index.html /var/www/html/index.html
COPY srcs/nginx/info.php /var/www/html/info.php

#Add the domain to the available sites folder
COPY srcs/nginx/default /etc/nginx/sites-available/default

#Add script which find the link of the latest phpMyAdmin version
COPY srcs/script/php_my_admin_link /php_my_admin_link

#Run script, download phpmyadmin and then set it up
RUN sh php_my_admin_link
RUN	wget -i link
RUN	tar xvf phpMyAdmin*
RUN	rm php_my_admin_link link phpMyAdmin*.tar.gz
RUN	mv phpMyAdmin* /var/www/html/phpmyadmin
RUN	mkdir /var/www/html/phpmyadmin/tmp
RUN chown -R www-data:www-data /var/www/html/phpmyadmin

#Add the new configuration file for phpmyadmin
COPY srcs/phpmyadmin/config.inc.php /var/www/html/phpmyadmin/config.inc.php

#Create a symbolic link for the domain inside sites-enabled
RUN rm /etc/nginx/sites-enabled/default
RUN ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/

#Expose the ports 80(HTTP) and 443(HTTPS/work with ssl/tls)
EXPOSE 80 443

#VOLUME //put database's files

#Add my launch script inside the container
COPY srcs/script/launch_commands.sh /tmp/launch_commands.sh

#Add my openssl infos and create the self-signed certificate
COPY srcs/openssl.txt /tmp/openssl.txt
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt < /tmp/openssl.txt

#Add config files for ssl key and certificate
COPY srcs/nginx/self-signed.conf /etc/nginx/snippets/self-signed.conf
COPY srcs/nginx/ssl-params.conf /etc/nginx/snippets/ssl-params.conf

#Use /tmp as the current working directory
WORKDIR /tmp

#Download wordpress and set it up
RUN curl -LO https://wordpress.org/latest.tar.gz
RUN tar xzvf latest.tar.gz
RUN mkdir /var/www/html/wordpress
RUN cp -a wordpress/. /var/www/html/wordpress
RUN chown -R www-data:www-data /var/www/html/wordpress
COPY srcs/wordpress/wp-config.php /var/www/html/wordpress/wp-config.php

#Come back to the root of the filesystem
WORKDIR /

#My main command run the script and open an interactive shell
CMD sh /tmp/launch_commands.sh && bash
