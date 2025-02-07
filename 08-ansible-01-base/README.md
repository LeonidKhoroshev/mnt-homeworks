# Домашнее задание к занятию 1 «Введение в Ansible» - Леонид Хорошев

## Подготовка к выполнению

1. Установите Ansible версии 2.10 или выше.
   ![Alt text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/08-ansible-01-base/screenshots/ansible1.png)
2. Создайте свой публичный репозиторий на GitHub с произвольным именем.
3. Скачайте [Playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.
   ```
   mkdir ansible
   cd ansible
   git init
   git pull https://github.com/LeonidKhoroshev/mnt-homeworks
   ```

## Основная часть

1. Попробуйте запустить playbook на окружении из `test.yml`, зафиксируйте значение, которое имеет факт `some_fact` для указанного хоста при выполнении playbook.
```
ansible-playbook -i inventory/test.yml site.yml
```
![Alt text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/08-ansible-01-base/screenshots/ansible2.png)

2. Найдите файл с переменными (group_vars), в котором задаётся найденное в первом пункте значение, и поменяйте его на `all default fact`.
```
nano  group_vars/all/examp.yml
---
  some_fact: all default fact
ansible-playbook -i inventory/test.yml site.yml
```
![Alt text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/08-ansible-01-base/screenshots/ansible3.png)

3. Воспользуйтесь подготовленным (используется `docker`) или создайте собственное окружение для проведения дальнейших испытаний.
```
docker run --name centos7 -d pycontribs/centos:7 sleep 360
docker run --name ubuntu -d pycontribs/ubuntu sleep 360
docker ps -a
```
Примечание - команда sleep передается в контейнеры, чтобы они не переходили мгновенно в статус exited

![Alt text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/08-ansible-01-base/screenshots/ansible5.png)

4. Проведите запуск playbook на окружении из `prod.yml`. Зафиксируйте полученные значения `some_fact` для каждого из `managed host`.
```
ansible-playbook -i inventory/prod.yml site.yml
```
![Alt text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/08-ansible-01-base/screenshots/ansible4.png)

5. Добавьте факты в `group_vars` каждой из групп хостов так, чтобы для `some_fact` получились значения: для `deb` — `deb default fact`, для `el` — `el default fact`.
```
nano  group_vars/deb/examp.yml
---
  some_fact: "deb default fact"
```

```
nano  group_vars/el/examp.yml
---
  some_fact: "el default fact"

```

6.  Повторите запуск playbook на окружении `prod.yml`. Убедитесь, что выдаются корректные значения для всех хостов.

```
ansible-playbook -i inventory/prod.yml site.yml
```
![Alt text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/08-ansible-01-base/screenshots/ansible6.png)

7. При помощи `ansible-vault` зашифруйте факты в `group_vars/deb` и `group_vars/el` с паролем `netology`.

```
ansible-vault encrypt playbook/group_vars/deb/examp.yml
ansible-vault encrypt playbook/group_vars/el/examp.yml
```
![Alt text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/08-ansible-01-base/screenshots/ansible7.png)

8. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь в работоспособности.

```
ansible-playbook -i inventory/prod.yml site.yml --ask-vault-pass
```
![Alt text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/08-ansible-01-base/screenshots/ansible8.png)

9. Посмотрите при помощи `ansible-doc` список плагинов для подключения. Выберите подходящий для работы на `control node`.

Список подключаемых модулей:
```
ansible-doc -t connection -l
```
![Alt text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/08-ansible-01-base/screenshots/ansible9.png)

10. В `prod.yml` добавьте новую группу хостов с именем  `local`, в ней разместите localhost с необходимым типом подключения.
```
nano inventory/prod.yml
---
  local:
    hosts:
      localhost:
        ansible_connection: local
```
![Alt text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/08-ansible-01-base/screenshots/ansible11.png)

11. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь, что факты `some_fact` для каждого из хостов определены из верных `group_vars`.

![Alt text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/08-ansible-01-base/screenshots/ansible10.png)


## Необязательная часть

1. При помощи `ansible-vault` расшифруйте все зашифрованные файлы с переменными.
```
ansible-vault decrypt playbook/group_vars/deb/examp.yml
ansible-vault decrypt playbook/group_vars/el/examp.yml
```
![Alt text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/08-ansible-01-base/screenshots/ansible12.png)

2. Зашифруйте отдельное значение `PaSSw0rd` для переменной `some_fact` паролем `netology`. Добавьте полученное значение в `group_vars/all/exmp.yml`.

Добавляем занчение
```
nano group_vars/all/exmp.yml
---
  some_fact: all default fact
  some_fact: PaSSw0rd
```

Зашифровываем
```
ansible-vault encrypt_string PaSSw0rd --ask-vault-pass
```
![Alt text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/08-ansible-01-base/screenshots/ansible13.png)

3. Запустите `playbook`, убедитесь, что для нужных хостов применился новый `fact`.

```
ansible-playbook -i inventory/prod.yml site.yml --ask-vault-pass
```
![Alt text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/08-ansible-01-base/screenshots/ansible14.png)

4. Добавьте новую группу хостов `fedora`, самостоятельно придумайте для неё переменную. В качестве образа можно использовать [этот вариант](https://hub.docker.com/r/pycontribs/fedora).

Запускаем предложенный контейнер
```
docker run --name fedora -d pycontribs/fedora sleep 360
```
Добавляем переменную
```
mkdir fedora
nano fedora/examp.yml
--
  some_fact: "fedora default fact"
```
Добавляем хост в prod окружение
```
nano prod.yml

  fedora:
    hosts:
      fedora:
        ansible_connection: docker

```

Запускаем playbook
```
ansible-playbook -i inventory/prod.yml site.yml --ask-vault-pass
```
![Alt text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/08-ansible-01-base/screenshots/ansible15.png)


