# Домашнее задание к занятию 15 «Система сбора логов Elastic Stack» - Леонид Хорошев


## Подготовка к выполнению домашнего задания

Домашнее задание выполнено на ВМ Alma9, развернутой в Яндекс облаке

![Alt_test](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/10-monitoring-04-elk/screenshots/ELK0.png)

Стек поднят с применением файлов директории [help](./help), в файле `docker-compose.yml` выполнены следующие изменения:
- закомментирован контейнер `some_application`, так как `python3.9` уже установлен в нашей ОС
- актуализированы версии программных продуктов `elasticsearch`, `logstash`, `kibana` и `filebeat` с `8.7.0` до `8.12.2`.

## Задание 1

Вам необходимо поднять в докере и связать между собой:

- elasticsearch (hot и warm ноды);
- logstash;
- kibana;
- filebeat.

Logstash следует сконфигурировать для приёма по tcp json-сообщений.

Filebeat следует сконфигурировать для отправки логов docker вашей системы в logstash.

В директории [help](./help) находится манифест docker-compose и конфигурации filebeat/logstash для быстрого 
выполнения этого задания.

Результатом выполнения задания должны быть:

- скриншот `docker ps` через 5 минут после старта всех контейнеров (их должно быть 5);

![Alt_test](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/10-monitoring-04-elk/screenshots/ELK1.png)

- скриншот интерфейса kibana;

![Alt_test](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/10-monitoring-04-elk/screenshots/ELK2.png)

- docker-compose манифест (если вы не использовали директорию help);
- ваши yml-конфигурации для стека (если вы не использовали директорию help).

## Задание 2

Перейдите в меню [создания index-patterns  в kibana](http://localhost:5601/app/management/kibana/indexPatterns/create) и создайте несколько index-patterns из имеющихся.

Поскольку в нашем случае установлена версия `8.12.2`, в которой меню немного изменено, то index-pattern создается в меню [data-view](https://www.elastic.co/guide/en/kibana/8.12/data-views.html).

![Alt_test](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/10-monitoring-04-elk/screenshots/ELK3.png)
![Alt_test](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/10-monitoring-04-elk/screenshots/ELK6.png)


Перейдите в меню просмотра логов в kibana (Discover) и самостоятельно изучите, как отображаются логи и как производить поиск по логам.

![Alt_test](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/10-monitoring-04-elk/screenshots/ELK5.png)


 
---
