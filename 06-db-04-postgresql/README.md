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

Решение:
```
postgresql=# CREATE DATABASE test_database;
CREATE DATABASE
postgresql=# \q
vagrant@vagrant:~$ docker exec -i pgdocker /bin/bash -c "PGPASSWORD=postgres psql --username postgresql test_database" < test_dump.sql.4
SET
SET
SET
SET
SET
 set_config
------------

(1 row)

SET
SET
SET
SET
SET
SET
CREATE TABLE
ERROR:  role "postgres" does not exist
CREATE SEQUENCE
ERROR:  role "postgres" does not exist
ALTER SEQUENCE
ALTER TABLE
COPY 8
 setval
--------
      8
(1 row)

ALTER TABLE
vagrant@vagrant:~$ sudo docker exec -it pgdocker psql -U postgresql
postgresql=# \c test_database
You are now connected to database "test_database" as user "postgresql".
test_database=# \dt
          List of relations
 Schema |  Name  | Type  |   Owner
--------+--------+-------+------------
 public | orders | table | postgresql
(1 row)
test_database=# ANALYZE VERBOSE public.orders;
INFO:  analyzing "public.orders"
INFO:  "orders": scanned 1 of 1 pages, containing 8 live rows and 0 dead rows; 8 rows in sample, 8 estimated total rows
ANALYZE
test_database=# SELECT avg_width FROM pg_stats WHERE tablename='orders';
 avg_width
-----------
         4
        16
         4
(3 rows)
```

## Задача 3

Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и
поиск по ней занимает долгое время. Вам, как успешному выпускнику курсов DevOps в нетологии предложили
провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).

Предложите SQL-транзакцию для проведения данной операции.

Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?

Решение:
```
test_database=# alter table orders rename to orders_simple;
ALTER TABLE
test_database=# create table orders (id integer, title varchar(80), price integer) partition by range(price);
CREATE TABLE
test_database=# create table orders_less499 partition of orders for values from (0) to (499);
CREATE TABLE
test_database=# create table orders_more499 partition of orders for values from (499) to (999999999);
CREATE TABLE
test_database=# insert into orders (id, title, price) select * from orders_simple;
INSERT 0 8
```
Дополнение:

Избежать ручного разбиения можно было при проектировании таблиц, т.е. использовать секционирование сразу.

## Задача 4

Используя утилиту `pg_dump` создайте бекап БД `test_database`.

Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?

Решение:
```
vagrant@vagrant:~$ docker exec -i pgdocker /bin/bash -c "PGPASSWORD=postgres pg_dump --username postgresql test_database" > test_dump_ubd.sql
```
[бэкап БД](https://github.com/korotkov-dmitry/VIRT-PDC-1/edit/main/06-db-04-postgresql/test_data)

Уникальность можно обеспечить добавив индекс или первичный ключ.
```
CREATE INDEX ON orders ((lower(title)));
```
Дополнение:

Для таблицы orders после разбиения не отработает, т.к. эта таблица `partitioned`. Для "обычной" отработает:
```
test_database=# CREATE INDEX ON orders_simple ((lower(title)));
CREATE INDEX
```
Стандарту SQL соответствует использование UNIQUE - ограничение уникальности данных, содержащихся в колонке или группе колонок. 
Индексы занимают место на диске из-за переполнения и "пустых" индексов. Требуется контроль проблемных мест, при использовании индексов. Настройка диагностик частично помогает в данной проблеме.

Дополнение 2:
Если я правильно понял, уникальное ограничение (Unique Constraint) относиться к ограничению на уровне данных SQL, которое, в свою очередь, "само" создает индекс-B-дерево.
Уникальный индекс (Unique Index) работает от обратного, т.е. устанавливает ограничение, но основная задача ускорение поиска. Также для уникального индекса значения NULL считаются не равными друг другу, что отлично от Unique Constraint. Также отличием является возможность использовать Unique Constraint в качестве внешнего ключа. 
```
CREATE TABLE public.orders (
    id integer NOT NULL,
    title character varying(80) NOT NULL,
    price integer DEFAULT 0,
    UNIQUE (title)
);
```
