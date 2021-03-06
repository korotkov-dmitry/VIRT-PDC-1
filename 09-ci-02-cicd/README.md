# Домашнее задание к занятию "09.02 CI\CD"

## Знакомоство с SonarQube

### Подготовка к выполнению

1. Выполняем `docker pull sonarqube:8.7-community`
2. Выполняем `docker run -d --name sonarqube -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true -p 9000:9000 sonarqube:8.7-community`
3. Ждём запуск, смотрим логи через `docker logs -f sonarqube`
4. Проверяем готовность сервиса через [браузер](http://localhost:9000)
5. Заходим под admin\admin, меняем пароль на свой

В целом, в [этой статье](https://docs.sonarqube.org/latest/setup/install-server/) описаны все варианты установки, включая и docker, но так как нам он нужен разово, то достаточно того набора действий, который я указал выше.

### Основная часть

1. Создаём новый проект, название произвольное
2. Скачиваем пакет sonar-scanner, который нам предлагает скачать сам sonarqube
3. Делаем так, чтобы binary был доступен через вызов в shell (или меняем переменную PATH или любой другой удобный вам способ)
4. Проверяем `sonar-scanner --version`
5. Запускаем анализатор против кода из директории [example](https://github.com/netology-code/mnt-homeworks/tree/master/09-ci-02-cicd/example) с дополнительным ключом `-Dsonar.coverage.exclusions=fail.py`
6. Смотрим результат в интерфейсе
7. Исправляем ошибки, которые он выявил(включая warnings)
8. Запускаем анализатор повторно - проверяем, что QG пройдены успешно
9. Делаем скриншот успешного прохождения анализа, прикладываем к решению ДЗ

#### Решение
<p align="center">
  <img src="./img/fail_py_bug.png">
</p>

<p align="center">
  <img src="./img/fail_py_bug_1.png">
</p>

<p align="center">
  <img src="./img/fail_py_good.png">
</p>

[fail.py](./src/fail.py)

```
vagrant@vagrant:~$ docker run -d --name sonarqube -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true -p 9000:9000 sonarqube:8.7-community
...
vagrant@vagrant:~$ cd /opt
vagrant@vagrant:/opt$ sudo mkdir sonarscanner
vagrant@vagrant:~$ cd sonarscanner
vagrant@vagrant:/opt/sonarscanner$ sudo wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.7.0.2747-linux.zip
vagrant@vagrant:/opt/sonarscanner$ sudo unzip sonar-scanner-cli-4.7.0.2747-linux.zip
vagrant@vagrant:/opt/sonarscanner$ sudo cat sonar-scanner-4.7.0.2747-linux/conf/sonar-scanner.properties
#Configure here general information about the environment, such as SonarQube server connection details for example
#No information about specific project should appear here

#----- Default SonarQube server
sonar.host.url=http://localhost:9000

#----- Default source code encoding
sonar.sourceEncoding=UTF-8
vagrant@vagrant:/opt/sonarscanner$ sudo chmod +x sonar-scanner-4.7.0.2747-linux/bin/sonar-scanner
vagrant@vagrant:/opt/sonarscanner$ sudo ln -s /opt/sonarscanner/sonar-scanner-4.7.0.2747-linux/bin/sonar-scanner /usr/local/bin/sonar-scanner
vagrant@vagrant:/opt/sonarscanner$ sonar-scanner -v
INFO: Scanner configuration file: /opt/sonarscanner/sonar-scanner-4.7.0.2747-linux/conf/sonar-scanner.properties
INFO: Project root configuration file: NONE
INFO: SonarScanner 4.7.0.2747
INFO: Java 11.0.14.1 Eclipse Adoptium (64-bit)
INFO: Linux 5.4.0-80-generic amd64
vagrant@vagrant:~/sonar-test$ sonar-scanner -Dsonar.projectKey=netology-homework -Dsonar.coverage.exclusions=fail.py -Dsonar.host.url=http://localhost:9000   -Dsonar.login=admin -Dsonar.password=adminadmin
INFO: Project root configuration file: NONE
INFO: SonarScanner 4.7.0.2747
INFO: Java 11.0.14.1 Eclipse Adoptium (64-bit)
INFO: Linux 5.4.0-80-generic amd64
INFO: User cache: /home/vagrant/.sonar/cache
INFO: Scanner configuration file: /opt/sonarscanner/sonar-scanner-4.7.0.2747-linux/conf/sonar-scanner.properties
...
INFO: Base dir: /home/vagrant/sonar-test
INFO: Working dir: /home/vagrant/sonar-test/.scannerwork
INFO: Load project settings for component key: 'netology-homework'
...
INFO: Indexing files...
INFO: Project configuration:
INFO:   Excluded sources for coverage: fail.py
...
INFO: Analysis total time: 26.540 s
INFO: ------------------------------------------------------------------------
INFO: EXECUTION SUCCESS
INFO: ------------------------------------------------------------------------
INFO: Total time: 29.562s
INFO: Final Memory: 7M/27M
INFO: ------------------------------------------------------------------------
```

## Знакомство с Nexus

### Подготовка к выполнению

1. Выполняем `docker pull sonatype/nexus3`
2. Выполняем `docker run -d -p 8081:8081 --name nexus sonatype/nexus3`
3. Ждём запуск, смотрим логи через `docker logs -f nexus`
4. Проверяем готовность сервиса через [бразуер](http://localhost:8081)
5. Узнаём пароль от admin через `docker exec -it nexus /bin/bash`
6. Подключаемся под админом, меняем пароль, сохраняем анонимный доступ

### Основная часть

1. В репозиторий `maven-public` загружаем артефакт с GAV параметрами:
   1. groupId: netology
   2. artifactId: java
   3. version: 8_282
   4. classifier: distrib
   5. type: tar.gz
2. В него же загружаем такой же артефакт, но с version: 8_102
3. Проверяем, что все файлы загрузились успешно
4. В ответе присылаем файл `maven-metadata.xml` для этого артефекта

#### Решение

<p align="center">
  <img src="./img/maven.png">
</p>

<p align="center">
  <img src="./img/maven_1.png">
</p>

[maven-metadata.xml](./src/maven-metadata.xml)

### Знакомство с Maven

### Подготовка к выполнению

1. Скачиваем дистрибутив с [maven](https://maven.apache.org/download.cgi)
2. Разархивируем, делаем так, чтобы binary был доступен через вызов в shell (или меняем переменную PATH или любой другой удобный вам способ)
3. Проверяем `mvn --version`
4. Забираем директорию [mvn](https://github.com/netology-code/mnt-homeworks/tree/master/09-ci-02-cicd/mvn) с pom

### Основная часть

1. Меняем в `pom.xml` блок с зависимостями под наш артефакт из первого пункта задания для Nexus (java с версией 8_282)
2. Запускаем команду `mvn package` в директории с `pom.xml`, ожидаем успешного окончания
3. Проверяем директорию `~/.m2/repository/`, находим наш артефакт
4. В ответе присылаем исправленный файл `pom.xml`

#### Решение

```
vagrant@vagrant:~$ mvn -v
Apache Maven 3.8.5 (3599d3414f046de2324203b78ddcf9b5e4388aa0)
Maven home: /opt/apache-maven-3.8.5
Java version: 11.0.15, vendor: Private Build, runtime: /usr/lib/jvm/java-11-openjdk-amd64
Default locale: en_US, platform encoding: UTF-8
OS name: "linux", version: "5.4.0-80-generic", arch: "amd64", family: "unix"
vagrant@vagrant:~/maven$ ls
pom.xml
vagrant@vagrant:~/maven$ mvn package
...
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time:  39.393 s
[INFO] Finished at: 2022-05-31T08:15:24Z
[INFO] ------------------------------------------------------------------------
vagrant@vagrant:~/maven$ ls ~/.m2/repository/netology/java/8_282 -l
total 36
-rw-rw-r-- 1 vagrant vagrant 7925 May 31 08:14 java-8_282-distrib.tar.gz
-rw-rw-r-- 1 vagrant vagrant  634 May 31 08:14 java-8_282-distrib.tar.gz.lastUpdated
-rw-rw-r-- 1 vagrant vagrant 7925 May 31 08:14 java-8_282-distrib.tar.gz.sha1
-rw-rw-r-- 1 vagrant vagrant  350 May 31 07:59 java-8_282.pom
-rw-rw-r-- 1 vagrant vagrant  326 May 31 07:59 java-8_282.pom.lastUpdated
-rw-rw-r-- 1 vagrant vagrant   40 May 31 07:59 java-8_282.pom.sha1
-rw-rw-r-- 1 vagrant vagrant  199 May 31 08:14 _remote.repositories
```

[pom.xml](./src/pom.xml)

