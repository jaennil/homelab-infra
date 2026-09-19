# Dialogue Insights

Анализ личных переписок. Сервисы живут в репозитории
[dialogue-insights](https://github.com/jaennil/dialogue-insights) и приезжают
Application'ом `dialogue-insights`, который смотрит в `k8s/overlays/production`.
Здесь только то, чем владеет кластер: namespace, база и секреты.

## Что поднимается

- CNPG-кластер `postgres` с тремя базами - `identity`, `telegram`,
  `conversation`. Роли создаются без пароля в `postInitSQL`, пароли им
  выставляет блок `managed.roles` из запечатанных секретов.
- Секреты подключения для сервисов, креды Telegram API и pull-секрет GHCR.

NATS с JetStream приезжает из репозитория приложения вместе с сервисами -
он часть контура импорта, а не инфраструктуры кластера.

## Порядок включения

1. Запечатать секреты по инструкции из `sealed-secrets.yaml.example` -
   получится `dialogue-insights/sealed-secrets.yaml`.
2. Переименовать `apps/dialogue-insights-infra.yaml.disabled` в `.yaml`,
   дождаться, пока CNPG поднимет базу.
3. Переименовать `apps/dialogue-insights.yaml.disabled` в `.yaml`.

Пока секретов нет, оба Application выключены намеренно: без них поды
встанут в `CreateContainerConfigError`, а Argo покажет вечно красное
приложение.

## Telegram через VPN

Коннектор ходит в Telegram только через xray: в деплое задан
`TELEGRAM_PROXY_URL=socks5://xray.proxy.svc.cluster.local:1080`, и TDLib
получает этот адрес через `addProxy` при создании каждой сессии.
