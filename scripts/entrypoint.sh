#! /bin/sh
set -e

CONF_FILE="$APP_WORK/lstu.conf"
DB_FILE="$APP_WORK/lstu.db"
PID_FILE="$APP_WORK/lstu.pid"

if [ ! -f "$CONF_FILE" ]; then
	# Création de la configuration
	cp "$APP_HOME/lstu.conf.template" "$CONF_FILE"

	# Modifications des valeurs
	sed -i -E "s|listen\s+=>\s+\['.*'\]|listen => ['http://*:8080']|" "$CONF_FILE"
	sed -i -E "s|#proxy\s+=>.*,|proxy => 1,|" "$CONF_FILE"
	sed -i -E "s|#contact\s+=>.*,|contact => 'docker[at]localhost.localdomain',|" "$CONF_FILE"
	sed -i -E "s|#secret\s+=>.*,|secret => '$(head -c1024 /dev/urandom | sha1sum | cut -d' ' -f1)',|" "$CONF_FILE"
	sed -i -E "s|#dbtype\s+=>.*,|dbtype => 'sqlite',|" "$CONF_FILE"
	sed -i -E "s|#db_path\s+=>.*,|db_path => '$DB_FILE',|" "$CONF_FILE"

	# Protection par defaut
	ADMIN_PASSWORD=$(head -c1024 /dev/urandom | sha1sum | cut -d' ' -f1)
	echo "Admin passord: $ADMIN_PASSWORD"
	sed -i -E "s|#adminpwd\s+=>.*,|adminpwd => '$ADMIN_PASSWORD',|" "$CONF_FILE"

	# Pid file
	sed -i "/hypnotoad => {/a        pid_file => '$PID_FILE'," "$CONF_FILE"

fi

if [ -f "$DB_FILE" ]; then
	# VACUUM DB
	echo "Vacuum $DB_FILE ..."
	echo "vacuum;" | sqlite3 "$DB_FILE"
fi

# Reset perms
chown -R "$APP_USER" "$APP_WORK"

# Clean pid file
if [ -f "$PID_FILE" ]; then
	echo "Removing $PID_FILE .."
	rm -f $PID_FILE
fi

# Démarrage de Lstu
cd "$APP_HOME" && \
	MOJO_CONFIG="$CONF_FILE" exec gosu "$APP_USER" carton exec hypnotoad -f script/lstu