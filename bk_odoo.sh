#!/bin/bash

#VARIABLES

BACKUP_DIR=$HOME/backup-odoo/
ODOO_DATABASE=example-database
ADMIN_PASSWORD=example-password
FICHERO=$BACKUP_DIR/*.zip

#Consulta si ya existe el directorio
if [ -d "$BACKUP_DIR" ]
then
	
    #Si el directorio ya exite se mueve el antiguo backup a la carpeta basura y luego se continua descargando el nuevo
	#También borra todo archivo .zip que estuviese antes en la carpeta basura.

	if [ -f $FICHERO ]
	then
		sudo find $BACKUP_DIR/basura -name "*.zip" -exec rm -rf {} \;
		echo "Actualizando backup y moviendo a carpeta basura el antiguo.."
                sudo mv $FICHERO $BACKUP_DIR/basura
	else
		echo "Se esta creando el backup por primera vez..."
	fi
    
	# CREA BACKUP Y LO DESCARGA
	sudo curl -X POST \
	-F "master_pwd=${ADMIN_PASSWORD}" \
	-F "name=${ODOO_DATABASE}" \
	-F "backup_format=zip" \
	-o ${BACKUP_DIR}/${ODOO_DATABASE}.$(date +%F).zip \
	http://localhost:8069/web/database/backup
	echo "Backup completado!"
	
else

    #Si el directorio no existe creará una serie de carpetas y moverá el script a una nueva ubicación

	sudo rm /etc/localtime
    sudo ln -s /usr/share/zoneinfo/America/Buenos_Aires /etc/localtime
    echo "Fecha y hora actualizadas!"
	sudo mkdir -p $BACKUP_DIR/basura
	sudo chmod 777 $BACKUP_DIR
	sudo cp $HOME/git/odoo/bk_odoo.sh $BACKUP_DIR
	sudo chmod ugo+x $BACKUP_DIR/bk_odoo.sh
	echo "Directorios creados!"

	sh $BACKUP_DIR/bk_odoo.sh
	

fi

