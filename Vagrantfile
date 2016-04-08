# -*- mode: ruby -*-
# vi: set ft=ruby :

if File.exists?(File.expand_path "./config/global.json")
  global = JSON.parse(File.read(File.expand_path "./config/global.json"))
end
if File.exists?(File.expand_path "./config/local.json")
  local = JSON.parse(File.read(File.expand_path "./config/local.json"))
end
if File.exists?(File.expand_path "./config/sites.json")
  sites = JSON.parse(File.read(File.expand_path "./config/sites.json"))
end


# unless Vagrant.has_plugin?("vagrant-host-shell")
    # puts "`vagrant-host-shell` plugin not found. Installing it now."
    # %x( vagrant plugin install vagrant-host-shell )
#end


# Config Github Settings
github_username = "stereoplegic"
github_repo     = "Vaprobash"
github_branch   = "1.4.1"
#github_url      = "https://raw.githubusercontent.com/#{github_username}/#{github_repo}/#{github_branch}"
# Why not just get scripts from local repo?
github_url      = "."
# Because this:https://developer.github.com/changes/2014-12-08-removing-authorizations-token/
# https://github.com/settings/tokens
github_pat          = ""

# Server Configuration

hostname        = local["hostname"]

# Set a local private network IP address.
# See http://en.wikipedia.org/wiki/Private_network for explanation
# You can use the following IP ranges:
#   10.0.0.1    - 10.255.255.254
#   172.16.0.1  - 172.31.255.254
#   192.168.0.1 - 192.168.255.254
server_ip             = local["ip"]
server_cpus           = local["cpus"]   # Cores
server_memory         = local["memory"] # MB
server_swap           = local["swap"] # Options: false | int (MB) - Guideline: Between one or two times the server_memory
server_timezone       = global["timezone"] # Use "America/Los Angeles" format for PHP compatibility, not e.g. "US/Central".

# Database Configuration
mysql_root_password   = "root"   # We'll assume user "root"
mysql_version         = "5.6"    # Options: 5.5 | 5.6
mysql_enable_remote   = "false"  # remote access enabled when true
pgsql_root_password   = "root"   # We'll assume user "root"
mongo_version         = "3.0"    # Options: 2.6 | 3.0
mongo_enable_remote   = "false"  # remote access enabled when true

# Languages and Packages
php_timezone          = global["timezone"]    # http://php.net/manual/en/timezones.php
php_version           = "5.6"    # Options: 5.5 | 5.6
ruby_version          = "latest" # Choose what ruby version should be installed (will also be the default version)
ruby_gems             = [        # List any Ruby Gems that you want to install
  #"jekyll",
  #"sass",
  #"compass",
]

go_version            = "latest" # Example: go1.4 (latest equals the latest stable version)

# To install HHVM instead of PHP, set this to "true"
hhvm                  = "false"

# PHP Options
composer_packages     = [        # List any global Composer packages that you want to install
  "drush/drush:8.*",
  "drush/config-extra",
  "drupal/coder"
  # "phpunit/phpunit:4.0.*",
  # "codeception/codeception=*",
  # "phpspec/phpspec:2.0.*@dev",
  # "squizlabs/php_codesniffer:1.5.*",
]

# Default shared folder
public_folder         = "/vagrant"

# Default web server document root
# Symfony's public directory is assumed "web"
# Laravel's public directory is assumed "public"
www_folder            = "/var/www"

laravel_root_folder   = "/vagrant/laravel" # Where to install Laravel. Will `composer install` if a composer.json file exists
laravel_version       = "latest-stable" # If you need a specific version of Laravel, set it here
symfony_root_folder   = "/vagrant/symfony" # Where to install Symfony.

nodejs_version        = "latest"   # By default "latest" will equal the latest stable version
nodejs_packages       = [          # List any global NodeJS packages that you want to install
  #"grunt-cli",
  #"gulp",
  #"bower",
  #"yo",
]

# RabbitMQ settings
rabbitmq_user = "user"
rabbitmq_password = "password"

sphinxsearch_version  = "rel22" # rel20, rel21, rel22, beta, daily, stable


