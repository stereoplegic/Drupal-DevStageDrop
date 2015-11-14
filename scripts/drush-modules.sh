# Install drush modules - run unprivileged
~/.composer/vendor/bin/drush dl drush_extras --destination=$HOME/.drush
~/.composer/vendor/bin/drush dl coder --destination=$HOME/.drush
~/.composer/vendor/bin/drush dl registry_rebuild --destination=$HOME/.drush
~/.composer/vendor/bin/drush dl hacked --destination=$HOME/.drush
~/.composer/vendor/bin/drush dl site_audit --destination=$HOME/.drush
~/.composer/vendor/bin/drush dl module_builder --destination=$HOME/.drush

~/.composer/vendor/bin/drush cc drush
