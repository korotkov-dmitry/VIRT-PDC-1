# Домашнее задание к занятию "6.5. Elasticsearch"

## Задача 1

В этом задании вы потренируетесь в:
- установке elasticsearch
- первоначальном конфигурировании elastcisearch
- запуске elasticsearch в docker

Используя докер образ [centos:7](https://hub.docker.com/_/centos) как базовый и 
[документацию по установке и запуску Elastcisearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/targz.html):

- составьте Dockerfile-манифест для elasticsearch
- соберите docker-образ и сделайте `push` в ваш docker.io репозиторий
- запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины

Требования к `elasticsearch.yml`:
- данные `path` должны сохраняться в `/var/lib`
- имя ноды должно быть `netology_test`

В ответе приведите:
- текст Dockerfile манифеста
- ссылку на образ в репозитории dockerhub
- ответ `elasticsearch` на запрос пути `/` в json виде

Подсказки:
- возможно вам понадобится установка пакета perl-Digest-SHA для корректной работы пакета shasum
- при сетевых проблемах внимательно изучите кластерные и сетевые настройки в elasticsearch.yml
- при некоторых проблемах вам поможет docker директива ulimit
- elasticsearch в логах обычно описывает проблему и пути ее решения

Далее мы будем работать с данным экземпляром elasticsearch.

Решение:
```
#Elasticsearch
FROM centos:7

ENV PATH=/usr/lib:/usr/lib/jvm/jre-11/bin:$PATH

RUN yum install java-11-openjdk -y
RUN yum install wget -y

RUN wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.1.0-linux-x86_64.tar.gz \
    && wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.1.0-linux-x86_64.tar.gz.sha512
RUN yum install perl-Digest-SHA -y
RUN shasum -a 512 -c elasticsearch-8.1.0-linux-x86_64.tar.gz.sha512 \
    && tar -xzf elasticsearch-8.1.0-linux-x86_64.tar.gz \
    && yum upgrade -y

ADD elasticsearch.yml /elasticsearch-8.1.0/config/
ENV JAVA_HOME=/elasticsearch-8.1.0/jdk/
ENV ES_HOME=/elasticsearch-8.1.0
RUN groupadd elasticsearch \
    && useradd -g elasticsearch elasticsearch

RUN mkdir /var/lib/logs \
    && chown elasticsearch:elasticsearch /var/lib/logs \
    && mkdir /var/lib/data \
    && chown elasticsearch:elasticsearch /var/lib/data \
    && chown -R elasticsearch:elasticsearch /elasticsearch-8.1.0/
RUN mkdir /elasticsearch-8.1.0/snapshots &&\
    chown elasticsearch:elasticsearch /elasticsearch-8.1.0/snapshots

USER elasticsearch
CMD ["/usr/sbin/init"]
CMD ["/elasticsearch-8.1.0/bin/elasticsearch"]
```

[centos_es](https://hub.docker.com/r/korotkovdmitry/centos_es)

```
vagrant@vagrant:~$ curl --cacert http_ca.crt -u elastic https://localhost:9200
Enter host password for user 'elastic':
{
  "name" : "5729947b36cc",
  "cluster_name" : "netology_test",
  "cluster_uuid" : "-NrNMrjXQTCCUwSYKeOnfg",
  "version" : {
    "number" : "8.1.0",
    "build_flavor" : "default",
    "build_type" : "tar",
    "build_hash" : "3700f7679f7d95e36da0b43762189bab189bc53a",
    "build_date" : "2022-03-03T14:20:00.690422633Z",
    "build_snapshot" : false,
    "lucene_version" : "9.0.0",
    "minimum_wire_compatibility_version" : "7.17.0",
    "minimum_index_compatibility_version" : "7.0.0"
  },
  "tagline" : "You Know, for Search"
}
```

## Задача 2

В этом задании вы научитесь:
- создавать и удалять индексы
- изучать состояние кластера
- обосновывать причину деградации доступности данных

Ознакомтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html) 
и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:

| Имя | Количество реплик | Количество шард |
|-----|-------------------|-----------------|
| ind-1| 0 | 1 |
| ind-2 | 1 | 2 |
| ind-3 | 2 | 4 |

Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.

Получите состояние кластера `elasticsearch`, используя API.

Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?

Удалите все индексы.

**Важно**

При проектировании кластера elasticsearch нужно корректно рассчитывать количество реплик и шард,
иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.

Решение:

Добавление индексов:
```
[elasticsearch@4c004618605c /]$ curl -k -u elastic:QkJ5Y5oqIWBG=WfcOMd3 -X PUT https://localhost:9200/ind-1 -H 'Content-Type: application/json' -d'{ "settings": { "number_of_replicas": 0 , "number_of_shards": 1}}'
[elasticsearch@4c004618605c /]$ curl -k -u elastic:QkJ5Y5oqIWBG=WfcOMd3 -X PUT https://localhost:9200/ind-2 -H 'Content-Type: application/json' -d'{ "settings": { "number_of_replicas": 1 , "number_of_shards": 2}}'
[elasticsearch@4c004618605c /]$ curl -k -u elastic:QkJ5Y5oqIWBG=WfcOMd3 -X PUT https://localhost:9200/ind-3 -H 'Content-Type: application/json' -d'{ "settings": { "number_of_replicas": 2 , "number_of_shards": 4}}'
```
Список индексов:
```
[elasticsearch@4c004618605c /]$ curl -k -u elastic:QkJ5Y5oqIWBG=WfcOMd3 -X GET https://localhost:9200/_cat/indices?v
health status index uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   ind-1 ruX8cemnTL-iTQmv7nSv8w   1   0          0            0       225b           225b
yellow open   ind-3 CA9xkvpPQdGih709Mf9nMA   4   2          0            0       225b           225b
yellow open   ind-2 3oIVs7U4Ske1BvuNs3VEsg   2   1          0            0       450b           450b
```
Статусы индексов:
```
[elasticsearch@4c004618605c /]$ curl -k -u elastic:QkJ5Y5oqIWBG=WfcOMd3 -X GET https://localhost:9200/_cluster/health/ind-1?pretty
{
  "cluster_name" : "netology_test",
  "status" : "green",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 1,
  "active_shards" : 1,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 0,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 100.0
}
[elasticsearch@4c004618605c /]$ curl -k -u elastic:QkJ5Y5oqIWBG=WfcOMd3 -X GET https://localhost:9200/_cluster/health/ind-2?pretty
{
  "cluster_name" : "netology_test",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 2,
  "active_shards" : 2,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 2,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 47.368421052631575
}
[elasticsearch@4c004618605c /]$ curl -k -u elastic:QkJ5Y5oqIWBG=WfcOMd3 -X GET https://localhost:9200/_cluster/health/ind-3?pretty
{
  "cluster_name" : "netology_test",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 4,
  "active_shards" : 4,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 8,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 47.368421052631575
}  
```
Состояние кластера:
```
[elasticsearch@4c004618605c /]$ curl -k -u elastic:QkJ5Y5oqIWBG=WfcOMd3 -X GET https://localhost:9200/_cluster/health/?pretty=true
{
  "cluster_name" : "netology_test",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 9,
  "active_shards" : 9,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 10,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 47.368421052631575
```
Удаление индексов:
```
[elasticsearch@4c004618605c /]$ curl -k -u elastic:QkJ5Y5oqIWBG=WfcOMd3 -X DELETE https://localhost:9200/ind-1?pretty
{
  "acknowledged" : true
}
[elasticsearch@4c004618605c /]$ curl -k -u elastic:QkJ5Y5oqIWBG=WfcOMd3 -X DELETE https://localhost:9200/ind-2?pretty
{
  "acknowledged" : true
}
[elasticsearch@4c004618605c /]$ curl -k -u elastic:QkJ5Y5oqIWBG=WfcOMd3 -X DELETE https://localhost:9200/ind-3?pretty
{
  "acknowledged" : true
}
[elasticsearch@4c004618605c /]$ curl -k -u elastic:QkJ5Y5oqIWBG=WfcOMd3 -X GET https://localhost:9200/_cat/indices?v
health status index uuid pri rep docs.count docs.deleted store.size pri.store.size
```

yellow для индекса означает что указаны реплики.

yellow для кластера означает что основной шард выделен, а реплики нет.


## Задача 3

В данном задании вы научитесь:
- создавать бэкапы данных
- восстанавливать индексы из бэкапов

Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.

Используя API [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository) 
данную директорию как `snapshot repository` c именем `netology_backup`.

**Приведите в ответе** запрос API и результат вызова API для создания репозитория.

Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.

[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html) 
состояния кластера `elasticsearch`.

**Приведите в ответе** список файлов в директории со `snapshot`ами.

Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.

[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
кластера `elasticsearch` из `snapshot`, созданного ранее. 

**Приведите в ответе** запрос к API восстановления и итоговый список индексов.

Подсказки:
- возможно вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `elasticsearch`

Решение:
```
[elasticsearch@4c004618605c /]$ curl -k -u elastic:QkJ5Y5oqIWBG=WfcOMd3 -X POST https://localhost:9200/_snapshot/netology_backup?pretty -H 'Content-Type: application/json' -d'{"type": "fs", "settings": { "location":"elasticsearch-8.1.0/snapshots" }}'
{
  "acknowledged" : true
}
[elasticsearch@4c004618605c /]$  curl -k -u elastic:QkJ5Y5oqIWBG=WfcOMd3 -X GET https://localhost:9200/_snapshot/netology_backup?pretty
{
  "netology_backup" : {
    "type" : "fs",
    "settings" : {
      "location" : "elasticsearch-8.1.0/snapshots"
    }
  }
}

[elasticsearch@4c004618605c /]$ curl -k -u elastic:QkJ5Y5oqIWBG=WfcOMd3 -X PUT https://localhost:9200/test -H 'Content-Type: application/json' -d'{ "settings": { "number_of_replicas": 0,  "number_of_shards": 1 }}'
{"acknowledged":true,"shards_acknowledged":true,"index":"test"}
[elasticsearch@4c004618605c /]$ curl -k -u elastic:QkJ5Y5oqIWBG=WfcOMd3 -X GET https://localhost:9200/_cat/indices?v
health status index uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test  _eiIrpYEQm-BD6rpd6m2vg   1   0          0            0       225b           225b

[elasticsearch@4c004618605c /]$ curl -k -u elastic:QkJ5Y5oqIWBG=WfcOMd3 -X PUT https://localhost:9200/_snapshot/netology_backup/elasticsearch?wait_for_completion=true
{"snapshot":{"snapshot":"elasticsearch","uuid":"ozB5jwy6S4-fY_r9QYfVcg","repository":"netology_backup","version_id":8010099,"version":"8.1.0","indices":[".geoip_databases",".security-7","test"],"data_streams":[],"include_global_state":true,"state":"SUCCESS","start_time":"2022-03-16T13:52:14.448Z","start_time_in_millis":1647438734448,"end_time":"2022-03-16T13:52:16.264Z","end_time_in_millis":1647438736264,"duration_in_millis":1816,"failures":[],"shards":{"total":3,"failed":0,"successful":3},"feature_states":[{"feature_name":"geoip","indices":[".geoip_databases"]},{"feature_name":"security","indices":[".security-7"]}]}}

[elasticsearch@4c004618605c /]$ ls -la /elasticsearch-8.1.0/snapshots/elasticsearch-8.1.0/snapshots
total 44
drwxr-xr-x 3 elasticsearch elasticsearch  4096 Mar 16 13:52 .
drwxr-xr-x 3 elasticsearch elasticsearch  4096 Mar 16 13:39 ..
-rw-r--r-- 1 elasticsearch elasticsearch  1098 Mar 16 13:52 index-0
-rw-r--r-- 1 elasticsearch elasticsearch     8 Mar 16 13:52 index.latest
drwxr-xr-x 5 elasticsearch elasticsearch  4096 Mar 16 13:52 indices
-rw-r--r-- 1 elasticsearch elasticsearch 18406 Mar 16 13:52 meta-ozB5jwy6S4-fY_r9QYfVcg.dat
-rw-r--r-- 1 elasticsearch elasticsearch   391 Mar 16 13:52 snap-ozB5jwy6S4-fY_r9QYfVcg.dat

[elasticsearch@4c004618605c /]$ curl -k -u elastic:QkJ5Y5oqIWBG=WfcOMd3 -X DELETE https://localhost:9200/test?pretty
{
  "acknowledged" : true
}
[elasticsearch@4c004618605c /]$ curl -k -u elastic:QkJ5Y5oqIWBG=WfcOMd3 -X GET https://localhost:9200/_cat/indices?v
health status index uuid pri rep docs.count docs.deleted store.size pri.store.size
[elasticsearch@4c004618605c /]$ curl -k -u elastic:QkJ5Y5oqIWBG=WfcOMd3 -X PUT https://localhost:9200/test-2 -H 'Content-Type: application/json' -d'{ "settings": { "number_of_replicas": 0,  "number_of_shards": 1 }}'
[elasticsearch@4c004618605c /]$ curl -k -u elastic:QkJ5Y5oqIWBG=WfcOMd3 -X GET https://localhost:9200/_cat/indices?v
health status index  uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test-2 bwNiLZVgQF29Lkc12M9bew   1   0          0            0       225b           225b

[elasticsearch@4c004618605c /]$ curl -k -u elastic:QkJ5Y5oqIWBG=WfcOMd3 -X POST https://localhost:9200/_snapshot/netology_backup/elasticsearch/_restore?pretty -H 'Content-Type: application/json' -d'{"include_global_state":true}'
{
  "accepted" : true
}
[elasticsearch@4c004618605c /]$ curl -k -u elastic:QkJ5Y5oqIWBG=WfcOMd3 -X GET https://localhost:9200/_
cat/indices?v
health status index  uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test-2 bwNiLZVgQF29Lkc12M9bew   1   0          0            0       225b           225b
green  open   test   8ZqIlUsNRLW7Whvkcblo-Q   1   0          0            0       225b           225b
```
