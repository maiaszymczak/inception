# Création de wp-config.php si absent
if [ ! -f /var/www/html/wp-config.php ]; then
  cd /var/www/html 
  wp core download --allow-root --path="/var/www/html" 
  wp config create --allow-root \
          --dbname=$WORDPRESS_DB_NAME \
          --dbuser=$WORDPRESS_DB_USER  \
          --dbpass=$WORDPRESS_DB_PASSWD \
          --url=$DOMAIN_NAME  \
          --dbhost="mariadb" \
          --skip-check   \
          --path="/var/www/html" 
  wp core install --allow-root \
          --url=$DOMAIN_NAME  \
          --title=$DOMAIN_NAME  \
          --admin_user=$ADMIN_USER  \
          --admin_password=$ADMIN_PASSWD  \
          --admin_email=$ADMIN_MAIL  \
          --path="/var/www/html"
  wp user create --allow-root $WP_USER $WP_USER_MAIL --user_pass=$WP_USER_PASSWD --path="/var/www/html"
  wp theme install zigcy-lite  --allow-root --path="/var/www/html"
  wp theme activate zigcy-lite  --allow-root --path="/var/www/html"
  wp config set WP_HOME "https://$DOMAIN_NAME" --allow-root
  wp config set WP_SITEURL "https://$DOMAIN_NAME" --allow-root
  wp search-replace "http://$DOMAIN_NAME" "https://$DOMAIN_NAME" --all-tables --allow-root
  wp cache flush --allow-root

fi
chown -R www-data:www-data /var/www/html
mkdir -p /run/php
exec php-fpm7.4 -F
