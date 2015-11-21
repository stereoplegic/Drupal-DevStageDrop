#!/usr/bin/env bash

# Install drush modules - run unprivileged

# Vagrant struggles to find composer path on provision, so use full path.
# On subsequent "vagrant ssh" sessions, you can simply type "drush [optional command]".

# No 8.x version of these modules exist yet, so append "-7.x" to the module name for the time being.
~/.composer/vendor/bin/drush dl -y drush_extras-7.x --destination=$HOME/.drush
~/.composer/vendor/bin/drush dl -y coder-7.x --destination=$HOME/.drush
~/.composer/vendor/bin/drush dl -y registry_rebuild-7.x --destination=$HOME/.drush
~/.composer/vendor/bin/drush dl -y hacked-7.x --destination=$HOME/.drush
~/.composer/vendor/bin/drush dl -y site_audit-7.x --destination=$HOME/.drush
~/.composer/vendor/bin/drush dl -y module_builder-7.x --destination=$HOME/.drush

~/.composer/vendor/bin/drush cc drush

