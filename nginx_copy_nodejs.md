nginx:

# `sudo nano install_nginx.yml`
# - _File names before `.yml` are case insensitive._

# YAML/YML file to create a playbook to configure nginx in our web instance.
---
# it starts with three dashes
# psuedo-coding first:

# add the name of the host/instance/vm - we are letting the controller know who to talk to (remember the name of the host is case sensitive)
- hosts: web

# collect logs or gather facts - good to collect details so we can see what's happening
  gather_facts: yes

# we need admin access to install anything (become: true means anything we run will auto have sudo attached to it)
  become: true

# add the instructions for the actual task - i.e install nginx in web server (tasks are the instructions. The 'name' key is what the gather_facts will return. The name is not case sensitive, but the actua$  tasks:
  - name: Installing Nginx web-server in our app machine
    apt: pkg=nginx state=present

copy:
# yml file to copy over file
---

- hosts: web

  gather_facts: yes

  become: true

  tasks:
  - name: copying file over to web VM
    copy:
      src: /home/vagrant/app
      dest: /home/vagrant/

nodejs:
# installing nodejs and running
---
- hosts: web
  gather_facts: yes
  become: true
  tasks:
  - name: getting the right version of node for our app
    shell: curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
  - name: installing nodejs and npm
    apt:
      pkg:
        - nodejs
        - npm
  - name: running nnpm start
    shell: cd app; npm install; screen -d -m npm start