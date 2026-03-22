exec > >(tee -a /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "[INFO] Start bootstrapping..."
apt-get update -y
apt-get install -y apache2

sed -i "s/Listen 80/Listen ${WEB_PORT}/" /etc/apache2/ports.conf

mkdir -p ${DOC_ROOT}
cat <<EOF > ${DOC_ROOT}/index.html
<h1>AWS Infrastructure Deployed via Terraform</h1>
<p><strong>Student:</strong> ${STUDENT}</p>
<p><strong>Port:</strong> ${WEB_PORT}</p>
<p><strong>DocRoot:</strong> ${DOC_ROOT}</p>
EOF

cat <<EOF > /etc/apache2/sites-available/custom.conf
<VirtualHost *:${WEB_PORT}>
    ServerName ${SERVER_NAME}
    DocumentRoot ${DOC_ROOT}
</VirtualHost>
EOF

echo "<Directory ${DOC_ROOT}>
    Require all granted
</Directory>" >> /etc/apache2/apache2.conf

a2dissite 000-default.conf
a2ensite custom.conf
systemctl restart apache2