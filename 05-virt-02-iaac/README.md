# Домашнее задание к занятию "5.2. Применение принципов IaaC в работе с виртуальными машинами"
## Задача 1

- Опишите своими словами основные преимущества применения на практике IaaC паттернов.

Позволяет более быстро осуществить процесс развертывания инфраструктуры для разработки,тестирования и масштабирования по мере необходимости.
Позволяет устранить разнородность конфигураций при использовании одинаковых сред разработки и тестирований.
Ускорение процесса разработки на всех этапах.

- Какой из принципов IaaC является основополагающим?

CI (Continuous Integration)Непрерывная интеграция (CI) — т.к. обеспечивает непрерывный, последовательный и автоматизированный способ разработки.

## Задача 2

- Чем Ansible выгодно отличается от других систем управление конфигурациями?

Простота и удобство использования, лёгкое управление, использование YAML и простота использования. Ansible достаточно удобен для выполнения сложных функций, а так же небольших проектов.
- Какой, на ваш взгляд, метод работы систем конфигурации более надёжный push или pull?

Определение метода зависит от поставленной задачи. Метод push более ценрализован и удобен для развертывания "одинаковых" систем. А для pull'а хост получает свою конфигурацию, что позволяет настраивать каждый хост отдельно.

## Задача 3

Установить на личный компьютер:

- VirtualBox
```
PS C:\Users\fulla\netology_devops\VIRT-PDC-1_HW\VM> vagrant provider
virtualbox
```
- Vagrant
```
PS C:\Users\fulla\netology_devops\VIRT-PDC-1_HW\VM> vagrant reload
==> server1.netology: Attempting graceful shutdown of VM...
==> server1.netology: Checking if box 'bento/ubuntu-20.04' version '202107.28.0' is up to date...
==> server1.netology: Clearing any previously set forwarded ports...
==> server1.netology: Clearing any previously set network interfaces...
==> server1.netology: Preparing network interfaces based on configuration...    server1.netology: Adapter 1: nat
    server1.netology: Adapter 2: hostonly
==> server1.netology: Forwarding ports...
    server1.netology: 22 (guest) => 20011 (host) (adapter 1)
    server1.netology: 22 (guest) => 2222 (host) (adapter 1)
==> server1.netology: Running 'pre-boot' VM customizations...
==> server1.netology: Booting VM...
==> server1.netology: Waiting for machine to boot. This may take a few minutes...
    server1.netology: SSH address: 127.0.0.1:2222
    server1.netology: SSH username: vagrant
    server1.netology: SSH auth method: private key
==> server1.netology: Machine booted and ready!
==> server1.netology: Checking for guest additions in VM...
==> server1.netology: Setting hostname...
==> server1.netology: Configuring and enabling network interfaces...
==> server1.netology: Mounting shared folders...
    server1.netology: /vagrant => C:/Users/fulla/netology_devops/VIRT-PDC-1_HW/VM
...
PS C:\Users\fulla\netology_devops\VIRT-PDC-1_HW\VM> vagrant ssh
Welcome to Ubuntu 20.04.2 LTS (GNU/Linux 5.4.0-80-generic x86_64)
...
Last login: Sat Jan 29 10:10:18 2022 from 10.0.2.2
vagrant@server1:~$
```
- Ansible
```
vagrant@server1:~$ ansible --version
ansible [core 2.12.1]
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/home/vagrant/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  ansible collection location = /home/vagrant/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/bin/ansible
  python version = 3.8.10 (default, Jun  2 2021, 10:49:15) [GCC 9.4.0]
  jinja version = 2.10.1
  libyaml = True
```
