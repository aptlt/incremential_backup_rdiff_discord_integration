# Backup incrementiel avec envoi d'infos à Discord

Backup de répertoires Linux avec envoi d'une notification à Discord. 

Pour l'envoi à Discord, le script s'appuie sur le super travail réalisé par l'équipe ChaoticWeg :
- https://github.com/ChaoticWeg/discord.sh
Merci à eux pour le partage de leur solution

Répertoires sauvegardés par ce script (facilement adaptable - WIP) :
- /var/lib/pterodactyl/volumes
- /var/www
- /etc/nginx
- /tmp/backup/mysql

*Pré-requis :*
- *déposer les scripts backup.sh et discord.sh dans le même répertoire*
- *avoir les droits d'écriture dans le répertoire de dépose des scripts (création d'un répertoire de log durant l'exécution du script)*
