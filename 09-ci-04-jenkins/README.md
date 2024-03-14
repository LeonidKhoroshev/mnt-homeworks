# Домашнее задание к занятию 10 «Jenkins» - Хорошев Леонид

## Подготовка к выполнению

1. Создать два VM: для jenkins-master и jenkins-agent.

Для создания требуемой инфраструктуры воспользуемся кодом terraform, подготовленным в рамках выполнения предыдущих домашних заданий. 
```
mkdir 09-ci-04-jenkins/infrastructure/terraform
cd 09-ci-04-jenkins/infrastructure/terraform
git init
git pull https://github.com/LeonidKhoroshev/terraform-team
cp ~/CICD/09-ci-03-cicd/infrastructure/terraform/personal.auto.tfvars ~/CICD/09-ci-04-jenkins/infrastructure/terraform/personal.auto.tfvars
terraform init
terraform plan
terraform apply
```
Скопируем наш проект terraform из репозитория `https://github.com/LeonidKhoroshev/terraform-team`, добавим файл `personal.auto.tfvars` из предыдущей домашней работы, откорректируем переменные (требуется для корректного названия VM) и поднимем инфраструктуру.

![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-04-jenkins/screenshots/jen1.png)

2. Установить Jenkins при помощи playbook.

Корректируем inventory, указав пользователя, созданного через cloud-init и ip адреса.

```
---
all:
  hosts:
    jenkins-master-01:
      ansible_host: 158.160.51.50
    jenkins-agent-01:
      ansible_host: 158.160.62.59
  children:
    jenkins:
      children:
        jenkins_masters:
          hosts:
            jenkins-master-01:
        jenkins_agents:
          hosts:
              jenkins-agent-01:
  vars:
    ansible_connection_type: paramiko
    ansible_user: leo

```
Копируем ключ и запускаем playbook
```
cp /root/.ssh/id_rsa.pub files/id_rsa.pub
ansible-playbook site.yml -i inventory/cicd/hosts.yml
```

![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-04-jenkins/screenshots/jen2.png)

3. Запустить и проверить работоспособность.

![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-04-jenkins/screenshots/jen3.png)

4. Сделать первоначальную настройку.

Первоначальная настройка выполнена аналогично материалов лекции, кроме одного - в моей версии Jenkins потребовалось в настройках дополнительно обеспечить возможность подключения агента в настройках безопасности:
![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-04-jenkins/screenshots/jen5.png)

Подключаем агента к мастеру, для чего вводим в терминале агента следуюшее:
```
curl -sO http://158.160.96.132:8080/jnlpJars/agent.jar
java -jar agent.jar -url http://158.160.96.132:8080/ -secret 30a7080259c46d590e8fcba2df01fadb8701cd6da5bec20cacc7df209054de92 -name agent -workDir "/opt/jenkins_agent/"
```

## Основная часть

1. Сделать Freestyle Job, который будет запускать `molecule test` из любого вашего репозитория с ролью.

Выполним job, состоящий из коммнад shell следующего содержания (в качестве репозитория возьмем vector, созданный в рамках выполнения домашних заданий предыдущегот учебного модуля):
```
git init
git pull https://github.com/LeonidKhoroshev/vector.git molecule
/home/jenkins/.local/bin/molecule test
```
Сборка завершилась неудачно:
```
Build step 'Execute shell' marked build as failure
Finished: FAILURE
```
Причина:
```
fatal: [localhost]: FAILED! => {"msg": "The conditional check 'platforms.changed or docker_images.results | map(attribute='images') | select('equalto', []) | list | count >= 0' failed. The error was: no test named 'equalto'\n\nThe error appears to be in '/usr/local/lib/python3.6/site-packages/molecule_docker/playbooks/create.yml': line 65, column 7, but may\nbe elsewhere in the file depending on the exact syntax problem.\n\nThe offending line appears to be:\n\n\n    - name: Build an Ansible compatible image (new)  # noqa: no-handler\n      ^ here\n"}
```
То есть проблема в отсутвиии теста equalto. Ранее с такой проблемой мы сталкивались в рамках выполнения домашнего задания по теме «Тестирование roles». Для исправления ситуации обновляем версии ansible (до 2.16.2) и python ( до 3.10).

