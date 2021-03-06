#!/usr/bin/env bash

WebRoot=/var/www

# Show the usage for NGXCB
function show_usage {
cat <<EOF

NGXCB:
Create a new Nginx Server Block (Ubuntu Server).
Assumes /etc/nginx/sites-available and /etc/nginx/sites-enabled setup used.

    -f    Optional - Force ngxcb to overwrite given server block file name
    -e    Optional - Enable the Server Block right away with NGXEN - i.e "-e" (without any value)
    -d    DocumentRoot - subfolder of $WebRoot - i.e. "-d yoursite" $WebRoot/yoursite - Optional: defaults to ServerName (-s switch)
    -h    Help - Show this menu.
    -n    The Server Block file name - i.e. "-n yoursite" - Optional: Defaults to DocumentRoot (-d switch), or ServerName (-s) if -d switch not set
    -s    ServerName (Required) - i.e. "-s yoursite.com"

EOF
exit 1
}

if [ $EUID -ne 0 ]; then
    echo "!!! Please use root: \"sudo ngxcb\""
    show_usage
fi

# Output Nginx Server Block Config
function create_server_block {

    # Test if Apache is installed
    apache2 -v > /dev/null 2>&1
    APACHE_IS_INSTALLED=$?

    # Test if PHP is installed
    php -v > /dev/null 2>&1
    PHP_IS_INSTALLED=$?

    # Test if HHVM is installed
    hhvm --version > /dev/null 2>&1
    HHVM_IS_INSTALLED=$?
    [[ $HHVM_IS_INSTALLED -eq 0 ]] && { PHP_IS_INSTALLED=-1; }

    # Default empty Nginx Root Directive
    NGINX_ROOT_DIR_NO_SSL=""
    NGINX_ROOT_DIR_WITH_SSL=""

    if [[ $APACHE_IS_INSTALLED -eq 0 ]]; then

read -d '' NGINX_ROOT_DIR_NO_SSL <<EOF
        location / {
            proxy_pass http://127.0.0.1:81;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
            proxy_connect_timeout 600;
            proxy_send_timeout 600;
            proxy_read_timeout 600;
            send_timeout 600;
        }
EOF

read -d '' NGINX_ROOT_DIR_WITH_SSL <<EOF
        location / {
            proxy_pass http://127.0.0.1:4543;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
            proxy_connect_timeout 600;
            proxy_send_timeout 600;
            proxy_read_timeout 600;
            send_timeout 600;
        }
EOF

        # Default empty PHP Config
        PHP_NO_SSL=""
        PHP_WITH_SSL=""

    else

read -d '' NGINX_ROOT_DIR_NO_SSL <<EOF
        location / {
            try_files \$uri \$uri/ /app.php?\$query_string /index.php?\$query_string;
        }
EOF

read -d '' NGINX_ROOT_DIR_WITH_SSL <<EOF
        location / {
            try_files \$uri \$uri/ /app.php?\$query_string /index.php?\$query_string;
        }
EOF

        if [[ $PHP_IS_INSTALLED -eq 0 ]]; then

# Nginx Server Block config for PHP (without using SSL)
read -d '' PHP_NO_SSL <<EOF
        # pass the PHP scripts to php5-fpm
        # Note: \.php$ is susceptible to file upload attacks
        # Consider using: "location ~ ^/(index|app|app_dev|config)\.php(/|$) {"
        location ~ \.php$ {
            try_files \$uri =404;
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            # With php5-fpm:
            fastcgi_pass 127.0.0.1:9000;
            fastcgi_index index.php;
            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
            fastcgi_param LARA_ENV local; # Environment variable for Laravel
            fastcgi_param HTTPS off;
        }
EOF

# Nginx Server Block config for PHP (with SSL)
read -d '' PHP_WITH_SSL <<EOF
        # pass the PHP scripts to php5-fpm
        # Note: \.php$ is susceptible to file upload attacks
        # Consider using: "location ~ ^/(index|app|app_dev|config)\.php(/|$) {"
        location ~ \.php$ {
            try_files \$uri =404;
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            # With php5-fpm:
            fastcgi_pass 127.0.0.1:9000;
            fastcgi_index index.php;
            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
            fastcgi_param LARA_ENV local; # Environment variable for Laravel
            fastcgi_param HTTPS on;
        }
EOF
        fi

        if [[ $HHVM_IS_INSTALLED -eq 0 ]]; then

# Nginx Server Block config for HHVM (without using SSL)
read -d '' PHP_NO_SSL <<EOF
        # pass the PHP scripts to php5-fpm
        location ~ \.(hh|php)$ {
            try_files \$uri =404;
            fastcgi_keep_conn on;
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            # With HHVM:
            fastcgi_pass 127.0.0.1:9000;
            fastcgi_index index.php;
            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
            fastcgi_param LARA_ENV local; # Environment variable for Laravel
            fastcgi_param HTTPS off;
        }
EOF

# Nginx Server Block config for HHVM (with SSL)
read -d '' PHP_WITH_SSL <<EOF
        # pass the PHP scripts to php5-fpm
        location ~ \.(hh|php)$ {
            try_files \$uri =404;
            fastcgi_keep_conn on;
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            # With HHVM:
            fastcgi_pass 127.0.0.1:9000;
            fastcgi_index index.php;
            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
            fastcgi_param LARA_ENV local; # Environment variable for Laravel
            fastcgi_param HTTPS on;
        }
EOF
        fi
    fi

# Main Nginx Server Block Config
cat <<EOF
    server {
        listen 80;

        root $WebRoot/$DocumentRoot;
        index index.html index.htm index.php app.php app_dev.php;

        # Make site accessible from ...
        server_name $ServerName;

        access_log /var/log/nginx/vagrant.com-access.log;
        error_log  /var/log/nginx/vagrant.com-error.log error;

        charset utf-8;

        $NGINX_ROOT_DIR_NO_SSL

        location = /favicon.ico { log_not_found off; access_log off; }
        location = /robots.txt  { access_log off; log_not_found off; }

        error_page 404 /index.php;

        $PHP_NO_SSL

        # Deny .htaccess file access
        location ~ /\.ht {
            deny all;
        }
    }

    server {
        listen 443;

        ssl on;
        ssl_certificate     /etc/ssl/xip.io/xip.io.crt;
        ssl_certificate_key /etc/ssl/xip.io/xip.io.key;

        root $WebRoot/$DocumentRoot;
        index index.html index.htm index.php app.php app_dev.php;

        # Make site accessible from ...
        server_name $ServerName;

        access_log /var/log/nginx/vagrant.com-access.log;
        error_log  /var/log/nginx/vagrant.com-error.log error;

        charset utf-8;

        $NGINX_ROOT_DIR_WITH_SSL

        location = /favicon.ico { log_not_found off; access_log off; }
        location = /robots.txt  { access_log off; log_not_found off; }

        error_page 404 /index.php;

        $PHP_WITH_SSL

        # Deny .htaccess file access
        location ~ /\.ht {
            deny all;
        }
    }
EOF
}

