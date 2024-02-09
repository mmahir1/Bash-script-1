#!/bin/bash

# Automating the deployment of an ecommerce application
# By Musayyib Yusuf

yum_installed() {
    if ! command -v yum &>/dev/null; then
        echo "YUM NOT INSTALLED"
        read -p "Do you want to install yum? (y/n): " install_yum

        if [ "$install_yum" == "y" ]; then
            sudo apt-get update
            sudo apt-get install yum
        else
            exit 1
        fi
    fi
}

# Check if service is running
is_service_running() {
    service_name=$1
    service_status=$(sudo systemctl is-active $service_name)

    if [ "$service_status" == "active" ]; then
        echo "$service_name is active and running"
    else
        echo "$service_name is not active"
        exit 1
    fi
}

is_firewalld_configured() {
    if ! command -v firewall-cmd &>/dev/null; then
        echo "Error: firewall-cmd is not installed"
        exit 1
    fi

    ports=$(sudo firewall-cmd --list-all --zone=public | grep ports)

    if [[ "$ports" == *"$1"* ]]; then
        echo "Firewalld is configured with port $1"
    else
        echo "Firewalld is not configured with port $1"
        exit 1
    fi
}

# Install and configure firewalld
yum_installed

sudo yum install -y firewalld
sudo systemctl start firewalld
sudo systemctl enable firewalld

# Check FirewallD Service is running
is_service_running firewalld

# Install and configure Maria-DB
sudo yum install -y mariadb-server
sudo service mariadb start
sudo systemctl enable mariadb

# Check Maria-Db service is running
is_service_running mariadb

# Configure firewall rules mariadb
sudo firewall-cmd --permanent --zone=public --add-port=3306/tcp
sudo firewall-cmd --reload

is_firewalld_configured 3306

# Configure Database
cat > setup-db.sql <<-EOF
CREATE DATABASE ecomdb;
CREATE USER 'ecomuser'@'localhost' IDENTIFIED BY 'ecompassword';
GRANT ALL PRIVILEGES ON ecomdb.* TO 'ecomuser'@'localhost';
FLUSH PRIVILEGES;
EOF

sudo mysql < setup-db.sql



# Create the db-load-scripts.sql
cat > db-load-script.sql <<-EOF
USE ecomdb;
CREATE TABLE products (
    id mediumint(8) unsigned NOT NULL auto_increment,
    Name varchar(255) default NULL,
    Price varchar(255) default NULL,
    ImageUrl VARCHAR(255) default NULL,
    PRIMARY KEY (id)
) AUTO_INCREMENT=1;

INSERT INTO products (Name, Price, ImageUrl) VALUES
    ("Laptop", "100", "c-1.png"),
    ("Drone", "200", "c-2.png"),
    ("VR", "300", "c-3.png"),
    ("Tablet", "50", "c-5.png"),
    ("Watch", "90", "c-6.png"),
    ("Phone Covers", "20", "c-7.png"),
    ("Phone", "80", "c-8.png"),
    ("Laptop", "150", "c-4.png");
EOF


sudo mysql < db-load-script.sql

# Check to see if ecomdb has been created
is_db_created() {
    if mariadb -e "USE ecomdb;" &>/dev/null; then
        echo "ecomdb Database exists."
    else
        echo "ecomdb Database does not exist"
        exit 1
    fi

    if mariadb -e "USE ecomdb; Describe products" &>/dev/null; then
        echo "Table products exists in ecomdb"
    else
        echo "Table products does not exist in ecomdb"
        exit 1
    fi
}

is_db_created

sudo yum install -y httpd php php-mysqlnd
sudo firewall-cmd --permanent --zone=public --add-port=80/tcp
sudo firewall-cmd --reload

is_firewalld_configured 80

# Update index.php
sudo sed -i 's/index.html/index.php/g' /etc/httpd/conf/httpd.conf

#start httpd service
sudo service httpd start
sudo systemctl enable httpd

#check if service is running
is_service_running httpd

#download code from github
sudo yum install -y git
sudo git clone https://github.com/kodekloudhub/learning-app-ecommerce.git /var/www/html/

sudo sed -i 's/172.20.1.101/localhost/g' /var/www/html/index.php


curl http://localhost
