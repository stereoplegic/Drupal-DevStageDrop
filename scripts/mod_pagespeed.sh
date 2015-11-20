#!/usr/bin/env bash

# Test if Apache is installed
apache2 -v > /dev/null 2>&1
APACHE_IS_INSTALLED=$?

if [[ $APACHE_IS_INSTALLED -eq 0 ]]; then
  wget https://dl-ssl.google.com/dl/linux/direct/mod-pagespeed-stable_current_amd64.deb
  dpkg -i mod-pagespeed-stable_current_amd64.deb
  rm -rf mod-pagespeed-stable_current_amd64.deb
fi
