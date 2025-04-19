#!/bin/bash

# Создаем директорию для скриптов, если она не существует
mkdir -p web/tflite

# Скачиваем необходимые скрипты
cd web/tflite

# Скачиваем tf-core.js
curl -O https://cdn.jsdelivr.net/npm/@tensorflow/tfjs-core@4.11.0/dist/tf-core.js

# Скачиваем tf-tflite.min.js
curl -O https://cdn.jsdelivr.net/npm/@tensorflow/tfjs-tflite@0.0.1-alpha.10/dist/tf-tflite.min.js

# Скачиваем tf-backend-cpu.js
curl -O https://cdn.jsdelivr.net/npm/@tensorflow/tfjs-backend-cpu@4.11.0/dist/tf-backend-cpu.js

cd ../..

echo "TFLite Web scripts downloaded successfully!" 