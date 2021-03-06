# Домашнее задание к занятию "6.2. SQL"

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 12) c 2 volume, 
в который будут складываться данные БД и бэкапы.

Приведите получившуюся команду или docker-compose манифест.

```
vagrant@vagrant:~$ sudo docker pull postgres:12
vagrant@vagrant:~$ sudo docker volume create vol_prod
vagrant@vagrant:~$ sudo docker volume create vol_test
vagrant@vagrant:~$ sudo docker run --rm --name pgdocker -e POSTGRES_PASSWORD=postgres -e POSTGRES_USER=postgresql -d -p 5432:5432 -v vol_prod:/var/lib/postgresql/data postgres:12
vagrant@vagrant:~$ sudo docker exec -it pgdocker psql -U postgresql
psql (12.10 (Debian 12.10-1.pgdg110+1))
Type "help" for help.

postgresql=#
```

## Задача 2

В БД из задачи 1: 
- создайте пользователя test-admin-user и БД test_db
- в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже)
- предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db
- создайте пользователя test-simple-user  
- предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db

Таблица orders:
- id (serial primary key)
- наименование (string)
- цена (integer)

Таблица clients:
- id (serial primary key)
- фамилия (string)
- страна проживания (string, index)
- заказ (foreign key orders)

Приведите:
- итоговый список БД после выполнения пунктов выше,
- описание таблиц (describe)
- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db
- список пользователей с правами над таблицами test_db

```
vagrant@vagrant:~$ sudo docker exec -it pgdocker psql -U postgresql
psql (12.10 (Debian 12.10-1.pgdg110+1))
Type "help" for help.

postgresql=# CREATE DATABASE test_db;
postgresql=# CREATE ROLE "test-admin-user" SUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT LOGIN;
postgresql=# exit
vagrant@vagrant:~$ sudo docker exec -it pgdocker psql -U postgresql -d test_db
psql (12.10 (Debian 12.10-1.pgdg110+1))
Type "help" for help.
test_db=# CREATE TABLE orders
(id integer,
name text,
price integer,
PRIMARY KEY (id));
test_db=# CREATE TABLE clients
(id integer PRIMARY KEY,
lastname text,
country text,
booking integer,
FOREIGN KEY (booking) REFERENCES orders (Id));
test_db=# CREATE ROLE "test-simple-user" NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT LOGIN;
CREATE ROLE
test_db=# GRANT SELECT ON TABLE public.clients TO "test-simple-user";
test_db=# GRANT INSERT ON TABLE public.clients TO "test-simple-user";
test_db=# GRANT UPDATE ON TABLE public.clients TO "test-simple-user";
test_db=# GRANT DELETE ON TABLE public.clients TO "test-simple-user";
test_db=# GRANT SELECT ON TABLE public.orders TO "test-simple-user";
test_db=# GRANT INSERT ON TABLE public.orders TO "test-simple-user";
test_db=# GRANT UPDATE ON TABLE public.orders TO "test-simple-user";
test_db=# GRANT DELETE ON TABLE public.orders TO "test-simple-user";
test_db=# \l
                                    List of databases
    Name    |   Owner    | Encoding |  Collate   |   Ctype    |     Access privileges
------------+------------+----------+------------+------------+---------------------------
 postgres   | postgresql | UTF8     | en_US.utf8 | en_US.utf8 |
 postgresql | postgresql | UTF8     | en_US.utf8 | en_US.utf8 |
 template0  | postgresql | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgresql            +
            |            |          |            |            | postgresql=CTc/postgresql
 template1  | postgresql | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgresql            +
            |            |          |            |            | postgresql=CTc/postgresql
 test_db    | postgresql | UTF8     | en_US.utf8 | en_US.utf8 |
test_db=# \d+
                        List of relations
 Schema |  Name   | Type  |   Owner    |    Size    | Description
--------+---------+-------+------------+------------+-------------
 public | clients | table | postgresql | 8192 bytes |
 public | orders  | table | postgresql | 8192 bytes |
test_db=# SELECT * FROM information_schema.role_table_grants WHERE grantee IN ('test-simple-user');
  grantor   |     grantee      | table_catalog | table_schema | table_name | privilege_type | is_grantable | with_hierarchy
------------+------------------+---------------+--------------+------------+----------------+--------------+----------------
 postgresql | test-simple-user | test_db       | public       | orders     | INSERT         | NO           | NO
 postgresql | test-simple-user | test_db       | public       | orders     | SELECT         | NO           | YES
 postgresql | test-simple-user | test_db       | public       | orders     | UPDATE         | NO           | NO
 postgresql | test-simple-user | test_db       | public       | orders     | DELETE         | NO           | NO
 postgresql | test-simple-user | test_db       | public       | clients    | INSERT         | NO           | NO
 postgresql | test-simple-user | test_db       | public       | clients    | SELECT         | NO           | YES
 postgresql | test-simple-user | test_db       | public       | clients    | UPDATE         | NO           | NO
 postgresql | test-simple-user | test_db       | public       | clients    | DELETE         | NO           | NO 
test_db=# \du
                                       List of roles
    Role name     |                         Attributes                         | Member of
------------------+------------------------------------------------------------+-----------
 postgresql       | Superuser, Create role, Create DB, Replication, Bypass RLS | {}
 test-admin-user  | Superuser, No inheritance                                  | {}
 test-simple-user | No inheritance                                             | {}
```

## Задача 3

Используя SQL синтаксис - наполните таблицы следующими тестовыми данными:

Таблица orders

