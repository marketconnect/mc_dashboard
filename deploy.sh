#!/bin/bash

if [[ -z "$DEPLOY_SERVER_USER" || -z "$DEPLOY_SERVER_IP" || -z "$DEPLOY_REMOTE_PATH" || -z "$DEPLOY_LOCAL_PATH" || -z "$DEPLOY_SERVER_PASSWORD" || -z "$DEPLOY_SERVER_PORT" ]]; then
  echo "Ошибка: отсутствуют необходимые переменные окружения."
  echo "Убедитесь, что заданы следующие переменные:"
  echo "  DEPLOY_SERVER_USER - имя пользователя на сервере"
  echo "  DEPLOY_SERVER_IP - IP-адрес сервера"
  echo "  DEPLOY_REMOTE_PATH - путь на сервере для размещения файлов"
  echo "  DEPLOY_LOCAL_PATH - локальная папка с файлами для деплоя"
  echo "  DEPLOY_SERVER_PASSWORD - пароль пользователя для SSH-доступа"
  echo "  DEPLOY_SERVER_PORT - порт SSH"
  exit 1
fi

echo "Начинаю сборку Flutter веб-приложения..."
flutter build web --release
if [[ $? -ne 0 ]]; then
  echo "Ошибка при сборке Flutter веб-приложения."
  exit 1
fi
echo "Сборка завершена успешно!"

echo "Начинаю деплой на $DEPLOY_SERVER_USER@$DEPLOY_SERVER_IP через порт $DEPLOY_SERVER_PORT..."
sshpass -p "$DEPLOY_SERVER_PASSWORD" rsync -av --delete -e "ssh -p $DEPLOY_SERVER_PORT" "$DEPLOY_LOCAL_PATH" "$DEPLOY_SERVER_USER@$DEPLOY_SERVER_IP:$DEPLOY_REMOTE_PATH"

if [[ $? -eq 0 ]]; then
  echo "Деплой успешно завершён!"
else
  echo "Ошибка во время деплоя."
  exit 1
fi