# Check if there are enough arguments provided (2 arguments and there 2 values)
if [[ $# -lt 2 ]]; then
    echo "!!! Not enough arguments. Please read the below for NGXCB useage:"
    show_usage
fi

# The default for the optional argument's:
#ServerBlockName="vagrant"
EnableServerBlock=0
NeedsReload=0
ForceOverwrite=0

# Parse flags:
# - Run it in "silence"-mode by starting with a ":"
# - Single ":" after an argument means "required"
# - Double ":" after an argument means "optional"
while getopts ":hd:s:n::ef" OPTION; do
    case $OPTION in
        h)
            show_usage
            ;;
        d)
            DocumentRoot=$OPTARG
            ;;
        s)
            ServerName=$OPTARG
            ;;
        n)
            ServerBlockName=$OPTARG
            ;;
        e)
            EnableServerBlock=1
            ;;
        f)
            ForceOverwrite=1
            ;;
        *)
            show_usage
            ;;
    esac
done

if [[ "$ServerName" == "" ]]; then
    echo "ERROR: Option -s required with an argument." >&2
    show_usage
    exit 1
fi

if [ "$DocumentRoot" == "" ]; then
    DocumentRoot=$ServerName
fi

if [ "$ServerBlockName" == "" ]; then
    ServerBlockName=$ServerName
fi

if [[ ! -d $WebRoot/$DocumentRoot ]]; then
    mkdir -p $WebRoot/$DocumentRoot
fi

if [[ $ForceOverwrite -eq 1 ]]; then
    # remove symlink from sites-enabled directory
    rm -f "/etc/nginx/sites-enabled/${ServerBlockName}" &>/dev/null
    if [[ $? -eq 0 ]]; then
        # if file has been removed, provide user with information that existing server
        # block is being overwritten
        echo ">>> ${ServerBlockName} is enabled and will be overwritten"
        echo ">>> to enable this server block execute 'ngxen ${ServerBlockName}' or use the -e flag"
        NeedsReload=1
    fi
elif [[ -f "/etc/nginx/sites-available/${ServerBlockName}" ]]; then
    echo "!!! Nginx Server Block already exists. Aborting!"
    show_usage
fi

# Create the Server Block config
create_server_block > /etc/nginx/sites-available/${ServerBlockName}

# Enable the Server Block and reload Nginx
if [[ $EnableServerBlock -eq 1 ]]; then
    # Enable Server Block
    ngxen -q ${ServerBlockName}

    # Reload Nginx
    NeedsReload=1
fi

[[ $NeedsReload -eq 1 ]] && service nginx reload
