## Ansible-playbook по установке Clickhouse и Vector

### 1. Устанавливаемое программное обеспечание:

**ClickHouse** — колоночная аналитическая СУБД , позволяющая выполнять аналитические запросы в режиме реального времени на структурированных больших данных, использует собственный диалект SQL близкий к стандартному.

**Vector** - это высокопроизводительный конвейер данных, позволяющий преобразовавать данные из различных источников (файлов, баз данных и т.д.) в требуемый удобночитаемый формат.

---

### 2. Требуемые условия для запуска Ansible-playbook:

**Ansible** - версия не ниже 2.10.

**Phyton** - не ниже версии 3.6.

**Системные требования**:
 - RAM - не менее 2 Гб;
 - ROM - не менее 450 Мб;
 - ОС - Linux-based системы (rpm семейство).

---

### 3. Настройка параметров, необходимых для запуска playbook:

**inventory** - /inventory/prod.yml:
```
clickhouse:
  hosts:
    clickhouse-01:
      ansible_connection: local
```
В указанном примере playbook настроен на установку ПО на локальном хосте, для работы на нескольких хостах необходимо привести файл в следующий вид, указав тип подключения - ssh и ip адреса настраиваемых хостов:
```
clickhouse:
  hosts:
    clickhouse-01:
      ansible_host: <IP_here> ansible_connection: ssh
```

**variables** - /group_vars/clickhouse/vars.yml:
```
clickhouse_version: "23.8.9.54"
clickhouse_packages:
  - clickhouse-client
  - clickhouse-server
  - clickhouse-common-static

vector_version: "0.35.0"
vector_os_arch: "x86_64"
vector_workdir: "/root/ansible/08-ansible-02-playbook"
sourse_file: "/var/log/mongodb/mongod.log"
version_number: "1"
path_file:  "/tmp/vector-%Y-%m-%d.log"
```

В данном файле представлены следующие переменные:
- clickhouse_version - версия clickhouse, подходящую можно выбрать [здесь](https://packages.clickhouse.com);
- clickhouse_packages - устанавливаемые пакеты (сервер, клиент, исполняемые файлы ClickHouse);
- vector_version - версия vector, подхлодящую можно выбрать [здесь](https://packages.timber.io/vector/);
- vector_os_arch - архитектура vector (x86, aarch64 в зависимости от используемого железа);
- vector_workdir - директория, в которой будет установлен vector;
- sourse_file - файл, из которого vector будет брать данные для дальнейшей обработки (подробнее в п.4 настоящей инструкции);
- version_number- версия "обработчика данных" lua (подробнее в п.4 настоящей инструкции);
- path_file - файл, в который попадает обработанная информация из `sourse_file` (подробнее в п.4 настоящей инструкции).

---

### 4. Настройка комбайна "Vector" 

Настройка vector на управляемых хостах осуществляется с помрощью конфигурационного файла, автоматически генерируемого из шаблона /templates/vector.j2:
```
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

Используемые в шаблоне переменные указаны в vars.yml (п.3 настоящей инструкции).

Конфигурация vector основывается на трех разделах:
- sources - источник данных для обработки, в нашем случае выбран файл с логами, но vector поллерживает множество других [источников](https://vector.dev/components/);
- transforms - формат обработки данных, в нашей конгфигурации выбрана lua, но доступно множество других [компоненов](https://vector.dev/docs/reference/configuration/transforms/);
- sinks - отвечает за представление обработанных данных, в нашем шаблоне выбран файл, как самый простой, с остальными форматами вывода можно также ознакомится на сайте разработчика в соответствующем [разделе](https://vector.dev/docs/reference/configuration/sinks/).

---

### 5. Структура Ansible-playbook:

**Установка Clickhouse на хосты, указанные в inventory**

Таски:
- `Get clickhouse distrib` - загрузка пакетов Clickhouse на управляемые хосты (`rescue`: Get clickhouse distrib` - загрузка пакетов Clickhouse в случае сбоя в предыдущей таске);
- `Install clickhouse packages` - установка пакетов Clickhouse (в нашем случае установка rpm пакетов clickhouse-client, clickhouse-server, clickhouse-common-static);
-  `Create database` - создание базы данных Clickhouse.

Хэндлер:
 - `Start clickhouse service` - запуск сервиса Clickhouse. 

**Установка Vector на хосты, указанные в inventory**:

Таски:
- `Get Vector distrib` - загрузка архива  Vector на управляемые хосты;
- `Unpack Vector` - распаковка  Vector в директорию, заданную через переменную `vector_workdir`;
- `Install Vector` - установка Vector;
- `Create Vector config` - создание конфигурационного файла на базе шаблона `vector.j2`, описанного в п.4 настоящей инструкции;
- `Create Vector data_dir` - создание директории для хранения данных Vector.

Хэндлер:
- `Start Vector` - запуск сервиса Vector.

---

### 6. Запуск Ansible-playbook:
```
ansible-playbook -i inventory/prod.yml site.yml
```
