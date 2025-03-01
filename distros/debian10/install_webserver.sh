#---------------------------------------------------------------------
# Function: InstallWebServer Debian 9
#    Install and configure Apache2, php + modules
#---------------------------------------------------------------------
InstallWebServer() {

  if [ "$CFG_WEBSERVER" == "apache" ]; then
    CFG_NGINX=n
    CFG_APACHE=y
    echo -n "Installing Web server (Apache) and modules... "
    echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections
    # - DISABLED DUE TO A BUG IN DBCONFIG - echo "phpmyadmin phpmyadmin/dbconfig-install boolean false" | debconf-set-selections
    echo "dbconfig-common dbconfig-common/dbconfig-install boolean false" | debconf-set-selections
    apt_install apache2 apache2-doc apache2-utils libapache2-mod-php libapache2-mod-fcgid apache2-suexec-pristine libruby libapache2-mod-python php-memcache php-imagick php-gettext libapache2-mod-passenger
    echo -e "[${green}DONE${NC}]\n"
    echo -n "Installing PHP and modules... "
    # Need to check if soemthing is asked before suppress messages
    # apt_install php7.3 php7.3-common php7.3-gd php7.3-mysql php7.3-imap php7.3-cli php7.3-cgi php-pear  php7.3-curl php7.3-intl php7.3-pspell php7.3-recode php7.3-sqlite3 php7.3-tidy php7.3-xmlrpc php7.3-zip php7.3-mbstring php7.3-imap mcrypt php7.3-snmp php7.3-xmlrpc php7.3-xsl
    apt_install php php-common php-gd php-mysql php-imap php-cli php-cgi php-pear php-curl php-intl php-pspell php-recode php-sqlite3 php-tidy php-xmlrpc php-zip php-mbstring php-soap
    echo -e "[${green}DONE${NC}]\n"
    echo -n "Installing PHP-FPM... "
    #Need to check if soemthing is asked before suppress messages
    apt_install php-fpm
    #Need to check if soemthing is asked before suppress messages
    a2enmod actions >/dev/null 2>&1
    a2enmod proxy_fcgi >/dev/null 2>&1
    a2enmod alias >/dev/null 2>&1
    echo -e "[${green}DONE${NC}]\n"
    echo -n "Installing needed programs for PHP and Apache (mcrypt, etc.)... "
    apt_install mcrypt imagemagick memcached curl tidy snmp
    echo -e "[${green}DONE${NC}]\n"

    if [ "$CFG_PHPMYADMIN" == "yes" ]; then
      source $APWD/distros/debian10/install_phpmyadmin.sh
      echo -n "Installing phpMyAdmin... "
      InstallphpMyAdmin
      echo -e "[${green}DONE${NC}]\n"
    fi

    if [ "$CFG_PHP56" == "yes" ]; then
      echo "Installing PHP 5.6"
      apt_install apt-transport-https
      curl https://packages.sury.org/php/apt.gpg | apt-key add - >/dev/null 2>&1
      echo 'deb https://packages.sury.org/php/ stretch main' >/etc/apt/sources.list.d/deb.sury.org.list
      hide_output apt-get update
      apt_install php5.6 php5.6-common php5.6-gd php5.6-mysql php5.6-imap php5.6-cli php5.6-cgi php5.6-mcrypt php5.6-curl php5.6-intl php5.6-pspell php5.6-recode php5.6-sqlite3 php5.6-tidy php5.6-xmlrpc php5.6-xsl php5.6-zip php5.6-mbstring php5.6-fpm
      echo -e "Package: *\nPin: origin packages.sury.org\nPin-Priority: 100" >/etc/apt/preferences.d/deb-sury-org
      echo -e "[${green}DONE${NC}]\n"
    fi

    echo -n "Activating Apache modules... "
    a2enmod suexec >/dev/null 2>&1
    a2enmod rewrite >/dev/null 2>&1
    a2enmod ssl >/dev/null 2>&1
    a2enmod actions >/dev/null 2>&1
    a2enmod include >/dev/null 2>&1
    a2enmod dav_fs >/dev/null 2>&1
    a2enmod dav >/dev/null 2>&1
    a2enmod auth_digest >/dev/null 2>&1
    # a2enmod fastcgi > /dev/null 2>&1
    # a2enmod alias > /dev/null 2>&1
    # a2enmod fcgid > /dev/null 2>&1
    a2enmod cgi >/dev/null 2>&1
    a2enmod headers >/dev/null 2>&1
    echo -e "[${green}DONE${NC}]\n"

    echo -n "Disabling HTTP_PROXY... "
    echo "<IfModule mod_headers.c>" >>/etc/apache2/conf-available/httpoxy.conf
    echo "     RequestHeader unset Proxy early" >>/etc/apache2/conf-available/httpoxy.conf
    echo "</IfModule>" >>/etc/apache2/conf-available/httpoxy.conf
    a2enconf httpoxy >/dev/null 2>&1
    echo -e "[${green}DONE${NC}]\n"
    echo -n "Restarting Apache... "
    systemctl restart apache2
    echo -e "[${green}DONE${NC}]\n"

    echo -n "Installing Let's Encrypt (Certbot)... "
    apt_install certbot
    echo -e "[${green}DONE${NC}]\n"

    echo -n "Installing PHP Opcode Cache... "
    apt_install  php7.3-opcache php7.3-apcu
    echo -e "[${green}DONE${NC}]\n"
    echo -n "Restarting Apache... "
    systemctl restart apache2
    echo -e "[${green}DONE${NC}]\n"
  elif [ "$CFG_WEBSERVER" == "nginx" ]; then
    CFG_NGINX=y
    CFG_APACHE=n
    echo -n "Installing Web server (nginx) and modules... "
    apt_install nginx
    systemctl start nginx
    # apt_install php7.3 php7.3-common php-bcmath php7.3-gd php7.3-mysql php7.3-imap php7.3-cli php7.3-cgi php-pear mcrypt php7.3-curl php7.3-intl php7.3-pspell php7.3-recode php7.3-sqlite3 php7.3-tidy php7.3-xmlrpc php7.3-xsl php7.3-zip php7.3-mbstring php7.3-imap mcrypt php7.3-snmp php7.3-xmlrpc php7.3-xsl
    apt_install php php-common php-bcmath php-gd php-mysql php-imap php-cli php-cgi php-pear mcrypt libruby php-curl php-intl php-pspell php-recode php-sqlite3 php-tidy php-xmlrpc php-xsl php-memcache php-imagick php-gettext php-zip php-mbstring php-soap php-opcache
    echo -e "[${green}DONE${NC}]\n"
    echo -n "Installing PHP-FPM... "
    #Need to check if soemthing is asked before suppress messages
    apt_install php-fpm
    sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.3/fpm/php.ini
    TIME_ZONE=$(echo "$TIME_ZONE" | sed -n 's/ (.*)$//p')
    sed -i "s/;date.timezone =/date.timezone=\"${TIME_ZONE//\//\\/}\"/" /etc/php/7.3/fpm/php.ini
    echo -e "[${green}DONE${NC}]\n"
    echo -n "Installing needed programs for PHP and nginx (mcrypt, etc.)... "
    apt_install mcrypt imagemagick memcached curl tidy snmp
    echo -e "[${green}DONE${NC}]\n"
    echo -n "Reloading PHP-FPM... "
    systemctl reload php7.3-fpm
    echo -e "[${green}DONE${NC}]\n"
    echo -n "Installing fcgiwrap... "
    apt_install fcgiwrap
    echo -e "[${green}DONE${NC}]\n"

    if [ "$CFG_PHPMYADMIN" == "yes" ]; then
      source $APWD/distros/debian10/install_phpmyadmin.sh
      echo -n "Installing phpMyAdmin... "
      InstallphpMyAdmin
      echo -e "[${green}DONE${NC}]\n"
    fi

    if [ "$CFG_PHP56" == "yes" ]; then
      echo -n "Installing PHP 5.6... "
      apt_install apt-transport-https
      curl https://packages.sury.org/php/apt.gpg | apt-key add - >/dev/null 2>&1
      echo 'deb https://packages.sury.org/php/ stretch main' >/etc/apt/sources.list.d/deb.sury.org.list
      hide_output apt-get update
      apt_install php5.6 php5.6-common php5.6-gd php5.6-mysql php5.6-imap php5.6-cli php5.6-cgi php5.6-mcrypt php5.6-curl php5.6-intl php5.6-pspell php5.6-recode php5.6-sqlite3 php5.6-tidy php5.6-xmlrpc php5.6-xsl php5.6-zip php5.6-mbstring php5.6-fpm
      echo -e "Package: *\nPin: origin packages.sury.org\nPin-Priority: 100" >/etc/apt/preferences.d/deb-sury-org
      echo -e "[${green}DONE${NC}]\n"
    fi
    echo -n "Installing Let's Encrypt (Certbot)... "
    apt_install certbot
    echo -e "[${green}DONE${NC}]\n"

    # echo -n "Installing PHP Opcode Cache... "
    # apt_install php7.3-opcache php-apcu
    # echo -e "[${green}DONE${NC}]\n"

  fi
  if [ "$CFG_PHP56" == "yes" ]; then
    echo -e "${red}Attention!!! You had installed php7 and php 5.6, to make php 5.6 work you had to configure the following in ISPConfig ${NC}"
    echo -e "${red}Path for PHP FastCGI binary: /usr/bin/php-cgi5.6 ${NC}"
    echo -e "${red}Path for php.ini directory: /etc/php/5.6/cgi ${NC}"
    echo -e "${red}Path for PHP-FPM init script: /etc/init.d/php5.6-fpm ${NC}"
    echo -e "${red}Path for php.ini directory: /etc/php/5.6/fpm ${NC}"
    echo -e "${red}Path for PHP-FPM pool directory: /etc/php/5.6/fpm/pool.d ${NC}"
  fi
}
