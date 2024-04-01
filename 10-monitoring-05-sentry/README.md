![2024-04-01_23-21-50](https://github.com/LeonidKhoroshev/mnt-homeworks/assets/114744186/b2fde497-f740-44f8-8a9a-3db4429f858f)# Домашнее задание к занятию 16 «Платформа мониторинга Sentry» - Леонид Хорошев

## Задание 1

Так как Self-Hosted Sentry довольно требовательная к ресурсам система, мы будем использовать Free Сloud account.

Free Cloud account имеет ограничения:

- 5 000 errors;
- 10 000 transactions;
- 1 GB attachments.

Для подключения Free Cloud account использован существующий аккаунт на Github

![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/10-monitoring-05-sentry/screenshots/sentry1.png)

## Задание 2

1. Создайте python-проект и нажмите `Generate sample event` для генерации тестового события.

```
mkdir sentry
cd sentry
pip3 install --upgrade sentry-sdk
nano main.py
```

Далее создаем проект (код в файле `main.py` аналогично представленному в лекции)

```
import sentry_sdk

sentry_sdk.init(
  dsn="https://5df851eb22dbfe0e39b5f3d628e4c1b3@o4507010720989184.ingest.us.sentry.io/4507011583442944",
  traces_sample_rate=1.0,
  profiles_sample_rate=1.0,
  environment="development",
  release="1.0"
  )

if __name__ == "__main__":
  division_zero = 1/0
```

2. Изучите информацию, представленную в событии.

Запускаем наш проект и наблюдаем исключение `ZeroDivisionError`

```
python3 main.py
```

![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/10-monitoring-05-sentry/screenshots/sentry2.png)

3. Перейдите в список событий проекта, выберите созданное вами и нажмите `Resolved`.
4. В качестве решения задание предоставьте скриншот `Stack trace` из этого события и список событий проекта после нажатия `Resolved`.

![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/10-monitoring-05-sentry/screenshots/sentry3.png)
![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/10-monitoring-05-sentry/screenshots/sentry4.png)



## Задание 3

1. Перейдите в создание правил алёртинга.
2. Выберите проект и создайте дефолтное правило алёртинга без настройки полей.
3. Снова сгенерируйте событие `Generate sample event`.

Создано новое правило алертинга `Alert1`, при наступлении события - 2 ошибки и более - уведомление приходит на почту, привязанную к аккаунту GitHub.

![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/10-monitoring-05-sentry/screenshots/sentry5.png)

Если всё было выполнено правильно — через некоторое время вам на почту, привязанную к GitHub-аккаунту, придёт оповещение о произошедшем событии.

![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/10-monitoring-05-sentry/screenshots/sentry6.png)

4. Если сообщение не пришло — проверьте настройки аккаунта Sentry (например, привязанную почту), что у вас не было 
`sample issue` до того, как вы его сгенерировали, и то, что правило алёртинга выставлено по дефолту (во всех полях all).
Также проверьте проект, в котором вы создаёте событие — возможно алёрт привязан к другому.

5. В качестве решения задания пришлите скриншот тела сообщения из оповещения на почте.

Проверим как алерт срабатывает при наступлении определенных событий (повторение ошибки более двух раз).

![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/10-monitoring-05-sentry/screenshots/sentry7.png)

Переходим в веб-интерфейс и видим, что алерт сработал, так как было 4 попытки деления на ноль:

![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/10-monitoring-05-sentry/screenshots/sentry8.png)

Также проверяем почту на предмет новых уведомлений:

![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/10-monitoring-05-sentry/screenshots/sentry9.png)


6. Дополнительно поэкспериментируйте с правилами алёртинга. Выбирайте разные условия отправки и создавайте sample events.

Поскольку проект достаточно простой, поэкспериментировали с переменными среды `developemnt`и количеством ошибок, необходимым для срабатывания алертов. 

## Задание повышенной сложности

1. Создайте проект на ЯП Python или GO (около 10–20 строк), подключите к нему sentry SDK и отправьте несколько тестовых событий.

Возьмем код из одного из предыдущих домашних заданий по [Gitlab](https://gitlab.com/leonidkhoroshev/netology-example/-/blob/main/app.py?ref_type=heads)

```
from flask import Flask, request
from flask_restful import Resource, Api
from json import dumps
from flask_jsonpify import jsonify

app = Flask(__name__)
api = Api(app)

class Info(Resource):
    def get(self):
        return {'version': 3, 'method': 'GET', 'message': 'Running'}

api.add_resource(Info, '/get_info')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port='5291')
```

Доработаем код, добавив `sentry_sdk`:
```
import sentry_sdk
sentry_sdk.init(
    dsn="https://e307abb7b062a597f1d7d4c1e9d5677c@o4507010720989184.ingest.us.sentry.io/4507013064032256",
    # Set traces_sample_rate to 1.0 to capture 100%
    # of transactions for performance monitoring.
    traces_sample_rate=1.0,
    # Set profiles_sample_rate to 1.0 to profile 100%
    # of sampled transactions.
    # We recommend adjusting this value in production.
    profiles_sample_rate=1.0,
)
```
Проверим еще раз `flask` и `sentry-sdk`:

![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/10-monitoring-05-sentry/screenshots/sentry10.png)

Создадим второй проект в `sentry` `app_py` во фреймворке `flask`:

![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/10-monitoring-05-sentry/screenshots/sentry11.png)

2. Поэкспериментируйте с различными передаваемыми параметрами, но помните об ограничениях Free учётной записи Cloud Sentry.

Запустим наше приложение:

```
python3 app.py
```

![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/10-monitoring-05-sentry/screenshots/sentry14.png)


Выполним несколько запросов через браузер так, чтобы были несколько разных кодов ответов (404 и 200 например):

![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/10-monitoring-05-sentry/screenshots/sentry12.png)
![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/10-monitoring-05-sentry/screenshots/sentry13.png)

3. В качестве решения задания пришлите скриншот меню issues вашего проекта и пример кода подключения sentry sdk/отсылки событий.

Во вкладке `perfomance` увидили, как отображается информация о работе нашего приложения (хотя ОС macOS определена неправильно, так как приложение работает в Centos7):

![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/10-monitoring-05-sentry/screenshots/sentry15.png)

Создадим новый адлерт по аналогии с заданием 2

![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/10-monitoring-05-sentry/screenshots/sentry16.png)

Запускаем приложение и вводим несколько запросов с результатом 404:

![Alt_text](https://github.com/LeonidKhoroshev/mnt-homeworks/blob/MNT-video/10-monitoring-05-sentry/screenshots/sentry17.png)

---

### Как оформить решение задания

Выполненное домашнее задание пришлите в виде ссылки на .md-файл в вашем репозитории.

---
