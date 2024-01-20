## Ansible-playbook по установке Clickhouse, Vector и Lighthouse

### 1. Устанавливаемое программное обеспечание:

**Nginx** - веб сервер, устанавливается на все хосты для обеспечения связи между ними.

**ClickHouse** — колоночная аналитическая СУБД , позволяющая выполнять аналитические запросы в режиме реального времени на структурированных больших данных, использует собственный диалект SQL близкий к стандартному.

**Vector** - это высокопроизводительный конвейер данных, позволяющий преобразовавать данные из различных источников (файлов, баз данных и т.д.) в требуемый удобночитаемый формат.

---

### 2. Требуемые условия для запуска Ansible-playbook:

**Terraform** - версия 1.5.

**Ansible** - версия не ниже 2.10.

**Phyton** - не ниже версии 3.6.

**Системные требования**:
 - RAM - не менее 4 Гб (для хоста c Lighthouse допустимо 2 Гб);
 - ROM - не менее 450 Мб;
 - ОС - Linux-based системы (rpm семейство).
---

### 3. Создание инфраструктуры Yandex Cloud

Данный раздел не относится непосредственно к нашему playbook, так как хосты можно создать и подготовить вручную, но в моем задании применяется terraform для автоматического создания 3-х виртуальных машин - Clickhouse, Vector и Lighthouse. На всех хостах предполагается настройка Nginx и на каждом хосте ПО - соответствующее названию хостов: Clickhouse, Vector и Lighthouse.
Конфигурационный файл terraform
```
resource "yandex_vpc_network" "develop" {
  name = var.vpc_name
}
resource "yandex_vpc_subnet" "develop" {
  name           = var.vpc_name
  zone           = var.default_zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.default_cidr
}

resource "yandex_compute_instance" "vm" {
  for_each             = { for vm in var.each_vm: index(var.each_vm,vm)=> vm }
  name                 = each.value.name
  platform_id          = var.platform_id

resources {
    cores              = each.value.cpu
    memory             = each.value.ram
    core_fraction      = each.value.core_fraction
  }

scheduling_policy {
    preemptible        = each.value.preemptible
  }

network_interface {
    subnet_id          = yandex_vpc_subnet.develop.id
    nat                = true
  }

  boot_disk {
    initialize_params {
      image_id         = var.image_id
      size             = each.value.disk
    }
  }
   metadata = {
    user-data = "${file("./meta.yml")}"
  }
}

resource "local_file" "hosts_cfg" {
  filename = "./inventory/hosts.cfg"
  content = templatefile("./inventory/hosts.tftpl", { webservers = yandex_compute_instance.vm })
```
Variables и metadata могут быть заменены на пользовательские, для изменения параметров пользователя (имя, ssh ключ), variables можно менять название и параметры хостов (например добавить RAM для более надежной работы)

### 4. Настройка параметров, необходимых для запуска playbook:

**inventory** - /inventory/hosts.cfg:
```
[webservers]

clickhouse ansible_host=158.160.104.65

vector ansible_host=158.160.114.122

lighthouse ansible_host=158.160.101.213

[webservers:vars]
ansible_python=/usr/bin/python3
```
Формируется из шаблона при создании хостов `terraform apply`
```
[webservers]

%{~ for i in webservers ~}

${i["name"]} ansible_host=${i["network_interface"][0]["nat_ip_address"]}

%{~ endfor ~}

[webservers:vars]
ansible_python=/usr/bin/python3
```



---

### 5. Настройка  "Vector" 

Настройка vector на управляемых хостах осуществляется с помрощью конфигурационного файла, автоматически генерируемого из шаблона /templates/vector.j2:
```
data_dir: "/var/lib/vector"


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
    endpoint: "http//158.160.104.65:8123"
    table: "logs_table"
    acknowledgements:
      enabled: false
    healthcheck:
      enabled: false
    compression: gzip
    skip_unknown_fields: true
```
В данной конфигурации на вход берутся автоматически генерируемые логи и отправляются в таблицу, созданную в Clickhouse (создана таской ). 

Конфигурация vector основывается на двух разделах (для упрощения конфигурации transforms решил не применять):
- sources - источник данных для обработки, в нашем случае выбран файл с логами, но vector поллерживает множество других [источников](https://vector.dev/components/);
- sinks - отвечает за представление обработанных данных, в нашем шаблоне выбран файл, как самый простой, с остальными форматами вывода можно также ознакомится на сайте разработчика в соответствующем [разделе](https://vector.dev/docs/reference/configuration/sinks/).

---

### 6. Структура Ansible-playbook:

**Установка Nginx**

Таски:
- `NGINX | Install eper-release` - установка открытого хранилища пакетов, из него будет установлен Nginx;
- `NGINX | Install Nginx` - установка веб-сервера Nginx;
- `NGINX | Create general config` - создание конфигурации из шаблона конфигурационного файла nginx.j2 (прописан порт, максимальное количество подключений и т.д.).

Хендлер:
- ` Start nginx` - старт нашего вебсервера на всех хостах inventory.

**Установка Lighthouse**

Таски:
- `Lighthouse | install git` - установка Git репозитория для скачивания от туда дистрибутива Lighthouse (pre-task);
- `Lighthouse | Copy from git` - копирование репозитория на хост;
- `Lighthouse | Create lighthouse config` - создание конфигурации из шаблона конфигурационного файла lighthouse.j2 (прописаны порт, хост, директория, хранение логов).

Хендлер:
- ` Reload nginx` - перезагруза веб-сервера для вступления изменений в силу.


**Установка Clickhouse**

Таски:
- блок тасок `Get clickhouse-common-static distrib`, `Get clickhouse-common-static distrib`, `Get clickhouse-client distrib` - загрузка пакетов Clickhouse на  хост;
- `Install clickhouse packages` - установка пакетов Clickhouse;
- `Create database` - создание базы данных для наших логов.

Хэндлер:
-  `Start clickhouse service` - запуск Clickhouse.


**Установка Vectory**:

Таски:
- `Vector | Get Vector distrib` - загрузка дистрибутива  Vector;
- `Vector | Install Vector` - установка Vector;
- `Vector | Create Vector directory` - создание директории для хранения данных Vector.
- `Vector | Create Vector config` - создание конфигурационного файла на базе шаблона `vector.j2`, описанного в п.5 настоящей инструкции;
- `Vector | Create systemd unit` - создание директории для хранения данных Vector.

Хэндлер:
- `Start Vector` - запуск сервиса Vector.

---

### 7. Запуск Ansible-playbook:
```
ansible-playbook -i inventory/hosts.cfg playbook.yml
```
