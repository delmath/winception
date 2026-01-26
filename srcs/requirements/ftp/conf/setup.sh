#!/bin/bash
mkdir -p /var/run/vsftpd/empty

if ! id -u "$FTP_USER" > /dev/null 2>&1; then
    echo "Creating FTP user..."
    useradd -m -d /var/www/html -s /bin/bash "$FTP_USER"
    echo "$FTP_USER:$FTP_PASSWORD" | chpasswd
    echo "FTP user created successfully"
else
    echo "FTP user already exists"
fi

echo "$FTP_USER" > /etc/vsftpd.userlist

chown -R "$FTP_USER:$FTP_USER" /var/www/html
chmod -R 755 /var/www/html

echo "Starting vsftpd..."
exec /usr/sbin/vsftpd /etc/vsftpd.conf
