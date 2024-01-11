# Домашнее задание к занятию 2 «Работа с Playbook» - Леонид Хорошев

## Подготовка к выполнению

1. * Необязательно. Изучите, что такое [ClickHouse](https://www.youtube.com/watch?v=fjTNS2zkeBs) и [Vector](https://www.youtube.com/watch?v=CgEhyffisLY).
2. Создайте свой публичный репозиторий на GitHub с произвольным именем или используйте старый.
3. Скачайте [Playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.
4. Подготовьте хосты в соответствии с группами из предподготовленного playbook.

## Основная часть

1. Подготовьте свой inventory-файл `prod.yml` (задание планируется выполнять на одном локальном хосте).
```
nano inventory/prod.yml
---
clickhouse:
  hosts:
    clickhouse-01:
       ansible_connection: local
```
2. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает [vector](https://vector.dev). Конфигурация vector должна деплоиться через template файл jinja2. От вас не требуется использовать все возможности шаблонизатора, просто вставьте стандартный конфиг в template файл. Информация по шаблонам по [ссылке](https://www.dmosk.ru/instruktions.php?object=ansible-nginx-install). не забудьте сделать handler на перезапуск vector в случае изменения конфигурации!

Дополняем существующий плейбук:
```
nano site.yml

- name: Install Vector
  hosts: clickhouse
  handlers:
    - name: Start Vector
      become: true
      ansible.builtin.systemd:
        daemon_reload: true
        enabled: false
        name: vector.service
        state: restarted

  tasks:
    - block:
        - name: Get Vector distrib
          ansible.builtin.get_url:
            url: "https://packages.timber.io/vector/{{ vector_version }}/vector-{{ vector_version }}-{{ vector_os_arch }}-unknown-linux-gnu.tar.gz"
            dest: "{{ vector_workdir }}/vector-{{ vector_version }}-{{ vector_os_arch }}-unknown-linux-gnu.tar.gz"
            mode: "0755"

        - name: Unpack Vector
          ansible.builtin.unarchive:
            remote_src: true
            src: "{{ vector_workdir }}/vector-{{ vector_version }}-{{ vector_os_arch }}-unknown-linux-gnu.tar.gz"
            dest: "{{ vector_workdir }}"

        - name: Install Vector
          become: true
          ansible.builtin.copy:
            remote_src: true
            src: "{{ vector_workdir }}/vector-{{ vector_os_arch }}-unknown-linux-gnu/bin/vector"
            dest: "/usr/bin/"
            mode: "0755"
            owner: root
            group: root

        - name: Create Vector config
          become: true
          ansible.builtin.template:
            remote_src: true
            src: "{{ vector_workdir }}/playbook/template/vector.j2"
            dest: "{{ vector_workdir }}"
            mode: "0755"
            owner: root
            group: root
          notify: Start Vector

        - name: Create Vector data_dir
          become: true
          ansible.builtin.file:
            path: /var/lib/vector
            state: directory
            mode: "0755"
            owner: root
            group: root
```

Создаем файл конфигурации vector.yml из трех блоков [sourses](https://vector.dev/docs/reference/configuration/sources/), [transforms](https://vector.dev/docs/reference/configuration/transforms/) и [sinks](https://vector.dev/docs/reference/configuration/sinks/). В качестве примера взяты блоки, упомянутые в лекции.

```
mkdir template
cd template
nano vector.j2

sources:
  my_source_id:
    type: file
    include:
      - {{ sourse_file }}

transforms:
  my_transform_id:
    type: lua
    inputs:
      - my_source_id:
    version: {{ version_number }}

sinks:
  my_sink_id:
    type: file
    inputs:
      - my_transform_id
    path: {{ path_file }}
```

Дополняем файл с переменными vars.yml, куда вносим переменные для плейбука site.yml и для шаблона vector.j2
```
nano vars.yml

vector_version: "0.35.0"
vector_os_arch: "x86_64"
vector_workdir: "/root/ansible/08-ansible-02-playbook"
source_file: "/var/log/mongodb/mongod.log"
version_number: "1" 
path_file:  "/tmp/vector-%Y-%m-%d.log"
```

3. При создании tasks рекомендую использовать модули: `get_url`, `template`, `unarchive`, `file`.
4. Tasks должны: скачать дистрибутив нужной версии, выполнить распаковку в выбранную директорию, установить vector.
5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.
```
ansible-lint site.yml
```
 ![Alt text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/08-ansible-02-playbook/screenshots/ansible1.png)
Замечание исправлено удалением лишних пробелов в конце указанных строк.

6. Попробуйте запустить playbook на этом окружении с флагом `--check`.
```
ansible-playbook -i inventory/prod.yml site.yml --check
```
 ![Alt text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/08-ansible-02-playbook/screenshots/ansible2.png)

Уточняем в переменной актуальную версию пакета
```
nano group_vars/clickhouse/vars.yml
clickhouse_version: "23.8.9.54"
```
Также меняем в плейбуке ссылку на корректную (вместо директории stable указываем lts, так как в первой отсутствуют дистрибутивы clickhouse server)
```
url: https://packages.clickhouse.com/rpm/lts/{{ item }}-{{ clickhouse_version }}.x86_64.rpm
```

Запускаем плейбук повторно
```
ansible-playbook -i inventory/prod.yml site.yml --check
```
 ![Alt text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/08-ansible-02-playbook/screenshots/ansible3.png)

7. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.
```
ansible-playbook -i inventory/prod.yml site.yml --diff
```
![Alt text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/08-ansible-02-playbook/screenshots/ansible4.png) 

Проверяем, установлены ли на хосте clickhouse и vector
![Alt text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/08-ansible-02-playbook/screenshots/ansible6.png) 

8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.
```
ansible-playbook -i inventory/prod.yml site.yml --diff
```
![Alt text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/08-ansible-02-playbook/screenshots/ansible5.png) 

9. Подготовьте README.md-файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги. Пример качественной документации ansible playbook по [ссылке](https://github.com/opensearch-project/ansible-playbook).

Докумантация по Ansible-playbook приведена в файле [playbook.md](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/08-ansible-02-playbook/Playbook.md)

10. Готовый playbook выложите в свой репозиторий, поставьте тег `08-ansible-02-playbook` на фиксирующий коммит, в ответ предоставьте ссылку на него.

[Ansible-playbook](https://github.com/LeonidKhoroshev/mnt-homeworks/tree/ansible-02)

---

