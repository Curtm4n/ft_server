/etc/init.d/mysql start
/etc/init.d/php7.3-fpm start
mariadb < /var/www/html/phpmyadmin/sql/create_tables.sql
mysql -e "CREATE DATABASE wordpress DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci"
mysql -e "GRANT SELECT, INSERT, UPDATE, DELETE ON phpmyadmin.* TO 'pma'@'localhost' IDENTIFIED BY 'hello'"
mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'curtis'@'localhost' IDENTIFIED BY 'hello' WITH GRANT OPTION"
mysql -e "FLUSH PRIVILEGES"
service nginx start
