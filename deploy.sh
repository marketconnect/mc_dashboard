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

echo "🔨  Flutter build (без PWA)…"
flutter build web --release --pwa-strategy=none
echo "✅  Build ok"

BUILD_DIR="$DEPLOY_LOCAL_PATH"

echo "🗑  Удаляю service‑worker файлы (на случай кэша)…"
rm -f "$BUILD_DIR/flutter_service_worker.js" "$BUILD_DIR/version.json"

echo "🚫  Глушу регистрацию service‑воркера в JS…"
for f in "$BUILD_DIR/flutter.js" "$BUILD_DIR/flutter_bootstrap.js"; do
  [[ -f "$f" ]] \
    && sed -i 's/navigator\.serviceWorker\.register/void 0 \&\& navigator.serviceWorker.register/' "$f"
done

echo "🚀  Rsync → $DEPLOY_SERVER_USER@$DEPLOY_SERVER_IP …"
sshpass -p "$DEPLOY_SERVER_PASSWORD" rsync -av --delete \
  -e "ssh -p $DEPLOY_SERVER_PORT" \
  "$BUILD_DIR/" "$DEPLOY_SERVER_USER@$DEPLOY_SERVER_IP:$DEPLOY_REMOTE_PATH"

echo "✅  Деплой завершён без Service Worker"