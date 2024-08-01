# Дипломный проект
# Разработка отказоустойчивой инфраструктуры для сайта, включающую мониторинг, сбор логов и резервное копирование основных данных
# Козлов Станислав

## Описание файлов Terraform

* bastion.tf - схема развертывания Bastion-хоста с Ansible и выгрузки на него инвентори
* elastic.tf - схема развертывания сервера Elasticsearch
* image-ansible.tf - схема создания диска Bastion-хоста на основе предварительно загруженного образа.
* inventory.tpl - шаблон наполнения инвентори
* kibana.tf - схема развертывания сервера Kibana
* main.tf - основная схема развертывания кластера с балансировщиками, таргет-группами, группами бэкендов, HTTP-роутером и сетями
* upload-inventory.tf - наполнение инвентори из outputs.tf и выгрузка в бакет
* zabbix.tf - схема развертывания сервера Zabbix
* security-groups.tf - группы безопасности
* backup.tf - резервное копирование снимков дисков

## Описание файлов Ansible

* nginx.yml - плейбук развертывания nginx
* zabbix-server.yml - плейбук развертывания zabbix-server через роль
* zabbix-web.yml - плейбук развертывания zabbix-web через роль
* zabbix-agent.yml - плейбук развертывания zabbix-agent через роль
* kibana.yml - плейбук для развертывания kibana

## Инфраструктура
Для развёртки инфраструктуры используйте Terraform и Ansible.
Не используйте для ansible inventory ip-адреса! Вместо этого используйте fqdn имена виртуальных машин в зоне ".ru-central1.internal". Пример: example.ru-central1.internal

*Выполнено*

## Сайт

Создайте две ВМ в разных зонах, установите на них сервер nginx, если его там нет. ОС и содержимое ВМ должно быть идентичным, это будут наши веб-сервера.
Используйте набор статичных файлов для сайта. Можно переиспользовать сайт из домашнего задания.
Создайте Target Group, включите в неё две созданных ВМ.
Создайте Backend Group, настройте backends на target group, ранее созданную. Настройте healthcheck на корень (/) и порт 80, протокол HTTP.
Создайте HTTP router. Путь укажите — /, backend group — созданную ранее.
Создайте Application load balancer для распределения трафика на веб-сервера, созданные ранее. Укажите HTTP router, созданный ранее, задайте listener тип auto, порт 80.
Протестируйте сайт curl -v <публичный IP балансера>:80

*Выполнено*

*Тест соединения*

