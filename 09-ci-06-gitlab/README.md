# Домашнее задание к занятию 12 «GitLab» - Леонид Хорошев

## Подготовка к выполнению

Готовим нашу инфраструктуру в Yandex cloud 

Создаем 2 виртуальные машины (`Gitlab` сервер и `Alma`, для установки раннера)

![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-06-gitlab/screenshots/git1.png)

Далее устанавливаем на ВМ `Alma linux` `Gitlab runner` по [инструкции](https://docs.gitlab.com/runner/install/linux-repository.html)

Регистрируем раннер:

```
gitlab-runner register
Enter the GitLab instance URL (for example, https://gitlab.com/):
http://62.84.119.13/
Enter the registration token:
GR13489414kx7KhxzVC6ydXAt7KzF
Enter a description for the runner:
[runner.ru-central1.internal]: my_educational_runner
Enter tags for the runner (comma-separated):
linux
Enter optional maintenance note for the runner:
use only for homework
```

Проверяем, что получилось:

```
cat /etc/gitlab-runner/config.toml
concurrent = 1
check_interval = 0
connection_max_age = "15m0s"
shutdown_timeout = 0

[session_server]
  session_timeout = 1800

[[runners]]
  name = "my_educational_runner"
  url = "http://62.84.119.13/"
  id = 1
  token = "U2WEL8y8NLZXNsHN1LBw"
  token_obtained_at = 2024-03-28T18:29:30Z
  token_expires_at = 0001-01-01T00:00:00Z
  executor = "shell"
  [runners.cache]
    MaxUploadedArchiveSize = 0
```

![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-06-gitlab/screenshots/git2.png)

## Основная часть

### DevOps

В репозитории содержится код проекта на Python. Проект — RESTful API сервис. Ваша задача — автоматизировать сборку образа с выполнением python-скрипта:

Через pipeline-editor создаем наш pipeline в файле `.gitlab-ci.yml` следующего содержания:

```
stages:
    - build
    - deploy
image: docker:20.10.5
services:
    - docker:20.10.5-dind
builder:
    stage: build
    script:
        - docker build -t $CI_REGISTRY/$CI_PROJECT_PATH/hello:gitlab-$CI_COMMIT_SHORT_SHA .
    except:
        - main
deployer:
    stage: deploy
    script:
        - docker build -t $CI_REGISTRY/$CI_PROJECT_PATH/hello:gitlab-$CI_COMMIT_SHORT_SHA .
        - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
        - docker push $CI_REGISTRY/$CI_PROJECT_PATH/hello:gitlab-$CI_COMMIT_SHORT_SHA
    only:
        - main
```

![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-06-gitlab/screenshots/git7.png)

Условия сборки:

1. Образ собирается на основе [centos:7](https://hub.docker.com/_/centos?tab=tags&page=1&ordering=last_updated).
2. Python версии не ниже 3.7.
3. Установлены зависимости: `flask` `flask-jsonpify` `flask-restful`.
4. Создана директория `/python_api`.
5. Скрипт из репозитория размещён в /python_api.
6. Точка вызова: запуск скрипта.
7. При комите в любую ветку должен собираться docker image с форматом имени hello:gitlab-$CI_COMMIT_SHORT_SHA . Образ должен быть выложен в Gitlab registry или yandex registry.

Для выполнения условий сборки создадим 2 файла `Dockerfile` и `requirements.txt`.

Dockerfile:
```
FROM centos:7
RUN yum install python3 python3-pip -y
COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt
WORKDIR /python_api
COPY app.py app.py
CMD ["python3", "app.py"]
```

requirements.txt:
```
flask
flask_restful
flask_jsonpify
```

Проверяем результат: сборка прошла, но не сразу, так как необходимо следить, чтобы название репозитория на Gitlab содержало только строчные буквы:
```
invalid argument "registry.gitlab.com/LeonidKhoroshev/netology-example/hello:gitlab-08854f8f" for "-t, --tag" flag: invalid reference format: repository name must be lowercase
See 'docker build --help'.
```

![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-06-gitlab/screenshots/git3.png)

### Product Owner

Вашему проекту нужна бизнесовая доработка: нужно поменять JSON ответа на вызов метода GET `/rest/api/get_info`, необходимо создать Issue в котором указать:

1. Какой метод необходимо исправить.
2. Текст с `{ "message": "Already started" }` на `{ "message": "Running"}`.
3. Issue поставить label: feature.

![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-06-gitlab/screenshots/git6.png)


### Developer

Пришёл новый Issue на доработку, вам нужно:

1. Создать отдельную ветку, связанную с этим Issue.
2. Внести изменения по тексту из задания.
3. Подготовить Merge Request, влить необходимые изменения в `master`, проверить, что сборка прошла успешно.


### Tester

Разработчики выполнили новый Issue, необходимо проверить валидность изменений:

1. Поднять докер-контейнер с образом `python-api:latest` и проверить возврат метода на корректность.
2. Закрыть Issue с комментарием об успешности прохождения, указав желаемый результат и фактически достигнутый.

## Итог

В качестве ответа пришлите подробные скриншоты по каждому пункту задания:

- файл gitlab-ci.yml;
- Dockerfile; 
- лог успешного выполнения пайплайна;
- решённый Issue.

### Важно 
После выполнения задания выключите и удалите все задействованные ресурсы в Yandex Cloud.

