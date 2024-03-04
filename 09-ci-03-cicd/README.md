# Домашнее задание к занятию 9 «Процессы CI/CD» - Леонид Хорошев

## Подготовка к выполнению

1. Создайте два VM в Yandex Cloud с параметрами: 2CPU 4RAM Centos7 (остальное по минимальным требованиям).

Для подготовки нашей инфраструктуры воспрользуемся готовыми конфигами terraform, используемыми ранее при выполнении домашних заданий по теме терраформ.
```
mkdir terraform
cd terraform
git init
git pull https://github.com/LeonidKhoroshev/terraform-team
terraform init
```
Дополняем файлом с персональными переменными ` nano personal.auto.tfvars`, чтобы при не вводить каждый раз наши токены и id при создании инфраструктуры, задаем через переменные нужное количество виртуальных машин и требуемую ОС, закомментируем код с избыточными ресурсами (s3 backand) и поднимаем нашу инфраструктуру.
```
terraform plan
terraform apply
```
![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-03-cicd/screenshots/sonar1.png)

2. Пропишите в [inventory](./infrastructure/inventory/cicd/hosts.yml) [playbook](./infrastructure/site.yml) созданные хосты.
```
---
all:
  hosts:
    sonar-01:
      ansible_host: 51.250.95.29
    nexus-01:
      ansible_host: 51.250.95.45
  children:
    sonarqube:
      hosts:
        sonar-01:
    nexus:
      hosts:
        nexus-01:
    postgres:
      hosts:
        sonar-01:
  vars:
    ansible_connection_type: paramiko
    ansible_user: leo
```
3. Добавьте в [files](./infrastructure/files/) файл со своим публичным ключом (id_rsa.pub). Если ключ называется иначе — найдите таску в плейбуке, которая использует id_rsa.pub имя, и исправьте на своё.
```
cp /root/.ssh/id_rsa.pub files/id_rsa.pub
```
4. Запустите playbook, ожидайте успешного завершения.
```
ansible-playbook site.yml -i inventory/cicd/hosts.yml
```
![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-03-cicd/screenshots/sonar2.png)
Как видно - проблема в версии Postgres, переходим в файл с переменными и меняем версию с 11 на более актуальную
```
nano inventory/cicd/group_vars/postgres.yml
postgresql_version: 12
```
Пробуем повторно
![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-03-cicd/screenshots/sonar3.png)
Теперь ошибка при старте postgres, проблема в том, что при запуске сервиса система требует root пароль, который у нас не задан.
В соответствующем разделе плейбука отключаем запрос пароля, то есть меняем значение `enabled` с `true` на `false`.
```
nano site.yml
    - name: Start pgsql service
      systemd:
        name: "postgresql-{{ postgresql_version }}"
        state: started
        enabled: false
```
Также следует обратить внимание на наличие "хардкода" в playbook - при изменении версии postgres необходимо проверить файл [site.yml](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-03-cicd/infrastructure/site.yml) и вручную изменить версию postgres в коде.
![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-03-cicd/screenshots/sonar4.png)

