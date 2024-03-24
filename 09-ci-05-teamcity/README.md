# Домашнее задание к занятию 11 «Teamcity» - Леонид Хорошев

## Подготовка к выполнению

1. В Yandex Cloud создайте новый инстанс (4CPU4RAM) на основе образа `jetbrains/teamcity-server`.

В Yandex cloud созданы сразу `teamcity-server`, `teamcity-agent` и ВМ `nexus`.

![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-05-teamcity/screenshots/team1.png)

2. Дождитесь запуска teamcity, выполните первоначальную настройку.
   
![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-05-teamcity/screenshots/team4.png)

3. Создайте ещё один инстанс (2CPU4RAM) на основе образа `jetbrains/teamcity-agent`. Пропишите к нему переменную окружения `SERVER_URL: "http://<teamcity_url>:8111"`.

4. Авторизуйте агент.

![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-05-teamcity/screenshots/team5.png)

5. Сделайте fork [репозитория](https://github.com/aragastmatb/example-teamcity).

[Fork репозитория example-teamcity](https://github.com/LeonidKhoroshev/example-teamcity)

6. Создайте VM (2CPU4RAM) и запустите [playbook](./infrastructure).

Для запуска плейбука в inventory-файле прописаны ip и имя пользователя ВМ `nexus`.
```
---
all:
  hosts:
    nexus-01:
      ansible_host: 178.154.223.56
  children:
    nexus:
      hosts:
        nexus-01:
  vars:
    ansible_connection_type: paramiko
    ansible_user: leo
```

Запускаем плейбук

```
 ansible-playbook site.yml -i inventory/cicd/hosts.yml
```
![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-05-teamcity/screenshots/team2.png)
![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-05-teamcity/screenshots/team3.png)



## Основная часть

1. Создайте новый проект в teamcity на основе fork.

![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-05-teamcity/screenshots/team6.png)

2. Сделайте autodetect конфигурации.

![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-05-teamcity/screenshots/team7.png)

3. Сохраните необходимые шаги, запустите первую сборку master.

![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-05-teamcity/screenshots/team8.png)

4. Поменяйте условия сборки: если сборка по ветке `master`, то должен происходит `mvn clean deploy`, иначе `mvn clean test`.


5. Для deploy будет необходимо загрузить [settings.xml](./teamcity/settings.xml) в набор конфигураций maven у teamcity, предварительно записав туда креды для подключения к nexus.

![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-05-teamcity/screenshots/team14.png)

6. В pom.xml необходимо поменять ссылки на репозиторий и nexus.

Прописан url созданной нами ВМ `nexus`
```
<repository>
				<id>nexus</id>
				<url>http://178.154.223.56:8081/repository/maven-releases</url>
```

7. Запустите сборку по master, убедитесь, что всё прошло успешно и артефакт появился в nexus.

Вносим необходимые изменения в шаг сборки `maven`, (прописываем clean deploy при условии сборки по ветке `master`) 

![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-05-teamcity/screenshots/team9.png)

Добавляем settings.xml

![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-05-teamcity/screenshots/team10.png)

После сборки проверяем репозиторий в Nexus:

![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-05-teamcity/screenshots/team11.png)

![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-05-teamcity/screenshots/team12.png)


8. Мигрируйте `build configuration` в репозиторий.

![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-05-teamcity/screenshots/team13.png)

После внесения изменений (в скриншоте) наша конфигурация доступна в [репозитории](https://github.com/LeonidKhoroshev/example-teamcity/tree/master/.teamcity/ExampleTeamcity).


9. Создайте отдельную ветку `feature/add_reply` в репозитории.
10. Напишите новый метод для класса Welcomer: метод должен возвращать произвольную реплику, содержащую слово `hunter`.
11. Дополните тест для нового метода на поиск слова `hunter` в новой реплике.
12. Сделайте push всех изменений в новую ветку репозитория.
13. Убедитесь, что сборка самостоятельно запустилась, тесты прошли успешно.
14. Внесите изменения из произвольной ветки `feature/add_reply` в `master` через `Merge`.
15. Убедитесь, что нет собранного артефакта в сборке по ветке `master`.
16. Настройте конфигурацию так, чтобы она собирала `.jar` в артефакты сборки.
17. Проведите повторную сборку мастера, убедитесь, что сбора прошла успешно и артефакты собраны.
18. Проверьте, что конфигурация в репозитории содержит все настройки конфигурации из teamcity.
19. В ответе пришлите ссылку на репозиторий.

---

### Как оформить решение задания

Выполненное домашнее задание пришлите в виде ссылки на .md-файл в вашем репозитории.

---
