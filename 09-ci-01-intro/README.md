![2024-02-27_14-32-49](https://github.com/LeonidKhoroshev/mnt-homeworks/assets/114744186/cb5f1af9-2c29-4a60-8b69-8caf35fd9de4)# Домашнее задание к занятию 7 «Жизненный цикл ПО» - Леонид Хорошев

## Подготовка к выполнению

1. Получить бесплатную версию Jira - https://www.atlassian.com/ru/software/jira/work-management/free (скопируйте ссылку в адресную строку). Вы можете воспользоваться любым(в том числе бесплатным vpn сервисом) если сайт у вас недоступен. Кроме того вы можете скачать [docker образ](https://hub.docker.com/r/atlassian/jira-software/#) и запустить на своем хосте self-managed версию jira.
2. Настроить её для своей команды разработки.
3. Создать доски Kanban и Scrum.
4. [Дополнительные инструкции от разработчика Jira](https://support.atlassian.com/jira-cloud-administration/docs/import-and-export-issue-workflows/).

## Основная часть

Необходимо создать собственные workflow для двух типов задач: bug и остальные типы задач. Задачи типа bug должны проходить жизненный цикл:

1. Open -> On reproduce.
2. On reproduce -> Open, Done reproduce.
3. Done reproduce -> On fix.
4. On fix -> On reproduce, Done fix.
5. Done fix -> On test.
6. On test -> On fix, Done.
7. Done -> Closed, Open.

![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-01-intro/screenshots/jira1.png)

Остальные задачи должны проходить по упрощённому workflow:

1. Open -> On develop.
2. On develop -> Open, Done develop.
3. Done develop -> On test.
4. On test -> On develop, Done.
5. Done -> Closed, Open.

![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-01-intro/screenshots/jira2.png)

**Что нужно сделать**

1. Создайте [задачу с типом bug](https://khoroshevlv.atlassian.net/browse/H01KB-2?atlOrigin=eyJpIjoiZDRkYTRjZDliYzU5NDk1Zjg4NGE0M2E3MDZlODIzZjkiLCJwIjoiaiJ9), попытайтесь провести его по всему [workflow до Done](https://khoroshevlv.atlassian.net/jira/software/projects/H01KB/boards/1?atlOrigin=eyJpIjoiYjEzMTk1YmM2YjUxNDBlZTlmMjI5MTcyZDIyZTI1YmUiLCJwIjoiaiJ9).

![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-01-intro/screenshots/jira3.png)

2. Создайте задачу с типом [epic](https://khoroshevlv.atlassian.net/browse/H01KB11-1), к ней привяжите несколько задач с типом [task](https://khoroshevlv.atlassian.net/browse/H01KB11-2), проведите их по всему workflow до Done.

![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-01-intro/screenshots/jira4.png)

3. При проведении обеих задач по статусам используйте kanban. 
4. Верните задачи в статус Open.

![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-01-intro/screenshots/jira5.png)
![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-01-intro/screenshots/jira6.png)
 
5. Перейдите в Scrum, запланируйте новый спринт, состоящий из задач эпика и одного бага, стартуйте спринт, проведите задачи до состояния Closed. Закройте спринт.
6. Если всё отработалось в рамках ожидания — выгрузите схемы workflow для импорта в XML. Файлы с workflow и скриншоты workflow приложите к решению задания.

---