5. Проверьте готовность SonarQube через [браузер](http://localhost:9000).
В результате с первого раза сервис оказался недоступен, это может быть связано с закрытым портом 9000, чтобы его открыть напишем небольшой плейбук:
```
nano openport.yml
---
- name: Install firewalld
  hosts: sonarqube
  become: true
  tasks:
    - name: Install
      ansible.builtin.yum:
        name: firewalld
        state: present
    - name: Start firewalld
      ansible.builtin.service:
        name: firewalld
        state: started
        enabled: true
    - name: Enable 9000
      ansible.posix.firewalld:
        zone: public
        port: 9000/tcp
        permanent: true
        state: enabled
```
Проверяем и запускаем:
```
ansible-lint openport.yml
ansible-playbook openport.yml -i inventory/cicd/hosts.yml
```
![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-03-cicd/screenshots/sonar5.png)


![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-03-cicd/screenshots/sonar6.png)


6. Зайдите под admin\admin, поменяйте пароль на свой.
7.  Проверьте готовность Nexus через [бразуер](http://localhost:8081).

![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-03-cicd/screenshots/sonar7.png)

8. Подключитесь под admin\admin123, поменяйте пароль, сохраните анонимный доступ.

## Знакомоство с SonarQube

### Основная часть

1. Создайте новый проект, название произвольное.
2. Скачайте пакет sonar-scanner, который вам предлагает скачать SonarQube.
```
wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip?_gl=1*11cjh35*_gcl_au*OTI0NDY3NTYzLjE3MDkyMzU5NTE.*_ga*MTkxMTgwNzA2Ni4xNzA5MjM1OTUx*_ga_9JZ0GZ5TC6*MTcwOTU0Mzk1OC41LjEuMTcwOTU1MDU3Mi4yMy4wLjA.
unzip  
unzip sonar-scanner-cli-5.0.1.3006-linux.zip?_gl=1*11cjh35*_gcl_au*OTI0NDY3NTYzLjE3MDkyMzU5NTE.*_ga*MTkxMTgwNzA2Ni4xNzA5MjM1OTUx*_ga_9JZ0GZ5TC6*MTcwOTU0Mzk1OC41LjEuMTcwOTU1MDU3Mi4yMy4wLjA.
rm sonar-scanner-cli-5.0.1.3006-linux.zip?_gl=1*11cjh35*_gcl_au*OTI0NDY3NTYzLjE3MDkyMzU5NTE.*_ga*MTkxMTgwNzA2Ni4xNzA5MjM1OTUx*_ga_9JZ0GZ5TC6*MTcwOTU0Mzk1OC41LjEuMTcwOTU1MDU3Mi4yMy4wLjA.
```

3. Сделайте так, чтобы binary был доступен через вызов в shell (или поменяйте переменную PATH, или любой другой, удобный вам способ).
```

```

4. Проверьте `sonar-scanner --version`.
5. Запустите анализатор против кода из директории [example](./example) с дополнительным ключом `-Dsonar.coverage.exclusions=fail.py`.
6. Посмотрите результат в интерфейсе.
7. Исправьте ошибки, которые он выявил, включая warnings.
8. Запустите анализатор повторно — проверьте, что QG пройдены успешно.
9. Сделайте скриншот успешного прохождения анализа, приложите к решению ДЗ.

## Знакомство с Nexus

### Основная часть

1. В репозиторий `maven-public` загрузите артефакт с GAV-параметрами:

 *    groupId: netology;
 *    artifactId: java;
 *    version: 8_282;
 *    classifier: distrib;
 *    type: tar.gz.
   
2. В него же загрузите такой же артефакт, но с version: 8_102.
3. Проверьте, что все файлы загрузились успешно.

![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-03-cicd/screenshots/sonar8.png)

4. В ответе пришлите файл [maven-metadata.xml](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-03-cicd/screenshots/maven-metadata.xml) для этого артефекта.

### Знакомство с Maven

### Подготовка к выполнению

1. Скачайте дистрибутив с [maven](https://maven.apache.org/download.cgi).

```
wget https://dlcdn.apache.org/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.tar.gz
```
![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-03-cicd/screenshots/mvn1.png)

2. Разархивируйте, сделайте так, чтобы binary был доступен через вызов в shell (или поменяйте переменную PATH, или любой другой, удобный вам способ).
```
tar -xvf apache-maven-3.9.6-bin.tar.gz
rm apache-maven-3.9.6-bin.tar.gz
ln -s /root/CICD/09-ci-03-cicd/mvn/apache-maven-3.9.6/bin/mvn /usr/bin/mvn
```

3. Удалите из `apache-maven-<version>/conf/settings.xml` упоминание о правиле, отвергающем HTTP- соединение — раздел mirrors —> id: my-repository-http-unblocker.

Удален код
```
    <mirror>
      <id>maven-default-http-blocker</id>
      <mirrorOf>external:http:*</mirrorOf>
      <name>Pseudo repository to mirror external repositories initially using HTTP.</name>
      <url>http://0.0.0.0/</url>
      <blocked>true</blocked>
    </mirror>
```


4. Проверьте `mvn --version`.

![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-03-cicd/screenshots/mvn2.png)

Корректно maven заработал только после установки java актуальной версии

```
wget https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.rpm
dnf install ./jdk-17_linux-x64_bin.rpm
ls -1 /usr/lib/jvm/jre-openjdk/
```
![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-03-cicd/screenshots/mvn3.png)

5. Заберите директорию [mvn](./mvn) с pom.

### Основная часть

1. Поменяйте в `pom.xml` блок с зависимостями под ваш артефакт из первого пункта задания для Nexus (java с версией 8_282).

В данном файле указан наш репозиторий  `http://158.160.121.165:8081/repository/maven-public/` актуальная версия артефакта `8_282`, а также раскомментирован блок с зависимостями.
```
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <groupId>com.netology.app</groupId>
  <artifactId>simple-app</artifactId>
  <version>1.0-SNAPSHOT</version>
   <repositories>
    <repository>
      <id>my-repo</id>
      <name>maven-public</name>
      <url>http://158.160.121.165:8081/repository/maven-public/</url>
    </repository>
  </repositories>
  <dependencies>
     <dependency>
      <groupId>netology</groupId>
      <artifactId>java</artifactId>
      <version>8_282</version>
      <classifier>distrib</classifier>
      <type>.gz</type>
    </dependency> 
  </dependencies>
</project>
```

2. Запустите команду `mvn package` в директории с `pom.xml`, ожидайте успешного окончания.

![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-03-cicd/screenshots/mvn4.png)

3. Проверьте директорию `~/.m2/repository/`, найдите ваш артефакт.

```
ls -la ~/.m2/repository/netology/java/8_282
```

![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-03-cicd/screenshots/mvn5.png)

4. В ответе пришлите исправленный файл [pom.xml](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/09-ci-03-cicd/mvn/pom.xml).

---
