# Телеметрия Citroen C4

База под показания датчиков машины. Данные снимает ноутбук через Lexia 3
(репозиторий `c4-can`), копит локально в SQLite и досылает сюда - поэтому
поездки вдали от дома не теряются.

## Секреты

Оба секрета уже запечатаны и лежат рядом (`sealed-secret-*.yaml`) - расшифровать
их может только этот кластер. Роль `grafana_reader` заведена с тем же паролем,
что и в life-dashboard, поэтому переменная `$GRAFANA_READER_PASSWORD` в деплое
Grafana работает для обоих источников и менять его не требуется.

Пароль владельца базы при необходимости достаётся из кластера:

    kubectl get secret citroen-postgres-credentials -n citroen \
      -o jsonpath='{.data.password}' | base64 -d

## Заливка с ноутбука

    export CAR_PG="postgresql://car:ПАРОЛЬ@<хост>:5432/car"
    ./.venv/bin/python sync.py

Схему создаёт сам sync.py. Досылка идемпотентная: помечает строки только после
успешной вставки, дубликаты отсекаются уникальным индексом.

## Запросы для панелей

    SELECT r.ts AS "time", r.value
    FROM reading r JOIN param p ON p.id = r.param_id
    WHERE p.name = 'MP_REGIME_MOTEUR_AFFICHE' AND $__timeFilter(r.ts)
    ORDER BY 1;
