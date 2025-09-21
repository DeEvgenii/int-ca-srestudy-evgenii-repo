#!/bin/bash
set -e # Прекратить выполнение скрипта при любой ошибке

# --- Переменные ---
INSTANCE_CONNECTION_NAME="ca-srestudy-evgenii-lift-dev:asia-northeast1:db-dev"

# --- Установка базовых пакетов ---
apt-get update
apt-get install -y wget curl nginx

# --- Настройка Nginx ---
systemctl enable nginx
systemctl start nginx

# --- Установка Ops Agent ---
curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
bash add-google-cloud-ops-agent-repo.sh --also-install
rm add-google-cloud-ops-agent-repo.sh

# --- Установка Cloud SQL Auth Proxy ---
wget https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/v2.8.2/cloud-sql-proxy.linux.amd64 -O /usr/local/bin/cloud-sql-proxy
chmod +x /usr/local/bin/cloud-sql-proxy

# --- Подготовка для безопасного запуска Прокси ---
# 1. Создаем системного пользователя без права входа
useradd -r -s /bin/false cloudsqlproxy || echo "User cloudsqlproxy already exists"

# 2. Создаем директорию для сокета
mkdir -p /cloudsql

# 3. Назначаем этого пользователя владельцем директории
chown cloudsqlproxy:cloudsqlproxy /cloudsql

# --- Создание правильного systemd сервиса для Прокси ---
cat <<EOF > /etc/systemd/system/cloud-sql-proxy.service
[Unit]
Description=Google Cloud SQL Auth Proxy
After=network.target

[Service]
# Запускаем от имени безопасного, ограниченного пользователя
User=cloudsqlproxy
Group=cloudsqlproxy

# Используем команду со всеми необходимыми флагами
ExecStart=/usr/local/bin/cloud-sql-proxy \
    --auto-iam-authn \
    --private-ip \
    -u /cloudsql \
    ${INSTANCE_CONNECTION_NAME}

Restart=always

[Install]
WantedBy=multi-user.target
EOF

# --- Запуск Прокси ---
systemctl daemon-reload
systemctl enable cloud-sql-proxy.service
systemctl start cloud-sql-proxy.service

apt-get update
apt-get install -y wget curl nginx default-mysql-client 

echo "Startup script finished successfully!"
