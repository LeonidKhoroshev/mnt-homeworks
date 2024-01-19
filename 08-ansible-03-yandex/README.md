# Домашнее задание к занятию 3 «Использование Ansible» - Леонид Хорошев

## Подготовка к выполнению

1. Подготовьте в Yandex Cloud три хоста: для `clickhouse`, для `vector` и для `lighthouse`.

Инфраструктуру для выполнения домашнего задания поднимаем через terraform, для чего подготовим файлы для создания сети, подсети и 3-х ВМ с именами `clickhouse`, `vector` и `lighthouse`. В параметр metadata через cloud-init передадим информацию о создаваемом пользователе и ssh ключах. Через ресурс local_file создаем inventory файл через соответствующий шаблон.
```
nano main.tf

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
}
```
Для автоматического создания inventory файла подготовим соответствующий шаблон.
```
nano inventory/hosts.tftpl

[webservers]

%{~ for i in webservers ~}

${i["name"]} ansible_host=${i["network_interface"][0]["nat_ip_address"]}

%{~ endfor ~}

[webservers:vars]
ansible_python=/usr/bin/python
```

Также создадим файл meta.yml, описывающий параметры метадаты для наших хостов:
```
nano meta.yml

#cloud-config
users:
  - name: leo
    groups: sudo
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    ssh-authorized-keys:
      - ssh-rsa AAAAB3NzaC........
```

Все необходимые переменные объявляем в variables.tf
```
nano variables.tf

###cloud vars
variable "token" {
  type        = string
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
}

variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}
variable "default_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "vpc_name" {
  type        = string
  default     = "develop"
  description = "VPC network&subnet name"
}

###vm vars

variable "platform_id" {
  type        = string
  default     = "standard-v3"
}

variable "image_id" {
  type        = string
  default     = "fd8gvgtf1t3sbtt4opo6"
}
variable "metadata" {
  type        = map
  default     = {serial_port_enable = "1",ssh_keys = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCgT8Ny1LD7hTjTan3NOKzgpZ9FEJC7+G7Zfm+bs+9bXZhQ/B6gwjJh0VI6RsVo2wZKsosIc2DZogA+NlWbefQfiC5RKtt/iZ$
}

variable "security_group_example" {
  type        = string
  default     = "enpst7elmqdtqj1j5e16"
}

variable "each_vm" {
  type = list(object({  name=string, cpu=number, ram=number, disk=number,preemptible=bool,core_fraction=number }))
  default = [{
    name="clickhouse"
    cpu=2
    ram=4
    disk=10
    preemptible=true
    core_fraction=20
    },
    {
    name="vector"
    cpu=2
    ram=4
    disk=10
    preemptible=true
    core_fraction=20
    },
    {
    name="lighthouse"
    cpu=2
    ram=4
    disk=10
    preemptible=true
    core_fraction=20
    }]
  }

#inventory vars

variable "public_key" {
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc.........."
}
```

Из предыдущих домашних занятий по теме terraform скопируем файл providers.tf
```
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">=0.13"
}

provider "yandex" {
  token     = var.token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.default_zone
}
```
Поднимаем инфраструктуру
```
terraform init
terraform plan
terraform apply
```

Проверяем созданные вм
![Alt text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/08-ansible-03-yandex/screenshots/ansible1.png)
Проверяем файл inventory
![Alt text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/08-ansible-03-yandex/screenshots/ansible2.png)

Проверяем доступность созданных хостов
```
ansible all -i inventory/hosts.cfg -m ping -u leo
```
![Alt text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/08-ansible-03-yandex/screenshots/ansible3.png)

2. Репозиторий LightHouse находится [по ссылке](https://github.com/VKCOM/lighthouse).

## Основная часть

1. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает LightHouse.
2. При создании tasks рекомендую использовать модули: `get_url`, `template`, `yum`, `apt`.
3. Tasks должны: скачать статику LightHouse, установить Nginx или любой другой веб-сервер, настроить его конфиг для открытия LightHouse, запустить веб-сервер.
Разделим playbook на задачи по установке и настройке:
Nginx
```
- name: Install Nginx
  hosts: webservers
  remote_user: leo
  become: true
  handlers:
    - name: Start nginx
      remote_user: leo
      become: true
      ansible.builtin.command: nginx
    - name: Reload nginx
      become: true
      ansible.builtin.command: nginx -s reload
  tasks:
    - name: NGINX | Install eper-release
      remote_user: leo
      become: true
      ansible.builtin.yum:
        name: epel-release
        state: present
    - name: NGINX | Install Nginx
      become: true
      ansible.builtin.yum:
        name: nginx
        state: present
      notify: Start nginx
    - name: NGINX | Create general config
      become: true
      remote_user: leo
      ansible.builtin.template:
        src: template/nginx.j2
        dest: /etc/nginx/nginx.conf
        mode: "0755"
      notify: Reload nginx
```
Lighthouse
```
- name: Install Lighthouse
  hosts: lighthouse
  remote_user: leo
  become: true
  handlers:
    - name: Reload nginx
      become: true
      remote_user: leo
      ansible.builtin.command: nginx -s reload
  pre_tasks:
    - name: Lighthouse | install git
      become: true
      ansible.builtin.yum:
        name: git
        state: present
  tasks:
    - name: Lighthouse | Copy from git
      become: true
      ansible.builtin.git:
        repo: "https://github.com/VKCOM/lighthouse.git"
        version: master
        dest: "home/leo/lighthouse"
    - name: Lighthouse | Create lighthouse config
      become: true
      ansible.builtin.template:
        src: template/lighthouse.j2
        dest: /etc/nginx/conf.d/default.conf
        mode: "0755"
      notify: Reload nginx
```
Clickhouse
```
- name: Install Clickhouse
  hosts: clickhouse
  remote_user: leo
  become: true
  handlers:
    - name: Start clickhouse service
      become: true
      ansible.builtin.service:
        name: clickhouse-server
        state: restarted
  tasks:
    - block:
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
Vector
```

```
- name: Install Vector
  hosts: vector
  remote_user: leo
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
            owner: leo
            group: root

        - name: Vector | Template config
          become: true
          ansible.builtin.template:
            src: template/vector.yml.j2
            dest: /etc/vector/vector.yml
            mode: "0755"
            owner: "leo"
            group: "root"
            validate: vector validate --no-environment --config-yaml %s
        - name: Vector | Create systemd unit
          become: true
          ansible.builtin.template:
            src: template/vector.service.j2
            dest: /etc/systemd/system/vector.service
            mode: "0755"
            owner: "leo"
            group: "root"
```
5. Подготовьте свой inventory-файл.

Файл формируется автоматически из шаблона, приведенного выше в hosts.cfg.
![Alt text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/08-ansible-03-yandex/screenshots/ansible3.png)

6. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.
7. Попробуйте запустить playbook на этом окружении с флагом `--check`.
8. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.
9. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.
10. Подготовьте README.md-файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги.
11. Готовый playbook выложите в свой репозиторий, поставьте тег `08-ansible-03-yandex` на фиксирующий коммит, в ответ предоставьте ссылку на него.

---

### Как оформить решение задания

Выполненное домашнее задание пришлите в виде ссылки на .md-файл в вашем репозитории.

---
