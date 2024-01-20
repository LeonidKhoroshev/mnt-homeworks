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
 - RAM - не менее 4 Гб (l для хоста c Lighthouse длпустимо 2 Гб);
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

### 5. Настройка "Clickhouse"



### 6. Настройка  "Vector" 

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
В данной конфигурации на вход берутся автоматически генерируемые логи и отправляются в таблицу, созданную в Clickhouse. 


Используемые в шаблоне переменные указаны в vars.yml (п.3 настоящей инструкции).

Конфигурация vector основывается на трех разделах:
- sources - источник данных для обработки, в нашем случае выбран файл с логами, но vector поллерживает множество других [источников](https://vector.dev/components/);
- transforms - формат обработки данных, в нашей конгфигурации выбрана lua, но доступно множество других [компоненов](https://vector.dev/docs/reference/configuration/transforms/);
- sinks - отвечает за представление обработанных данных, в нашем шаблоне выбран файл, как самый простой, с остальными форматами вывода можно также ознакомится на сайте разработчика в соответствующем [разделе](https://vector.dev/docs/reference/configuration/sinks/).

---

### 6. Структура Ansible-playbook:

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

### 7. Запуск Ansible-playbook:
```
ansible-playbook -i inventory/prod.yml site.yml
```
