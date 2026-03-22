#!/bin/bash
exec > >(tee -a /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "[INFO] Starting bootstrap process..."
apt-get update -y
apt-get install -y apache2

# Налаштування кастомного порту 8008
sed -i "s/Listen 80/Listen ${WEB_PORT}/" /etc/apache2/ports.conf

# Створення DocumentRoot та сторінки
mkdir -p ${DOC_ROOT}
cat <<EOF > ${DOC_ROOT}/index.html
<!DOCTYPE html>
<html>
<head><title>Lab 3 - Terraform IaC</title></head>
<body>
    <h1>Infrastructure Deployed Successfully</h1>
    <p>Student: ${STUDENT}</p>
    <p>Port: ${WEB_PORT}</p>
    <p>DocRoot: ${DOC_ROOT}</p>
</body>
</html>
EOF

# Налаштування VirtualHost
cat <<EOF > /etc/apache2/sites-available/custom.conf
<VirtualHost *:${WEB_PORT}>
    ServerName ${SERVER_NAME}
    DocumentRoot ${DOC_ROOT}
</VirtualHost>
EOF

# Дозвіл доступу до директорії
echo "<Directory ${DOC_ROOT}>
    Require all granted
</Directory>" >> /etc/apache2/apache2.conf

# Активація конфігурації
a2dissite 000-default.conf
a2ensite custom.conf
systemctl restart apache2
systemctl enable apache2
echo "[INFO] Bootstrap finished successfully"