Vagrant.configure("2") do |config|

  # Set server to Ubuntu 14.04
  config.vm.box = "ubuntu/trusty64"

  config.vm.define "Vaprobash" do |vapro|
  end

  # Depends on vagrant-hostsupdater plugin, available via command:
  # vagrant plugin install vagrant-hostsupdater
  unless Vagrant.has_plugin?("vagrant-hostsupdater")
      #raise "`vagrant-hostsupdater` is a required plugin. Install it by running: vagrant plugin install vagrant-hostsupdater"
      puts "`vagrant-hostsupdater` plugin not found. Installing it now."
      %x( vagrant plugin install vagrant-hostsupdater )
  end
  if Vagrant.has_plugin?("vagrant-hostsupdater")
    config.vm.network :private_network, ip: "192.168.3.10"
    config.vm.hostname = "sp1local.saverhost.com"
    config.hostsupdater.aliases = []
    sites.each do |index, site|
      if site["aliases"]
        site["aliases"].each do |alias_url|
          config.hostsupdater.aliases.push(alias_url)
        end
      end
    end
  end

  # Create a hostname, don't forget to put it to the `hosts` file
  # This will point to the server's default virtual host
  # TO DO: Make this work with virtualhost along-side xip.io URL
  config.vm.hostname = local["hostname"]

  # Create a static IP
  config.vm.network :private_network, ip: server_ip
  config.vm.network :forwarded_port, guest: 80, host: 8000

  # Enable agent forwarding over SSH connections
  config.ssh.forward_agent = true

  # Use NFS for the shared folder
  config.vm.synced_folder "../../Projects", "/projects", :create=> "true"
  # Parallel-specific: sync default site files (excluded by .gitignore)
  config.vm.synced_folder "../www", "/var/www", :create=> "true"
  config.vm.synced_folder "../drush", "/home/vagrant/.drush", :create=> "true"

  # Site-specific synced folders. Local folder will be created if it doesn't exist.
  # Configure in config/sites.json
  sites.each do |index, site|
    if site["synced_folders"]
      site["synced_folders"].each do |host_path, guest_path|
        config.vm.synced_folder "#{host_path}", "#{guest_path}", :create=> "true"
      end
    end
  end

  config.vm.synced_folder ".", "/vagrant",
            id: "core"
            # :nfs => true,
            # :mount_options => ['nolock,vers=3,udp,noatime,actimeo=2']


  # Replicate local .gitconfig file if it exists
  if File.file?(File.expand_path("~/.gitconfig"))
    config.vm.provision "file", source: "~/.gitconfig", destination: ".gitconfig"
  end

  # If using VirtualBox
  config.vm.provider :virtualbox do |vb|

    vb.name = hostname

    # Set server cpus
    vb.customize ["modifyvm", :id, "--cpus", local["cpus"]]

    # Set server memory
    vb.customize ["modifyvm", :id, "--memory", local["memory"]]

    # Set the timesync threshold to 10 seconds, instead of the default 20 minutes.
    # If the clock gets more than 15 minutes out of sync (due to your laptop going
    # to sleep for instance, then some 3rd party services will reject requests.
    vb.customize ["guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 10000]

    # Prevent VMs running on Ubuntu to lose internet connection
    # vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    # vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]

  end

  # If using VMWare Fusion
  config.vm.provider "vmware_fusion" do |vb, override|
    override.vm.box_url = "http://files.vagrantup.com/precise64_vmware.box"

    # Set server memory
    vb.vmx["memsize"] = local["memory"]

  end

  # If using Vagrant-Cachier
  # http://fgrehm.viewdocs.io/vagrant-cachier
  unless Vagrant.has_plugin?("vagrant-cachier")
    puts "`vagrant-cachier` plugin not found. Installing it now."
    %x( vagrant plugin install vagrant-cachier )
  end
  if Vagrant.has_plugin?("vagrant-cachier")
    # Configure cached packages to be shared between instances of the same base box.
    # Usage docs: http://fgrehm.viewdocs.io/vagrant-cachier/usage
    config.cache.scope = :box

    #config.cache.synced_folder_opts = {
        # type: :nfs,
        # mount_options: ['rw', 'vers=3', 'tcp', 'nolock']
    #}
  end

  # Adding vagrant-digitalocean provider - https://github.com/smdahlen/vagrant-digitalocean
  # Needs to ensure that the vagrant plugin is installed
  config.vm.provider :digital_ocean do |provider, override|
    override.ssh.private_key_path = '~/.ssh/id_rsa'
    override.ssh.username = 'vagrant'
    override.vm.box = 'digital_ocean'
    override.vm.box_url = "https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box"

    provider.token = 'YOUR TOKEN'
    provider.image = 'ubuntu-14-04-x64'
    provider.region = 'nyc2'
    provider.size = '1024mb'
  end

  ####
  # Base Items
  ##########

  # Provision Base Packages
  config.vm.provision "shell", path: "#{github_url}/scripts/base.sh", args: [github_url, server_swap, server_timezone]

  # optimize base box
  config.vm.provision "shell", path: "#{github_url}/scripts/base_box_optimizations.sh", privileged: true

  # Provision PHP
  config.vm.provision "shell", path: "#{github_url}/scripts/php.sh", args: [php_timezone, hhvm, php_version]

  # Enable MSSQL for PHP
  # config.vm.provision "shell", path: "#{github_url}/scripts/mssql.sh"

  # Provision Vim
  # config.vm.provision "shell", path: "#{github_url}/scripts/vim.sh", args: github_url

  # Provision Docker
  # config.vm.provision "shell", path: "#{github_url}/scripts/docker.sh", args: "permissions"

  ####
  # Web Servers
  ##########

  # Provision Apache Base (1st line below), optionally install mod_pagespeed (2nd line below)
  config.vm.provision "shell", path: "#{github_url}/scripts/apache.sh", args: [server_ip, www_folder, hostname, github_url]
  # config.vm.provision "shell", path: "#{github_url}/scripts/mod_pagespeed.sh"

  # Provision Nginx Base
  config.vm.provision "shell", path: "#{github_url}/scripts/nginx.sh", args: [server_ip, www_folder, hostname, github_url]


  ####
  # Databases
  ##########

  # Provision MySQL
  # config.vm.provision "shell", path: "#{github_url}/scripts/mysql.sh", args: [mysql_root_password, mysql_version, mysql_enable_remote]

  # Provision PostgreSQL
  # config.vm.provision "shell", path: "#{github_url}/scripts/pgsql.sh", args: pgsql_root_password

  # Provision SQLite
  # config.vm.provision "shell", path: "#{github_url}/scripts/sqlite.sh"

  # Provision RethinkDB
  # config.vm.provision "shell", path: "#{github_url}/scripts/rethinkdb.sh", args: pgsql_root_password

  # Provision Couchbase
  # config.vm.provision "shell", path: "#{github_url}/scripts/couchbase.sh"

  # Provision CouchDB
  # config.vm.provision "shell", path: "#{github_url}/scripts/couchdb.sh"

  # Provision MongoDB
  # config.vm.provision "shell", path: "#{github_url}/scripts/mongodb.sh", args: [mongo_enable_remote, mongo_version]

  # Provision MariaDB
  config.vm.provision "shell", path: "#{github_url}/scripts/mariadb.sh", args: [mysql_root_password, mysql_enable_remote]

  # Provision Neo4J
  # config.vm.provision "shell", path: "#{github_url}/scripts/neo4j.sh"

  ####
  # Search Servers
  ##########

  # Install Elasticsearch
  # config.vm.provision "shell", path: "#{github_url}/scripts/elasticsearch.sh"

  # Install SphinxSearch
  # config.vm.provision "shell", path: "#{github_url}/scripts/sphinxsearch.sh", args: [sphinxsearch_version]

  ####
  # Search Server Administration (web-based)
  ##########

  # Install ElasticHQ
  # Admin for: Elasticsearch
  # Works on: Apache2, Nginx
  # config.vm.provision "shell", path: "#{github_url}/scripts/elastichq.sh"


  ####
  # In-Memory Stores
  ##########

  # Install Memcached
  config.vm.provision "shell", path: "#{github_url}/scripts/memcached.sh"

  # Provision Redis (without journaling and persistence)
  config.vm.provision "shell", path: "#{github_url}/scripts/redis.sh"

  # Provision Redis (with journaling and persistence)
  # config.vm.provision "shell", path: "#{github_url}/scripts/redis.sh", args: "persistent"
  # NOTE: It is safe to run this to add persistence even if originally provisioned without persistence


  ####
  # Utility (queue)
  ##########

  # Install Beanstalkd
  # config.vm.provision "shell", path: "#{github_url}/scripts/beanstalkd.sh"

  # Install Heroku Toolbelt
  # config.vm.provision "shell", path: "https://toolbelt.heroku.com/install-ubuntu.sh"

  # Install Supervisord
  # config.vm.provision "shell", path: "#{github_url}/scripts/supervisord.sh"

  # Install Kibana
  # config.vm.provision "shell", path: "#{github_url}/scripts/kibana.sh"

  # Install ØMQ
  # config.vm.provision "shell", path: "#{github_url}/scripts/zeromq.sh"

  # Install RabbitMQ
  # config.vm.provision "shell", path: "#{github_url}/scripts/rabbitmq.sh", args: [rabbitmq_user, rabbitmq_password]

  ####
  # Additional Languages
  ##########

  # Install Nodejs
  # config.vm.provision "shell", path: "#{github_url}/scripts/nodejs.sh", privileged: false, args: nodejs_packages.unshift(nodejs_version, github_url)

  # Install Ruby Version Manager (RVM)
  # config.vm.provision "shell", path: "#{github_url}/scripts/rvm.sh", privileged: false, args: ruby_gems.unshift(ruby_version)

  # Install Go Version Manager (GVM)
  # config.vm.provision "shell", path: "#{github_url}/scripts/go.sh", privileged: false, args: [go_version]

  ####
  # Frameworks and Tooling
  ##########

  # Provision Composer
  # You may pass a github auth token as the first argument
  config.vm.provision "shell", path: "#{github_url}/scripts/composer.sh", privileged: false, args: [github_pat, composer_packages.join(" ")]

  # Drush Modules
  # Install if Drush has been installed via Composer (set in composer_packages variable)
  config.vm.provision "shell", path: "#{github_url}/scripts/drush-modules.sh", privileged: false

  # Provision Laravel
  # config.vm.provision "shell", path: "#{github_url}/scripts/laravel.sh", privileged: false, args: [server_ip, laravel_root_folder, www_folder, laravel_version]

  # Provision Symfony
  # config.vm.provision "shell", path: "#{github_url}/scripts/symfony.sh", privileged: false, args: [server_ip, symfony_root_folder, www_folder]

  # Install Screen
  # config.vm.provision "shell", path: "#{github_url}/scripts/screen.sh"

  # Install Mailcatcher
  # config.vm.provision "shell", path: "#{github_url}/scripts/mailcatcher.sh"

  # Install git-ftp
  # config.vm.provision "shell", path: "#{github_url}/scripts/git-ftp.sh", privileged: false

  # Install Ansible
  # config.vm.provision "shell", path: "#{github_url}/scripts/ansible.sh"

  # Install Android
  # config.vm.provision "shell", path: "#{github_url}/scripts/android.sh"

  ####
  # Local Scripts
  # Any local scripts you may want to run post-provisioning.
  # Add these to the same directory as the Vagrantfile.
  ##########
  # config.vm.provision "shell", path: "./local-script.sh"

  ####
  # Site Provisioning Scripts
  # Create Apache vhost and/or Nginx server block for each site with
  # "enabled": true
  # set in config/sites.json

  sites.each do |index, site|
    if site["enabled"]
      if site["provisioners"]
        site["provisioners"].each_with_index do |provisioner|
          if provisioner["type"] == "inline"
            config.vm.provision :shell, privileged: provisioner["privileged"], inline: provisioner["script"]
          else
            config.vm.provision provisioner["type"], privileged: provisioner["privileged"], path: provisioner["script"]
          end
        end
      end
    end
  end

  #config.vm.provision "shell", path: "../scripts/vhosts/enlightencoffee.sh"

  #config.vm.provision "shell", path: "../scripts/vhosts/euphoriemassage.sh"

  #config.vm.provision "shell", path: "../scripts/vhosts/iqdecoration.sh"

  #config.vm.provision "shell", path: "../scripts/vhosts/mikebybee.sh"

  #config.vm.provision "shell", path: "../scripts/vhosts/d8.parallelpublicworks.sh", args: [mysql_root_password]
  #config.vm.provision :shell, privileged: false, inline: "~/.composer/vendor/bin/drush @parallel.d8 updb"

  #config.vm.provision "shell", path: "../scripts/vhosts/kb.parallelpublicworks.sh", args: [mysql_root_password]
  #config.vm.provision :shell, privileged: false, inline: "~/.composer/vendor/bin/drush @parallel.kb en -y diff"

  #config.vm.provision "shell", path: "../scripts/vhosts/otolaryngology.uw.sh", args: [mysql_root_password]
  #config.vm.provision :shell, privileged: false, inline: "~/.composer/vendor/bin/drush @parallel.uw-oto en -y diff devel"

  #config.vm.provision "shell", path: "../scripts/vhosts/immunology.uw.sh", args: [mysql_root_password]
  #config.vm.provision :shell, privileged: false, inline: "~/.composer/vendor/bin/drush @parallel.uw-immunology updb -y"

  #config.vm.provision "shell", path: "../scripts/vhosts/ophthalmology.uw.sh", args: [mysql_root_password]
  #config.vm.provision :shell, privileged: false, inline: "~/.composer/vendor/bin/drush @parallel.uw-ophthalmology updb -y"

  #config.vm.provision "shell", path: "../scripts/vhosts/newsbeat.uw.sh", args: [mysql_root_password]
  # Aggregated CSS can render as an invalid mimetype if not unset after import
  #config.vm.provision :shell, privileged: false, inline: "~/.composer/vendor/bin/drush @parallel.newsbeat updb -y"
  #config.vm.provision :shell, privileged: false, inline: "~/.composer/vendor/bin/drush @parallel.newsbeat vset preprocess_css 0 -y"
  #config.vm.provision :shell, privileged: false, inline: "~/.composer/vendor/bin/drush @parallel.newsbeat vset preprocess_css 1 -y"

  #config.vm.provision "shell", path: "../scripts/vhosts/cel.sh", args: [mysql_root_password]
  #config.vm.provision :shell, privileged: false, inline: "~/.composer/vendor/bin/drush @parallel.cel updb -y"

  #config.vm.provision "shell", path: "../scripts/vhosts/d6.5d.cel.sh", args: [mysql_root_password]
  #config.vm.provision :shell, privileged: false, inline: "~/.composer/vendor/bin/drush @parallel.d6.5d.cel updb -y"

  #config.vm.provision "shell", path: "../scripts/vhosts/del-ece.sh", args: [mysql_root_password]
  #config.vm.provision :shell, privileged: false, inline: "~/.composer/vendor/bin/drush @parallel.del-ece updb -y"

  #config.vm.provision "shell", path: "../scripts/vhosts/alliedfeather.sh", args: [mysql_root_password]
  #config.vm.provision :shell, privileged: false, inline: "~/.composer/vendor/bin/drush @parallel.alliedfeather updb -y"

  #config.vm.provision "shell", path: "../scripts/vhosts/iposc.sh", args: [mysql_root_password]
  #config.vm.provision :shell, privileged: false, inline: "~/.composer/vendor/bin/drush @parallel.iposc updb -y"

  #config.vm.provision "shell", path: "../scripts/vhosts/realnetworks.sh", args: [mysql_root_password]
  #config.vm.provision :shell, privileged: false, inline: "~/.composer/vendor/bin/drush @parallel.realnetworks updb -y"

  #config.vm.provision "shell", path: "../scripts/vhosts/rnn.sh", args: [mysql_root_password]
  #config.vm.provision :shell, privileged: false, inline: "~/.composer/vendor/bin/drush @parallel.rnn updb -y"

  #config.vm.provision "shell", path: "../scripts/vhosts/wria1.sh", args: [mysql_root_password]
  #config.vm.provision :shell, privileged: false, inline: "~/.composer/vendor/bin/drush @parallel.wria1 updb -y"

  #config.vm.provision "shell", path: "../scripts/vhosts/wscc.sh", args: [mysql_root_password]
  #config.vm.provision :shell, privileged: false, inline: "~/.composer/vendor/bin/drush @parallel.wscc updb -y"

end
