#!/bin/bash

# ===============================
# SYSTEM UPDATE
# ===============================
sudo dnf update -y

# ===============================
# INSTALL APACHE
# ===============================
sudo dnf install httpd -y
sudo systemctl start httpd
sudo systemctl enable httpd

# ===============================
# INSTALL PHP
# ===============================
sudo dnf install php php-mysqlnd php-fpm php-json php-cli php-common php-mbstring php-xml php-gd -y

# ===============================
# DOWNLOAD WORDPRESS
# ===============================
cd /var/www/html

sudo curl -O https://wordpress.org/latest.tar.gz
sudo tar -xzf latest.tar.gz
sudo cp -r wordpress/* .

# ===============================
# FIX PERMISSIONS
# ===============================
sudo chown -R apache:apache /var/www/html
sudo chmod -R 755 /var/www/html

# ===============================
# INSTALL EFS UTIL
# ===============================
sudo dnf install -y amazon-efs-utils

# ===============================
# MOUNT EFS (REPLACE FS ID)
# ===============================
sudo mkdir -p /var/www/html/wp-content
sudo mount -t efs fs-xxxx:/ /var/www/html/wp-content

# ===============================
# PERSIST EFS MOUNT
# ===============================
echo "fs-xxxx:/ /var/www/html/wp-content efs defaults,_netdev 0 0" | sudo tee -a /etc/fstab

# ===============================
# SET EFS PERMISSIONS
# ===============================
sudo chown -R apache:apache /var/www/html/wp-content
sudo chmod -R 775 /var/www/html/wp-content

# ===============================
# CONFIGURE WORDPRESS
# ===============================
cd /var/www/html

sudo cp wp-config-sample.php wp-config.php

# NOTE: Manually update DB_NAME, DB_USER, DB_PASSWORD, DB_HOST

# ===============================
# RESTART APACHE
# ===============================
sudo systemctl restart httpd

echo "Setup complete. Configure wp-config.php manually."