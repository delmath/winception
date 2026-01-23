#!/bin/bash

if ! id -u ftpuser > /dev/null 2>&1; then
    echo "Creating FTP user..."
    useradd -m -d /var/www/html -s /bin/bash ftpuser
    echo "ftpuser:${FTP_PASSWORD:-ftppass}" | chpasswd
    echo "FTP user created successfully"
else
    echo "FTP user already exists"
fi

echo "ftpuser" > /etc/vsftpd.userlist

chown -R ftpuser:ftpuser /var/www/html
chmod -R 755 /var/www/html

echo "Starting vsftpd..."
exec /usr/sbin/vsftpd /etc/vsftpd.conf
