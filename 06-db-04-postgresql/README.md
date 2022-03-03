# Домашнее задание к занятию "6.4. PostgreSQL"

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.

Подключитесь к БД PostgreSQL используя `psql`.

Воспользуйтесь командой `\?` для вывода подсказки по имеющимся в `psql` управляющим командам.

**Найдите и приведите** управляющие команды для:
- вывода списка БД
- подключения к БД
- вывода списка таблиц
- вывода описания содержимого таблиц
- выхода из psql

Решение:
```
vagrant@vagrant:~$ docker pull postgres:13
13: Pulling from library/postgres
...
Digest: sha256:5bc010bbb524bef645ab7930e0a198625d1acfc8bdb69c460b030840b0911e3f
Status: Downloaded newer image for postgres:13
docker.io/library/postgres:13
vagrant@vagrant:~$ docker volume create vol_psql
vol_psql
vagrant@vagrant:~$ sudo docker run --rm --name pgdocker -e POSTGRES_PASSWORD
=postgres -e POSTGRES_USER=postgresql -d -p 5432:5432 -v vol_psql:/var/lib/p
ostgresql/data postgres:13
b43032d37fd0f6dadc67e90d440d700036360d0191419c2d48d3e6c4aac4f05e
vagrant@vagrant:~$ sudo docker exec -it pgdocker psql -U postgresql
psql (13.6 (Debian 13.6-1.pgdg110+1))
Type "help" for help.

postgresql=# \l
                                    List of databases
    Name    |   Owner    | Encoding |  Collate   |   Ctype    |     Access privileges
------------+------------+----------+------------+------------+---------------------------
 postgres   | postgresql | UTF8     | en_US.utf8 | en_US.utf8 |
 postgresql | postgresql | UTF8     | en_US.utf8 | en_US.utf8 |
 template0  | postgresql | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgresql            +
            |            |          |            |            | postgresql=CTc/postgresql
 template1  | postgresql | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgresql            +
            |            |          |            |            | postgresql=CTc/postgresql
(4 rows)

postgresql=# \c postgres
You are now connected to database "postgres" as user "postgresql".

postgres=# \dtS
 pg_catalog | pg_aggregate            | table | postgresql
 pg_catalog | pg_am                   | table | postgresql
 pg_catalog | pg_amop                 | table | postgresql
 pg_catalog | pg_amproc               | table | postgresql
 ...

postgres=# \dS+ pg_type
 oid            | oid          |           | not null |         | plain    |              |
 typname        | name         |           | not null |         | plain    |              |
 typnamespace   | oid          |           | not null |         | plain    |              |
 typowner       | oid          |           | not null |         | plain    |              |
 typlen         | smallint     |           | not null |         | plain    |              |
 typbyval       | boolean      |           | not null |         | plain    |              |
 typtype        | "char"       |           | not null |         | plain    |              |
 typcategory    | "char"       |           | not null |         | plain    |              |
...

postgres=# \q
```

## Задача 2

Используя `psql` создайте БД `test_database`.

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-04-postgresql/test_data).

Восстановите бэкап БД в `test_database`.

Перейдите в управляющую консоль `psql` внутри контейнера.

Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.

Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы `orders` 
с наибольшим средним значением размера элементов в байтах.

**Приведите в ответе** команду, которую вы использовали для вычисления и полученный результат.

## Задача 3

Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и
поиск по ней занимает долгое время. Вам, как успешному выпускнику курсов DevOps в нетологии предложили
провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).

Предложите SQL-транзакцию для проведения данной операции.

Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?

## Задача 4

Используя утилиту `pg_dump` создайте бекап БД `test_database`.

Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?
