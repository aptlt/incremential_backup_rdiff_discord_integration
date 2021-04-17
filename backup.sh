#!/bin/bash

##########################################################################
#                                                                        #
#   Script permettant le backup des répertoires suivants :               #
#                                                                        #
#   - /var/lib/pterodactyl/volumes   -- volumes pterodactyl              #
#   - /var/www                       -- statiques web                    #
#   - /etc/nginx                     -- configuration nginx              #
#   - /tmp/back/mysql                -- bases de données applicatives    #
#                                                                        #
#   Création :                          08/04/2021                       #
#   Dernière modification :             08/04/2021                       #
#                                                                        #
#   Pré-requis : Script "discord.sh" présent dans le même répertoire     #
#                                                                        #
##########################################################################


## Définition des variables principales 

DATE=$(date +%d-%m-%Y_%H\h%M)

WORK_DIR="$PWD"

LOG_DIR=${WORK_DIR}/log
mkdir -p ${LOG_DIR}

BACKUP_DIR="/var/lib/pterodactyl/backups"

## Création du répertoire temporaire d'export des dumps MySQL
mkdir -p /tmp/backup/mysql

## Export des bases
export_db=${LOG_DIR}/export_db_${DATE}.log
export_db_tmp=${LOG_DIR}/export_db_tmp.log

for DB in $(mysql -e 'show databases' -s --skip-column-names); do
    mysqldump -v $DB > "/tmp/backup/mysql/$DB.sql" 2>> ${export_db_tmp}
done

grep --ignore-case "error" ${export_db_tmp} >> ${export_db}

rm -f ${export_db_tmp}

## Creation du fichier de log envoye à Discord
log_send=${LOG_DIR}/backup_${DATE}.log

## Variable couleur OK ou FAILED
couleur=0x67C627

## Départ du script : backup des répertoires
dir_to_save=(volumes www nginx mysql)

for dir in "${dir_to_save[@]}"
do
    case ${dir} in

        volumes)
            dir_source=/var/lib/pterodactyl/volumes
            ;;

        www)
            dir_source=/var/www
            ;;
        
        nginx)
            dir_source=/etc/nginx
            ;;

        mysql)
            dir_source=/tmp/backup/mysql
            ;;
    esac

    ## Exécution du backup
    log_temp=${LOG_DIR}/backup_${dir}_${DATE}.log
    rdiff-backup -v5 ${dir_source} ${BACKUP_DIR}/${dir} > ${log_temp} 2>&1

    ## Gestion des erreurs
    if [ "$?" = 0 ]
    then
        echo -n "Backup du répertoire ${dir_source} \nOK\n\n" >> ${log_send}
    else
        echo -n "Backup du répertoire ${dir_source} \nFAILED\nCause :\n" >> ${log_send}
        cat ${log_temp} >> ${log_send}
        echo -n "\n" >> ${log_send}
        couleur=0xD21D38
        notify_owner="<@code_discord_user_to_notify>"
    fi

    rm -f ${log_temp}

done

## Suppression répertoire temporaire d'export des dumps MySQL
rm -rf /tmp/backup/mysql

## Declaration de la variable DISCORD_WEBHOOK
DISCORD_WEBHOOK=https://URL_WEBHOOK_DISCORD
export DISCORD_WEBHOOK

## Supprimer les retour à la ligne et les remplacer par le string "\n"
sed -i ':a;N;$!ba;s/\n/\\n/g' ${log_send}

## Envoi 
text_discord=`cat ${log_send}`

./discord.sh \
    --username "RoboBackup" \
    --title "RECAPITULATIF BACKUP ${DATE}" \
    --description "${text_discord}" \
    --text "${notify_owner}" \
    --color ${couleur}
    
${WORK_DIR}/discord.sh \
    --username "RoboBackup" \
    --file ${export_db} 
