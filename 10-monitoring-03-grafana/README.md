# Домашнее задание к занятию 14 «Средство визуализации Grafana» - Леонид Хорошев

## Задание повышенной сложности

**При решении задания 1** не используйте директорию [help](./help) для сборки проекта. Самостоятельно разверните grafana, где в роли источника данных будет выступать prometheus, а сборщиком данных будет node-exporter:

- grafana;
- prometheus-server;
- prometheus node-exporter.

За дополнительными материалами можете обратиться в официальную документацию grafana и prometheus.

В решении к домашнему заданию также приведите все конфигурации, скрипты, манифесты, которые вы 
использовали в процессе решения задания.

**При решении задания 3** вы должны самостоятельно завести удобный для вас канал нотификации, например, Telegram или email, и отправить туда тестовые события.

В решении приведите скриншоты тестовых событий из каналов нотификаций.

## Обязательные задания

### Задание 1

1. Используя директорию [help](./help) внутри этого домашнего задания, запустите связку prometheus-grafana.
```
cd 10-monitoring-03-grafana/help
docker-compose up
docker ps -a
```
![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/10-monitoring-03-grafana/screenshots/graf1.png)

Дополнение - для корректного запуска `prometheus` и `nodeexporter` в файл `docker-compose.yml` внесены изменения, а именно прокинуты порты для данных сервисов:
prometheus:
```
ports:
  - 9090:9090
```
nodeexporter:
```
ports:
  - 9100:9100
```

2. Зайдите в веб-интерфейс grafana, используя авторизационные данные, указанные в манифесте docker-compose.

![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/10-monitoring-03-grafana/screenshots/graf2.png)

3. Подключите поднятый вами prometheus, как источник данных.

![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/10-monitoring-03-grafana/screenshots/graf3.png)


## Задание 2

Изучите самостоятельно ресурсы:

1. [PromQL tutorial for beginners and humans](https://valyala.medium.com/promql-tutorial-for-beginners-9ab455142085).
2. [Understanding Machine CPU usage](https://www.robustperception.io/understanding-machine-cpu-usage).
3. [Introduction to PromQL, the Prometheus query language](https://grafana.com/blog/2020/02/04/introduction-to-promql-the-prometheus-query-language/).

Создайте Dashboard и в ней создайте Panels:

- утилизация CPU для nodeexporter (в процентах, 100-idle);
```
avg without (cpu)(irate(node_cpu_seconds_total{job="nodeexporter",mode="idle"}[1m]))
```
- CPULA 1/5/15 (CPU load average за 1, 5 и 15 минут);
```
node_load1{job="nodeexporter"}
node_load5{job="nodeexporter"}
node_load15{job="nodeexporter"}
```
- количество свободной оперативной памяти;
```
node_memory_MemFree_bytes{job='nodeexporter'}
```
- количество места на файловой системе.
```
node_filesystem_avail_bytes{instance="nodeexporter:9100", job="nodeexporter", mountpoint="/"}
```
Получившийся дашборд

![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/10-monitoring-03-grafana/screenshots/graf4.png)

## Задание 3

1. Создайте для каждой Dashboard подходящее правило alert — можно обратиться к первой лекции в блоке «Мониторинг».
2. В качестве решения задания приведите скриншот вашей итоговой Dashboard.

Для выполнения задания и удобства восприятия информации внешний вид панели был изменен изменен:

![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/10-monitoring-03-grafana/screenshots/graf5.png)

## Задание 4

1. Сохраните ваш Dashboard.Для этого перейдите в настройки Dashboard, выберите в боковом меню «JSON MODEL». Далее скопируйте отображаемое json-содержимое в отдельный файл и сохраните его.
2. В качестве решения задания приведите листинг этого файла.

[Dachbord_1](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/10-monitoring-03-grafana/Dashbord_1.json)

---