![image](https://github.com/stkv1/diplom/assets/145263196/672be4db-c8b9-45ab-b6fb-d8597ea1b3ee)

*Вывод в браузере по IP балансировщика*

![100](https://github.com/stkv1/diplom/assets/145263196/3577f345-3fe3-46c1-83c7-cfc8aef3c6e8)


## Мониторинг

Создайте ВМ, разверните на ней Zabbix. На каждую ВМ установите Zabbix Agent, настройте агенты на отправление метрик в Zabbix.
Настройте дешборды с отображением метрик, минимальный набор — по принципу USE (Utilization, Saturation, Errors) для CPU, RAM, диски, сеть, http запросов к веб-серверам. Добавьте необходимые tresholds на соответствующие графики.

*Используется готовая роль из Ansible Community*

<https://galaxy.ansible.com/ui/repo/published/community/zabbix>

<https://galaxy.ansible.com/ui/repo/published/community/zabbix/docs/>

Устанавливаем коллекцию ролей:
*ansible-galaxy collection install community.zabbix*
Коллекция включает роли Zabbix, Zabbix-Web, Zabbix-Agent, Zabbix-Proxy, Mysql

Установка производится в 
~/.ansible/collections/ansible_collections/community/zabbix/

Zabbix установлен

![133 — копия](https://github.com/stkv1/diplom/assets/145263196/204433db-8855-4b00-a22a-5c50f7d40df8)

![138](https://github.com/stkv1/diplom/assets/145263196/4f7bd5e0-b7b8-4c76-9811-1cd8c4b2c64e)

Для мониторинга создан собственный шаблон, куда добавлены следующие метрики:

![173](https://github.com/user-attachments/assets/b2b71830-f6ab-409d-9f62-900cd18891d7)

Для мониторинга Nginx использован встроенный шаблон Nginx by Zabbix Agent

Графики для метрик собраны в дашборды

![185](https://github.com/user-attachments/assets/ac05c035-26bb-4611-abe8-76ad15a25d83)

![186](https://github.com/user-attachments/assets/ab769328-bb08-4c1a-9712-be87899b4d3c)


## Логи

Cоздайте ВМ, разверните на ней Elasticsearch. Установите filebeat в ВМ к веб-серверам, настройте на отправку access.log, error.log nginx в Elasticsearch.
Создайте ВМ, разверните на ней Kibana, сконфигурируйте соединение с Elasticsearch.

Для развертывания Elasticsearch использовалась готовая роль

<https://github.com/elastic/ansible-elasticsearch>

В процессе в роль были внесены правки в связи с недоступностью продуктов Elasticsearch из России
Ссылки были изменены на зеркало Яндекса:

<https://mirror.yandex.ru/mirrors/elastic/7/>

<https://mirror.yandex.ru/mirrors/elastic/8/>

Некоторые шаги в роли (например, скачивание и установка GPG-ключа для репозитория Elasticsearch) были пропущены для успешного завершения установки

Elasticsearch успешно установлен и запущен

![141](https://github.com/user-attachments/assets/e7e2be96-613a-4e20-9368-783a1c5981f6)

![182](https://github.com/user-attachments/assets/6da48cb5-464b-41a2-aee3-aa8c68dcab8b)

Для развертывания Kibana использовалась следующая роль:

ansible-galaxy install geerlingguy.kibana

Также были переписаны ссылки на зеркала Яндекса:

<https://mirror.yandex.ru/mirrors/elastic/7/pool/main/k/kibana/>

Kibana установлена

![151](https://github.com/user-attachments/assets/dd9ac841-e3ff-4ec5-b3ce-13c81f0d8147)

Также установлен Filebeat:

![188](https://github.com/user-attachments/assets/64dc9541-fc78-482a-bfe9-3eb85569eaa1)

Настроена передача логов из filebeat в Elasticsearch и далее в Kibana.

Логи в Elasticsearch:

![206](https://github.com/user-attachments/assets/85733538-ca46-4c45-9bed-ab1fc728c0b9)

Графики в Kibana:

![238](https://github.com/user-attachments/assets/cac0f5e6-0e57-4f02-9728-ba48613d70f8)

*Выполнено*

## Сеть

Разверните один VPC. Сервера web, Elasticsearch поместите в приватные подсети. Сервера Zabbix, Kibana, application load balancer определите в публичную подсеть.
Настройте Security Groups соответствующих сервисов на входящий трафик только к нужным портам.
Настройте ВМ с публичным адресом, в которой будет открыт только один порт — ssh. Эта вм будет реализовывать концепцию bastion host . Синоним "bastion host" - "Jump host". 
Подключение ansible к серверам web и Elasticsearch через данный bastion host можно сделать с помощью ProxyCommand . 
Допускается установка и запуск ansible непосредственно на bastion host.(Этот вариант легче в настройке)

*Выполнено. Ansible установлен непосредственно на Bastion-хост*

![101](https://github.com/stkv1/diplom/assets/145263196/a37c36b3-380a-49e9-bf5b-46ac4ab18f4b)

![102](https://github.com/stkv1/diplom/assets/145263196/0624607a-12db-4202-ad6a-0bf0cff5865a)



***Особенности реализации этого блока***

*Реализация наполнения файла Inventory и передачи его в Ansible выполнена следующим образом:
Файл инвентори для Ansible собирается через Outputs и выкладывается в бакет. 
Для этого используются функции local_file (для сохранения выдачи Outputs.tf по шаблону в папку с проектом Terraform) и yandex_storage_object (для выгрузки файла в бакет)
Далее, после развертывания бастион-хоста с установленным Ansible и AWS CLI, с помощью remote_exec запускается команда aws s3 cp для скачивания инвентори из бакета*

***Сохранение состояния бастион-хоста***

*Ansible установлен на бастион-хосте, все плейбуки и роли также находятся на нем
Для сохранения состояния бастион-хоста, перед уничтожением инфраструктуры сохраняется снапшот диска.
Перед повторным развертыванием бастиона, через переменную передается id снапшота, через него бастион развертывается со всеми сохраненными изменениями*

***Группы безопасности***

*Добавлены security-groups для балансировщика, серверов Zabbix и Kibana (см. соответствующий файл security-groups.tf)*

### Резервное копирование

Создайте snapshot дисков всех ВМ. Ограничьте время жизни snaphot в неделю. Сами snaphot настройте на ежедневное копирование

*Реализовано с помощью модуля yandex_compute_snapshot_schedule. Периодичность бэкапа указана ежедневной. Число хранимых снимков для каждого диска ограничено 7, таким образом время жизни одного снимка - одна неделя*
