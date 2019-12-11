#---------------------------------------------------------------------
# Function: InstallSQLServer
#    Install and configure SQL Server
#---------------------------------------------------------------------
InstallSQLServer() {
    echo -n "Installing Database server (MariaDB)... "
    echo "maria-db-10.1 mysql-server/root_password password $CFG_MYSQL_ROOT_PWD" | debconf-set-selections
    echo "maria-db-10.1 mysql-server/root_password_again password $CFG_MYSQL_ROOT_PWD" | debconf-set-selections
    apt_install mariadb-client mariadb-server
    mysql_secure_installation
	echo -e "[${green}DONE${NC}]\n"
	echo -n "Restarting MariaDB... "
	systemctl restart mysql
    echo -e "[${green}DONE${NC}]\n"
}
