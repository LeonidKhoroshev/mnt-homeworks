# Домашнее задание к занятию 4 «Работа с roles» - Леонид Хорошев

## Подготовка к выполнению

1. * Необязательно. Познакомьтесь с [LightHouse](https://youtu.be/ymlrNlaHzIY?t=929).
2. Создайте два пустых публичных репозитория в любом своём проекте: vector-role и lighthouse-role.
3. Добавьте публичную часть своего ключа к своему профилю на GitHub.

## Основная часть

Ваша цель — разбить ваш playbook на отдельные roles. 

Задача — сделать roles для ClickHouse, Vector и LightHouse и написать playbook для использования этих ролей. 

Ожидаемый результат — существуют три ваших репозитория: два с roles и один с playbook.

**Что нужно сделать**

1. Создайте в старой версии playbook файл `requirements.yml` и заполните его содержимым:

   ```yaml
   ---
     - src: git@github.com:AlexeySetevoi/ansible-clickhouse.git
       scm: git
       version: "1.13"
       name: clickhouse 
   ```

2. При помощи `ansible-galaxy` скачайте себе эту роль.
   ```
   ansible-galaxy install -r requirements.yml
   ```
   ![Alt text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/08-ansible-04-role/screenshots/role1.png)

3. Создайте новый каталог с ролью при помощи `ansible-galaxy role init vector-role`.
![Alt text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/08-ansible-04-role/screenshots/role2.png)

4. На основе tasks из старого playbook заполните новую role. Разнесите переменные между `vars` и `default`.

Переносим таски и хэндлеры по файлам tasks/main.yml и handlers/main.yml
Таски:
```yaml
- name: Get Vector distrib
  ansible.builtin.get_url:
    url: https://packages.timber.io/vector/0.35.0/vector-0.35.0-1.x86_64.rpm
    dest: /home/leo/vector-0.35.0-1.x86_64.rpm
    mode: "0755"
- name: Install Vector
  become: true
  remote_user: leo
  ansible.builtin.copy:
    remote_src: true
    src: "/home/leo/"
    dest: "/usr/bin/"
    mode: "0755"
    owner: root
    group: root
- name: Create Vector directory
  become: true
  ansible.builtin.file:
    path: "/etc/vector"
    state: directory
    mode: "0755"
    owner: root
    group: root
- name: Vector | Template config
  become: true
  ansible.builtin.template:
    src: template/vector.j2
    dest: /etc/vector/vector.yml
    mode: "0755"
    owner: root
    group: root
- name: Vector | Create systemd unit
  become: true
  ansible.builtin.template:
    src: template/vector.j2
    dest: /etc/systemd/system/vector.service
    mode: "0755"
    owner: root
    group: root
  notify: Start Vector
```
Хэндлеры:
```yaml
- name: Start Vector
  remote_user: leo
  become: true
  ansible.builtin.systemd:
    daemon_reload: true
    enabled: false
    name: vector.service
    state: restarted
```
5. Перенести нужные шаблоны конфигов в `templates`.
```
cp template vector.j2 roles/vector-role/templates/vector.j2
```
Конфигурация Vector:
```
sources:
  dummy_logs:
    type: demo_logs
    format: syslog
    interval: 1

sinks:
  clickhouse_logs:
    type: clickhouse
    inputs:
      - dummy_logs
    database: "logs"
    endpoint: "http//192.168.1.184:8123"
    table: "logs_table"
    acknowledgements:
      enabled: false
    healthcheck:
      enabled: false
    compression: gzip
    skip_unknown_fields: true
```
В рамках выполнения задания, помимо vector-role подготовлено еще три роли:
 - [nginx-role](https://github.com/LeonidKhoroshev/nginx.git);
 - [clickhouse-role](https://github.com/LeonidKhoroshev/clickhouse-role);
 - [lighthouse-role](https://github.com/LeonidKhoroshev/lighthouse.git).

6. Опишите в `README.md` обе роли и их параметры. Пример качественной документации ansible role [по ссылке](https://github.com/cloudalchemy/ansible-prometheus).
7. Повторите шаги 3–6 для LightHouse. Помните, что одна роль должна настраивать один продукт.

Разделяем плейбук по установке Lighthouse из предыдущего домашнего задания на таски и хэндлеры, аналогично п.4 (подготовка vector-role)
Таски:
```yaml
- name: Lighthouse | install git
  become: true
  remote_user: leo
  ansible.builtin.yum:
    name: git
    state: present
- name: Lighthouse | Copy from git
  become: true
  ansible.builtin.git:
    repo: "https://github.com/VKCOM/lighthouse.git"
    version: master
    dest: "home/leo/lighthouse"
- name: Lighthouse | Create lighthouse config
  become: true
  ansible.builtin.template:
    src: templates/lighthouse.j2
    dest: /etc/nginx/conf.d/default.conf
    mode: "0755"
  notify: Reload nginx
```
Хэндлеры:
```yaml
---
- name: Reload nginx
  become: true
  remote_user: leo
  ansible.builtin.command: nginx -s reload
```

Аналогичные действия производим и для создания clickhouse-role

Таски:
```yaml
- name: Get clickhouse-common-static distrib
  ansible.builtin.get_url:
    url: https://packages.clickhouse.com/rpm/lts/clickhouse-common-static-23.8.9.54.x86_64.rpm
    dest: /home/leo/clickhouse-common-static-23.8.9.54.x86_64.rpm
    mode: "0755"
- name: Get clickhouse-server distrib
  ansible.builtin.get_url:
    url: https://packages.clickhouse.com/rpm/lts/clickhouse-server-23.8.9.54.x86_64.rpm
    dest: /home/leo/clickhouse-server-23.8.9.54.x86_64.rpm
    mode: "0755"
- name: Get clickhouse-client distrib
  ansible.builtin.get_url:
    url: https://packages.clickhouse.com/rpm/lts/clickhouse-client-23.8.9.54.x86_64.rpm
    dest: /home/leo/clickhouse-client-23.8.9.54.x86_64.rpm
    mode: "0755"
- name: Install clickhouse packages
  become: true
  ansible.builtin.yum:
    name:
      - clickhouse-common-static-23.8.9.54.x86_64.rpm
      - clickhouse-client-23.8.9.54.x86_64.rpm
      - clickhouse-server-23.8.9.54.x86_64.rpm
  notify: Start clickhouse service
- name: Flush handlers
  meta: flush_handlers
- name: Create database
  ansible.builtin.command: "clickhouse-client -q 'create database logs;'"
  register: create_db
  failed_when: create_db.rc != 0 and create_db.rc !=82
  changed_when: create_db.rc == 0
```
Хэндлеры:
```yaml

- name: Start clickhouse service
  become: true
  ansible.builtin.service:
    name: clickhouse-server
    state: restarted
```
8. Выложите все roles в репозитории. Проставьте теги, используя семантическую нумерацию. Добавьте roles в [requirements.yml](https://github.com/LeonidKhoroshev/mnt-homeworks/tree/ansible-04/requirements.yml) в playbook.

9. Переработайте playbook на использование roles. Не забудьте про зависимости LightHouse и возможности совмещения `roles` с `tasks`.
```yaml
---
- name: Install Nginx
  hosts: webservers
  remote_user: leo
  become: true
  roles:
    - nginx-role
- name: Install Clickhouse
  hosts: clickhouse
  remote_user: leo
  become: true
  roles:
    - clickhouse-role
- name: Install Lighthouse
  hosts: lighthouse
  remote_user: leo
  become: true
  roles:
    - lighthouse-role
- name: Install Vector
  hosts: vector
  remote_user: leo
  become: true
  roles:
    - vector-role
```

Проверим, что playbook работает:
- развернем инфраструктуру
```
cd terraform
terrafom apply 
```
![Alt text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/08-ansible-04-role/screenshots/role4.png)
- проверяем inventory файл
```
cat inventory/hosts.cfg

[webservers]

clickhouse ansible_host=178.154.201.44

vector ansible_host=178.154.200.221

lighthouse ansible_host=178.154.200.241

[webservers:vars]
ansible_python=/usr/bin/python3
```
- запускаем плейбук
```
ansible-playbook -i inventory/hosts.cfg playbook_roles.yml
```
![Alt text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/08-ansible-04-role/screenshots/role3.png)

10. Выложите playbook_roles.yml в [репозиторий](https://github.com/LeonidKhoroshev/mnt-homeworks/tree/ansible-04).

11. В ответе дайте ссылки на  репозитории с roles ([nginx](https://github.com/LeonidKhoroshev/nginx.git), [clickhouse](https://github.com/LeonidKhoroshev/clickhouse-role), [lighthouse](https://github.com/LeonidKhoroshev/lighthouse.git), [vector](https://github.com/LeonidKhoroshev/vector.git)) и одну ссылку на репозиторий с [playbook](https://github.com/LeonidKhoroshev/mnt-homeworks/tree/ansible-04).

---