|Наименование|цена|
|------------|----|
|Шоколад| 10 |
|Принтер| 3000 |
|Книга| 500 |
|Монитор| 7000|
|Гитара| 4000|

Таблица clients

|ФИО|Страна проживания|
|------------|----|
|Иванов Иван Иванович| USA |
|Петров Петр Петрович| Canada |
|Иоганн Себастьян Бах| Japan |
|Ронни Джеймс Дио| Russia|
|Ritchie Blackmore| Russia|

Используя SQL синтаксис:
- вычислите количество записей для каждой таблицы 
- приведите в ответе:
    - запросы 
    - результаты их выполнения.

```
test_db=# insert into orders VALUES (1, 'Шоколад', 10), (2, 'Принтер', 3000), (3, 'Книга', 500), (4, 'Монитор', 7000), (5, 'Гитара', 4000);
INSERT 0 5
test_db=# insert into clients VALUES (1, 'Иванов Иван Иванович', 'USA'), (2, 'Петров Пinsert into clients VALUES (1, 'Иванов Иван Иванович', 'USA'), (2, 'Петров Петр Петрович', 'Canada'), (3, 'Иоганн Себастьян Бах', 'Japan'), (4, 'Ронни Джеймс Дио', 'Russia'), (5, 'Ritchie Blackmore', 'Russia');
INSERT 0 5
test_db=# SELECT count (*) FROM orders;
 count
-------
     5
(1 row)

test_db=# SELECT count (*) FROM clients;
 count
-------
     5
(1 row)
```

## Задача 4

Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.

Используя foreign keys свяжите записи из таблиц, согласно таблице:

|ФИО|Заказ|
|------------|----|
|Иванов Иван Иванович| Книга |
|Петров Петр Петрович| Монитор |
|Иоганн Себастьян Бах| Гитара |

Приведите SQL-запросы для выполнения данных операций.

Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.
 
Подсказк - используйте директиву `UPDATE`.

```
test_db=# UPDATE clients SET booking = 3 WHERE id = 1;
test_db=# UPDATE clients SET booking = 4 WHERE id = 2;
test_db=# UPDATE clients SET booking = 5 WHERE id = 3;
test_db=# SELECT lastname ФИО, orders.name Заказ FROM clients INNER JOIN orders ON
orders.id = clients.booking;
         ФИО          |  Заказ
----------------------+---------
 Иванов Иван Иванович | Книга
 Петров Петр Петрович | Монитор
 Иоганн Себастьян Бах | Гитара
```

## Задача 5

Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 
(используя директиву EXPLAIN).

Приведите получившийся результат и объясните что значат полученные значения.

```
test_db=# EXPLAIN SELECT lastname ФИО, orders.name Заказ FROM clients INNER JOIN or
ders ON orders.id = clients.booking;
                              QUERY PLAN
-----------------------------------------------------------------------
 Hash Join  (cost=37.00..57.24 rows=810 width=64)
   Hash Cond: (clients.booking = orders.id)
   ->  Seq Scan on clients  (cost=0.00..18.10 rows=810 width=36)
   ->  Hash  (cost=22.00..22.00 rows=1200 width=36)
         ->  Seq Scan on orders  (cost=0.00..22.00 rows=1200 width=36)
```
Результат показывает время выполнения всего запроса. Время на создание связи и время сбора запроса в таблицу для вывода. 

## Задача 6

Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).

Остановите контейнер с PostgreSQL (но не удаляйте volumes).

Поднимите новый пустой контейнер с PostgreSQL.

Восстановите БД test_db в новом контейнере.

Приведите список операций, который вы применяли для бэкапа данных и восстановления. 

```
vagrant@vagrant:~$ sudo docker exec -t pgdocker pg_dump -U postgresql test_db -f /var/lib/postgresql/data/dump_test.sql
vagrant@vagrant:~$ sudo docker stop pgdocker
vagrant@vagrant:~$ sudo docker run --rm --name pgdocker2 -e POSTGRES_PASSWORD=postgres -e POSTGRES_USER=postgresql -d -v vol_test:/var/lib/postgresql postgres:12
vagrant@vagrant:~$ sudo docker exec -it pgdocker2 psql -U postgresql
postgresql=# CREATE DATABASE test_db;
postgresql=# CREATE ROLE "test-admin-user" SUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT LOGIN;
postgresql=# CREATE ROLE "test-simple-user" NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT LOGIN;
postgresql=# \q
vagrant@vagrant:~$ sudo docker exec -it pgdocker2 psql -U postgresql -d test_db -f /var/lib/postgresql/dump_test.sql
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
ALTER TABLE
CREATE TABLE
ALTER TABLE
COPY 5
COPY 5
ALTER TABLE
ALTER TABLE
ALTER TABLE
GRANT
GRANT
vagrant@vagrant:~$ sudo docker exec -it pgdocker2 psql -U postgresql -d test_db
psql (12.10 (Debian 12.10-1.pgdg110+1))
Type "help" for help.

test_db=# \du
                                       List of roles
    Role name     |                         Attributes                         | Me
mber of
------------------+------------------------------------------------------------+---
--------
 postgresql       | Superuser, Create role, Create DB, Replication, Bypass RLS | {}
 test-admin-user  | Superuser, No inheritance                                  | {}
 test-simple-user | No inheritance                                             | {}

test_db=# SELECT lastname ФИО, orders.name Заказ FROM clients INNER JOIN orders ON
orders.id = clients.booking;
         ФИО          |  Заказ
----------------------+---------
 Иванов Иван Иванович | Книга
 Петров Петр Петрович | Монитор
 Иоганн Себастьян Бах | Гитара
(3 rows)
```
