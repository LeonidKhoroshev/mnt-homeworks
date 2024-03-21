# Домашнее задание к занятию 15 «Система сбора логов Elastic Stack» - Леонид Хорошев

## Дополнительные ссылки

При выполнении задания используйте дополнительные ресурсы:

- [поднимаем elk в docker](https://www.elastic.co/guide/en/elastic-stack-get-started/current/get-started-docker.html);
- [поднимаем elk в docker с filebeat и docker-логами](https://www.sarulabs.com/post/5/2019-08-12/sending-docker-logs-to-elasticsearch-and-kibana-with-filebeat.html);
- [конфигурируем logstash](https://www.elastic.co/guide/en/logstash/current/configuration.html);
- [плагины filter для logstash](https://www.elastic.co/guide/en/logstash/current/filter-plugins.html);
- [конфигурируем filebeat](https://www.elastic.co/guide/en/beats/libbeat/5.3/config-file-format.html);
- [привязываем индексы из elastic в kibana](https://www.elastic.co/guide/en/kibana/current/index-patterns.html);
- [как просматривать логи в kibana](https://www.elastic.co/guide/en/kibana/current/discover.html);
- [решение ошибки increase vm.max_map_count elasticsearch](https://stackoverflow.com/questions/42889241/how-to-increase-vm-max-map-count).

В процессе выполнения в зависимости от системы могут также возникнуть не указанные здесь проблемы.

Используйте output stdout filebeat/kibana и api elasticsearch для изучения корня проблемы и её устранения.

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

Перейдите в меню просмотра логов в kibana (Discover) и самостоятельно изучите, как отображаются логи и как производить поиск по логам.

В манифесте директории help также приведенно dummy-приложение, которое генерирует рандомные события в stdout-контейнера.
Эти логи должны порождать индекс logstash-* в elasticsearch. Если этого индекса нет — воспользуйтесь советами и источниками из раздела «Дополнительные ссылки» этого задания.
 
---

### Как оформить решение задания

Выполненное домашнее задание пришлите в виде ссылки на .md-файл в вашем репозитории.

---

 
