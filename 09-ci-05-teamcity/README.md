![2024-03-24_15-24-52](https://github.com/LeonidKhoroshev/mnt-homeworks/assets/114744186/3a2a782b-3216-4dda-b55b-9a41f3a8bcd7)# Домашнее задание к занятию 11 «Teamcity» - Леонид Хорошев

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

![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-05-teamcity/screenshots/team15.png)

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

![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-05-teamcity/screenshots/team16.png)

10. Напишите новый метод для класса Welcomer: метод должен возвращать произвольную реплику, содержащую слово `hunter`.

Реплику следующего содержания добавим в файл [Welcomer.java](https://github.com/LeonidKhoroshev/example-teamcity/blob/feature/add_reply/src/main/java/plaindoll/Welcomer.java):

```
 public String sayByeHunter(){
                 return "Goodbye, hunter!";
	}
```

11. Дополните тест для нового метода на поиск слова `hunter` в новой реплике.

Тест прописываем в файле [WelcomerTest.java](https://github.com/LeonidKhoroshev/example-teamcity/blob/feature/add_reply/src/test/java/plaindoll/WelcomerTest.java)

```
 @Test
	public void welcomersayByeHunter(){
		assertThat(welcomer.sayByeHunter(), containsString("hunter"));
	}
```

12. Сделайте push всех изменений в новую ветку репозитория.

```
git commit -m "hunter"
git push https://github.com/LeonidKhoroshev/example-teamcity feature/add_reply
```

13. Убедитесь, что сборка самостоятельно запустилась, тесты прошли успешно.

![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-05-teamcity/screenshots/team17.png)

14. Внесите изменения из произвольной ветки `feature/add_reply` в `master` через `Merge`.

```
git checkout master
git merge feature/add_reply
git push https://github.com/LeonidKhoroshev/example-teamcity master
```

15. Убедитесь, что нет собранного артефакта в сборке по ветке `master`.

В нашем хранилище nexus уже есть собранные артефакты по результатам выполнения п.7 данного домашнего задания

![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-05-teamcity/screenshots/team18.png) 

Чтобы не запутаться, можно изменить номер (версию) релиза, для этого отредактируем файл [pom.xml](https://github.com/LeonidKhoroshev/example-teamcity/blob/master/pom.xml)

```
<version>0.0.3</version>
```

16. Настройте конфигурацию так, чтобы она собирала `.jar` в артефакты сборки.

В том же файле [pom.xml](https://github.com/LeonidKhoroshev/example-teamcity/blob/master/pom.xml) проверяем, что для артефакта задано требуемое расширение:
```
<packaging>jar</packaging>
```

17. Проведите повторную сборку мастера, убедитесь, что сбора прошла успешно и артефакты собраны.

![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-05-teamcity/screenshots/team20.png) 
![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-05-teamcity/screenshots/team19.png) 

18. Проверьте, что конфигурация в репозитории содержит все настройки конфигурации из teamcity

Директория [.teamcity](https://github.com/LeonidKhoroshev/example-teamcity/tree/master/.teamcity/ExampleTeamcity)

19. В ответе пришлите ссылку на репозиторий.

Репозиторий [example-teamcity](https://github.com/LeonidKhoroshev/example-teamcity/tree/master)

---
