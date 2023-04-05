#!/bin/bash

# Create home dir and update vsftpd user db:
mkdir -p /home/vsftpd
chown -R ftp:ftp /home/vsftpd
echo -e "${FTP_USER}\n${FTP_PASS}" > /etc/vsftpd/virtual_users.txt
db_load -T -t hash -f /etc/vsftpd/virtual_users.txt /etc/vsftpd/virtual_users.db

# Set passive mode parameters:
if [ "$PASV_ADDRESS" = "REQUIRED" ]; then
	echo "Please insert IPv4 address of your host"
	exit 1
fi
if ! grep pasv_address /etc/vsftpd/vsftpd.conf > /dev/null; then
	echo "pasv_address=${PASV_ADDRESS}" >> /etc/vsftpd/vsftpd.conf
else
	sed -i "s/^pasv_address=/pasv_address=${PASV_ADDRESS}/g" /etc/vsftpd/vsftpd.conf
fi

sed -i "s/_MIN_PORT_/${PASV_MIN_PORT}/g" /etc/vsftpd/vsftpd.conf
sed -i "s/_MAX_PORT_/${PASV_MAX_PORT}/g" /etc/vsftpd/vsftpd.conf

# Run vsftpd:
vsftpd /etc/vsftpd/vsftpd.conf
