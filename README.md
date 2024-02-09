Automated Deployment of an E-commerce Application
This script automates the deployment of an e-commerce application on a Linux system. It includes the installation and configuration of necessary components such as firewalld, MariaDB, Apache HTTP server, PHP, and git. The script also sets up the database, configures firewall rules, and downloads the application code from a GitHub repository.

Prerequisites
This script is intended for use on Linux systems with the yum package manager.
Ensure that you have sudo privileges to execute commands with administrative permissions.
Usage
Clone this repository to your local machine:

bash
Copy code
git clone <repository_url>
Navigate to the directory containing the script:

bash
Copy code
cd <repository_directory>
Make the script executable:

bash
Copy code
chmod +x deploy_ecommerce.sh
Execute the script:

bash
Copy code
./deploy_ecommerce.sh
Follow the on-screen prompts to install any required dependencies and configure the deployment.

Script Overview
yum_installed: Checks if yum package manager is installed. If not, prompts the user to install it.
is_service_running: Checks if a given service is running.
is_firewalld_configured: Checks if firewalld is installed and configured with specified port(s).
Install and configure firewalld: Installs and starts firewalld service.
Install and configure MariaDB: Installs MariaDB server and starts the service.
Configure database: Sets up the database and creates necessary tables.
Check if ecomdb has been created: Verifies if the database and required tables have been created successfully.
Install Apache HTTP server and PHP: Installs Apache HTTP server and PHP along with the necessary PHP extension for MySQL.
Update index.php: Updates the configuration file to use index.php as the default index file.
Start HTTPD service: Starts the Apache HTTP server and enables it to start on boot.
Download code from GitHub: Clones the e-commerce application code from the specified GitHub repository.
Modify configuration: Updates the application configuration to use localhost.
Verify deployment: Checks if the deployment was successful by accessing the application homepage via curl.
Note
Ensure that you have an active internet connection during the execution of the script, as it requires downloading packages and code from external sources.
Review the script and modify any configurations as per your requirements before executing it in a production environment.
