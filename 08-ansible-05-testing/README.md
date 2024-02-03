# Домашнее задание к занятию 5 «Тестирование roles» - Хорошев Леонид

## Подготовка к выполнению

1. Установите molecule: `pip3 install "molecule==3.5.2"` и драйвера `pip3 install molecule_docker molecule_podman`.
2. Выполните `docker pull aragast/netology:latest` —  это образ с podman, tox и несколькими пайтонами (3.7 и 3.9) внутри.

## Основная часть

Ваша цель — настроить тестирование ваших ролей. 

Задача — сделать сценарии тестирования для vector. 

Ожидаемый результат — все сценарии успешно проходят тестирование ролей.

### Molecule

1. Запустите  `molecule test -s centos_7` внутри корневой директории clickhouse-role, посмотрите на вывод команды. Данная команда может отработать с ошибками, это нормально. Наша цель - посмотреть как другие в реальном мире используют молекулу.
 ![Alt text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/08-ansible-05-testing/screenshots/test1.png)

2. Перейдите в каталог с ролью vector-role и создайте сценарий тестирования по умолчанию при помощи `molecule init scenario --driver-name docker`.
 ![Alt text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/08-ansible-05-testing/screenshots/test2.png)

3. Добавьте несколько разных дистрибутивов (centos:8, ubuntu:latest) для инстансов и протестируйте роль, исправьте найденные ошибки, если они есть.
```
---
dependency:
  name: galaxy
driver:
  name: docker
platforms:
  - name: centos_8
    image: docker.io/pycontribs/centos:8
    pre_build_image: true
  - name: ubuntu_latest
    image: docker.io/pycontribs/ubuntu:latest
    pre_build_image: true
provisioner:
  name: ansible
verifier:
  name: ansible
```
Результаты первого тестирования ролия Vector-role:
```
molecule test
```
![Alt text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/08-ansible-05-testing/screenshots/test3.png)
Для исправления данной ошибки `couldn't resolve module/action 'community.docker.docker_container'` установлены следующие коллекции:
```
ansible-galaxy collection install community.docker
ansible-galaxy collection install community.general
```
Запускаем повторно `molecule test`
![Alt text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/08-ansible-05-testing/screenshots/test4.png)
Получаем проблему с отсутвием теста `equalto`, для исправления обновляем версии ansible (с core 2.13 до 2.16.2) и python (c 3.6 до 3.10).

Тестируем `molecule test`
![Alt text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/08-ansible-05-testing/screenshots/test5.png)
![Alt text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/08-ansible-05-testing/screenshots/test6.png)
![Alt text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/08-ansible-05-testing/screenshots/test7.png)

4. Добавьте несколько assert в verify.yml-файл для  проверки работоспособности vector-role (проверка, что конфиг валидный, проверка успешности запуска и др.).
здаем файл verify.yml
```
- name: Verify
  hosts: all
  gather_facts: true
  tasks:
    - name: Include vector role
      include_role:
        name: vector
    - name: Check vector service
      assert:
        that: vector_pid.stdout != 0
        success_msg: "Service is running"
        fail_msg: "Service not running"
    - name: Check vector config
      assert:
        that: valid_config.rc == 0
        success_msg: "Config valid"
        fail_msg: "Config not valid"
```

Корректируем converge.yml:
```
---
- name: Converge
  hosts: all
  tasks:
    - name: "Include vector"
      include_role:
        name: vector-role
```

Проверяем `molecule test`
![Alt text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/08-ansible-05-testing/screenshots/molecule8.png)
5. Запустите тестирование роли повторно и проверьте, что оно прошло успешно.
![Alt text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/08-ansible-05-testing/screenshots/molecule9.png)
6. Добавьте новый тег на коммит с рабочим сценарием в соответствии с семантическим версионированием.

### Tox

1. Добавьте в директорию с vector-role файлы из [директории](./example).
2. Запустите `docker run --privileged=True -v <path_to_repo>:/opt/vector-role -w /opt/vector-role -it aragast/netology:latest /bin/bash`, где path_to_repo — путь до корня репозитория с vector-role на вашей файловой системе.
```
docker run --privileged=True -v /root/netology/roles/vector-role:/opt/vector-role -w /opt/vector-role -it aragast/netology:latest /bin/bash
```
3. Внутри контейнера выполните команду `tox`, посмотрите на вывод.
![Alt text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/08-ansible-05-testing/screenshots/test10.png)
Вывод показал
```
{'driver': [{'name': ['unallowed value docker']}]}
ERROR: InvocationError for command /opt/vector-role/.tox/py37-ansible30/bin/molecule test --destroy always (exited with code 1)
```
что достаточно логично, так как в запущенном нами контейнере отсутствует Docker.

5. Создайте облегчённый сценарий для `molecule` с драйвером `molecule_podman`. Проверьте его на исполнимость.

Корректируем файл  tox-requirements.txt для замены драйвера с docker на podman
```
selinux
ansible-lint==5.1.3
yamllint==1.33.0
lxml
molecule==6.22.2
molecule_podman
jmespath
```
Создаем сценарий light
```
molecule init scenario --driver-name docker light
```

6. Пропишите правильную команду в `tox.ini`, чтобы запускался облегчённый сценарий.
```
[tox]
minversion = 1.8
basepython = python3.6
envlist = py{37,39}-ansible{210,30}
skipsdist = true

[testenv]
passenv = *
deps =
    -r tox-requirements.txt
    ansible210: ansible<3.0
    ansible30: ansible<3.1
commands =
    {posargs:molecule test -s light}
```

8. Запустите команду `tox`. Убедитесь, что всё отработало успешно.
```
docker run --privileged=True -v /root/netology/roles/vector-role:/opt/vector-role -w /opt/vector-role -it aragast/netology:latest /bin/bash
tox
```
![Alt text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/08-ansible-05-testing/screenshots/test11.png)
Сценарий отрабатывает, по вектор  с указанными зависимостями не стартует.

9. Добавьте новый тег на коммит с рабочим сценарием в соответствии с семантическим версионированием.

После выполнения у вас должно получится два сценария molecule и один tox.ini файл в репозитории. Не забудьте указать в ответе теги решений Tox и Molecule заданий. В качестве решения пришлите ссылку на  ваш репозиторий и скриншоты этапов выполнения задания.