![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-04-jenkins/screenshots/jen6.png)
![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-04-jenkins/screenshots/jen7.png)
![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-04-jenkins/screenshots/jen8.png)

2. Сделать Declarative Pipeline Job, который будет запускать `molecule test` из любого вашего репозитория с ролью.

Pipeline выполняем по образу и подобию Freestyle Job, c тем отличием, что вместо первого шага `git init`, мы удаляем содержимое рабочей директории и скачиваем репозиторий заново, так как в него могут быть внесены изменения. Ветка используется не `main`, а `molecule`, потому что по условиям домашних заданий из прошлого учебного модуля.
```
pipeline {
    agent {
        label 'ansible'
    }
    stages {
        stage('Clear work dir') {
            steps {
                deleteDir()
            }
        }
        stage('Clone git repo') {
            steps {
                dir('vector-role') {
                git branch: 'molecule', url: 'https://github.com/LeonidKhoroshev/vector.git'
                }
            }
        }
```
Проверяем результат:
![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-04-jenkins/screenshots/jen9.png)

В этот раз сборка прошла с первого раза, так как в самом коде в репозитории и в логике проверки мы ничего не меняли и не добавляли никаких дополнительных тестов.

3. Перенести Declarative Pipeline в репозиторий в файл `Jenkinsfile`.

Для удобства использования Pipeline создадим в Git отдельный репозиторий [Jenkins](https://github.com/LeonidKhoroshev/Jenkins), где разместим наш [Jenkinsfile](https://github.com/LeonidKhoroshev/Jenkins/blob/main/Jenkinsfile)

4. Создать Multibranch Pipeline на запуск `Jenkinsfile` из репозитория.

Настройки нашего Pipeline (аналогично лекции):

![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-04-jenkins/screenshots/jen10.png)

Результат сборки:
![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-04-jenkins/screenshots/jen11.png)

Несколько предыдущих сборок были завершены неудачей по причине ошибок с назавнием веток (`main` и `master`), а также из-за "отвалившегося" агентского хоста.

Важно отметить, что при  создании Multibranch Pipeline Jenkins автоматически запрашивает в `git` ветку `master`. В случае, если в репозитории отсутствуют созданные пользователем ветки, необходимо менять `master` на `main`, так как именно так называется ветка, создаваемая по умолчанию в репозиториях на `github`. 

5. Создать Scripted Pipeline, наполнить его скриптом из [pipeline](./pipeline).



6. Внести необходимые изменения, чтобы Pipeline запускал `ansible-playbook` без флагов `--check --diff`, если не установлен параметр при запуске джобы (prod_run = True). По умолчанию параметр имеет значение False и запускает прогон с флагами `--check --diff`.
7. Проверить работоспособность, исправить ошибки, исправленный Pipeline вложить в репозиторий в файл `ScriptedJenkinsfile`.
8. Отправить ссылку на репозиторий с ролью и Declarative Pipeline и Scripted Pipeline.
9. Сопроводите процесс настройки скриншотами для каждого пункта задания!!

## Необязательная часть

1. Создать скрипт на groovy, который будет собирать все Job, завершившиеся хотя бы раз неуспешно. Добавить скрипт в репозиторий с решением и названием `AllJobFailure.groovy`.
2. Создать Scripted Pipeline так, чтобы он мог сначала запустить через Yandex Cloud CLI необходимое количество инстансов, прописать их в инвентори плейбука и после этого запускать плейбук. Мы должны при нажатии кнопки получить готовую к использованию систему.

---

### Как оформить решение задания

Выполненное домашнее задание пришлите в виде ссылки на .md-файл в вашем репозитории.

---
