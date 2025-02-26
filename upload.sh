#!/bin/bash

set -e  # Остановить выполнение при ошибке

# Проверка переменных окружения
if [[ -z "$YANDEX_BUCKET" || -z "$YANDEX_ACCESS_KEY" || -z "$YANDEX_SECRET_KEY" || -z "$YANDEX_FOLDER_ID" ]]; then
  echo "Ошибка: отсутствуют необходимые переменные окружения."
  echo "Убедитесь, что заданы следующие переменные:"
  echo "  YANDEX_BUCKET - имя бакета"
  echo "  YANDEX_ACCESS_KEY - Access Key"
  echo "  YANDEX_SECRET_KEY - Secret Key"
  echo "  YANDEX_FOLDER_ID - Folder ID"
  exit 1
fi

# 1️⃣ **Сборка Flutter Web**
echo "Начинаю сборку Flutter веб-приложения..."
flutter build web --release
if [[ $? -ne 0 ]]; then
  echo "Ошибка при сборке Flutter веб-приложения."
  exit 1
fi
echo "✅ Сборка завершена успешно!"

# 2️⃣ **Очистка бакета перед загрузкой**
echo "Очистка бакета $YANDEX_BUCKET..."
OBJECTS=$(yc storage object list --bucket="$YANDEX_BUCKET" --format=json | jq -r '.[].key')

if [[ -n "$OBJECTS" ]]; then
  for object in $OBJECTS; do
    yc storage object delete --bucket="$YANDEX_BUCKET" --object="$object"
    echo "❌ Удален: $object"
  done
  echo "✅ Бакет очищен!"
else
  echo "✅ Бакет уже пуст!"
fi

# 3️⃣ **Загрузка файлов в Yandex Object Storage с правильным Content-Type**
echo "Загрузка файлов в бакет Yandex Cloud ($YANDEX_BUCKET)..."
for file in $(find build/web -type f); do
  RELATIVE_PATH=${file#build/web/}  # Убираем build/web из пути

  # Определение Content-Type
  case "${file##*.}" in
    html) CONTENT_TYPE="text/html" ;;
    js) CONTENT_TYPE="application/javascript" ;;
    css) CONTENT_TYPE="text/css" ;;
    json) CONTENT_TYPE="application/json" ;;
    png) CONTENT_TYPE="image/png" ;;
    jpg|jpeg) CONTENT_TYPE="image/jpeg" ;;
    svg) CONTENT_TYPE="image/svg+xml" ;;
    ico) CONTENT_TYPE="image/x-icon" ;;
    wasm) CONTENT_TYPE="application/wasm" ;;
    *) CONTENT_TYPE="application/octet-stream" ;;  # По умолчанию
  esac

  # Загрузка файла
  yc storage object upload --bucket "$YANDEX_BUCKET" \
    --name "$RELATIVE_PATH" \
    --source "$file" \
    --content-type "$CONTENT_TYPE"

  echo "✅ Загружен: $RELATIVE_PATH ($CONTENT_TYPE)"
done

echo "🎉 Деплой завершён!"
