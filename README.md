# IAC with Ansible


### Let's create Vagrantfile to create Three VMs for Ansible architecture
#### Ansible controller and Ansible agents 

```

# -*- mode: ruby -*-
 # vi: set ft=ruby :
 
 # All Vagrant configuration is done below. The "2" in Vagrant.configure
 # configures the configuration version (we support older styles for
 # backwards compatibility). Please don't change it unless you know what
 
 # MULTI SERVER/VMs environment 
 #
 Vagrant.configure("2") do |config|
 # creating are Ansible controller
   config.vm.define "controller" do |controller|
     
    controller.vm.box = "bento/ubuntu-18.04"
    
    controller.vm.hostname = 'controller'
    
    controller.vm.network :private_network, ip: "192.168.33.12"
    
    # config.hostsupdater.aliases = ["development.controller"] 
    
   end 
 # creating first VM called web  
   config.vm.define "web" do |web|
     
     web.vm.box = "bento/ubuntu-18.04"
    # downloading ubuntu 18.04 image
 
     web.vm.hostname = 'web'
     # assigning host name to the VM
     
     web.vm.network :private_network, ip: "192.168.33.10"
     #   assigning private IP
     
     #config.hostsupdater.aliases = ["development.web"]
     # creating a link called development.web so we can access web page with this link instread of an IP   
         
   end
   
 # creating second VM called db
   config.vm.define "db" do |db|
     
     db.vm.box = "bento/ubuntu-18.04"
     
     db.vm.hostname = 'db'
     
     db.vm.network :private_network, ip: "192.168.33.11"
     
     #config.hostsupdater.aliases = ["development.db"]     
   end
 
 
 end
```
# Infrastructure-as-Code

Ansible Vault:
- Set up encrypted AWS access keys with Ansible Vault
- allows you to launch an ec2 instance
- Allows extra levels of security between the needed pem file as well as the encrypted AWS secret access keys
- The AWS secret access keys layer is separate. pem file allows you to SSH into an instance and do config management
- The secret keys allow you to launch any service, i.e instance or VPC
- You create a password for ansible vault

Steps:
- Create a new VM (not the old controller)
- set up ansible controller to use in hybrid from on prem to public cloud
- install required dependencies
- - python 3, pip3, awscli, ansible, boto boto3, tree (has specific order)
- create an alias python=python3
- use gitbash as admin (not vscode)
- aws --version
  
- set up ansible vault
- awc access & secret keys
- ansible-vault default folder structure
- create a file.yml to store aws keys
- set up permissions (chmod 600 file.yml)
- "ansible db -mping --ask-vault-pass" 
- --ask-vault-pass will 


`sudo apt-get update -y` 
`sudo apt-get upgrade -y` 
`sudo apt-get install tree` # installing tree package
`sudo apt-add-repository --yes --update ppa:ansible/ansible` # repository for ansible. Goes to ansible repository and adds it. Basically downloads the folder and specific version before we install
`sudo apt-get install ansible -y` 
`sudo apt-get install python3-pip -y` 

`pip3 install awscli`
`pip3 install boto boto3` # when using pip3, we can't add -y (-y is a linux command)

`sudo apt-get update -y`
`sudo apt-get upgrade -y` # to check if everything works and to check if anything we just installed needs updating/upgrading

`aws --version` # to check if everything works. Might need to logout and back in to have it reread env variables

`cd /etc/ansible/group_var/all/file.yml` # this is where we store the keys. Very specific folder structure. Below we can see how this is made specifically. 

`sudo mkdir group_vars`
`cd group_cars`
`sudo mkdir all`
`cd all`
`ansible-vault create pass.yml` # when we run that, its going to prompt us that we're in the VI editor. Need to press `i i` to get into insert mode
enter keys as so:
```
aws_access_key: xxxxx
aws_secret_key: xxxxx
```
`:wq!` to save
`:q!` to exit without saving
temp pass = 123

`sudo chmod 600 pass.yml` to change permissions
`ansible all -m ping` to see what happens. If there was something in the hosts file, we'd have to add `--ask-vault-pass`. Without this added part, ansible won't run the command for the cloud. Needs that authentication for cloud communication. Its also how ansible knows you want to communicate with the cloud instance and not the localhost

the order behind all these dependencies matters btw. Each command is needed for the next one to run properly. There are prerequisites and correct orders.

Task: Launch ex2 in ireland using ubuntu 18.04

`ansible-galaxy collection install amazon.aws`

```
---
- hosts: localhost
  connection: local
  gather_facts: yes
  vars_files:
  - /etc/ansible/group_vars/all/pass.yml
  vars:
    key_name: my_aws
    region: eu-west-1
    image: ami-07d8796a2b0f8d29c
    id: "karim-ansible"
    sec_group: "{{ id }}-sec"
    ansible_python_interpreter: /usr/bin/python3
  tasks:
    - name: Provisioning EC2 instances
      block:
      - name: Upload public key to AWS
        ec2_key:
          name: "{{ key_name }}"
          key_material: "{{ lookup('file', '~/.ssh/my_aws.pub') }}"
          region: "{{ region }}"
          aws_access_key: "{{aws_access_key}}"
          aws_secret_key: "{{aws_secret_key}}"
      - name: Create security group
        ec2_group:
          name: "{{ sec_group }}"
          description: "Sec group for app {{ id }}"
          region: "{{ region }}"
          aws_access_key: "{{aws_access_key}}"
          aws_secret_key: "{{aws_secret_key}}"
          rules:
            - proto: tcp
              ports:
                - 22
              cidr_ip: 0.0.0.0/0
              rule_desc: allow all on ssh port
            - proto: tcp
              ports:
                - 80
              cidr_ip: 0.0.0.0/0
              rule_desc: allow all on http port
        register: result_sec_group
      - name: Provision instance(s)
        ec2:
          aws_access_key: "{{aws_access_key}}"
          aws_secret_key: "{{aws_secret_key}}"
          key_name: "{{ key_name }}"
          id: "{{ id }}"
          group_id: "{{ result_sec_group.group_id }}"
          image: "{{ image }}"
          instance_type: t2.micro
          region: "{{ region }}"
          wait: true
          count: 1
          instance_tags:
            Name: eng103a_karim_ansible
      tags: ['never', 'create_ec2']
```
`sudo ansible-playbook ec2_app.yml --ask-vault-pass --tags create_ec2 --tags=ec2-create`

```

# LAUNCH EC2
---
- hosts: localhost
  connection: local
  gather_facts: yes
  vars_files:
  - /etc/ansible/group_vars/all/pass.yml
  vars:
    key_name: my_aws
    region: eu-west-1
    image: ami-07d8796a2b0f8d29c
    id: "karim_ansible_controller"
    sec_group: "{{ id }}-sec"
    ansible_python_interpreter: /usr/bin/python3

  tasks:
    - name: Provisioning EC2 instances
      block:
      - name: Upload public key to AWS
        ec2_key:
          name: "{{ key_name }}"
          key_material: "{{ lookup('file', '~/.ssh/my_aws.pub') }}"
          region: "{{ region }}"
          aws_access_key: "{{aws_access_key}}"
          aws_secret_key: "{{aws_secret_key}}"
      - name: Create security group
        ec2_group:
          name: "{{ sec_group }}"
          description: "Sec group for app {{ id }}"
          region: "{{ region }}"
          aws_access_key: "{{aws_access_key}}"
          aws_secret_key: "{{aws_secret_key}}"
          rules:
            - proto: tcp
              ports:
                - 22
              cidr_ip: 0.0.0.0/0
              rule_desc: allow all on ssh port
            - proto: tcp
              ports:
                - 80
              cidr_ip: 0.0.0.0/0
              rule_desc: allow all on http port
        register: result_sec_group
      - name: Provision instance(s)
        ec2:
          aws_access_key: "{{aws_access_key}}"
          aws_secret_key: "{{aws_secret_key}}"
          key_name: "{{ key_name }}"
          id: "{{ id }}"
          group_id: "{{ result_sec_group.group_id }}"
          image: "{{ image }}"
          instance_type: t2.micro
          region: "{{ region }}"
          wait: true
          count: 1
          instance_tags:
            Name: eng103a_karim_controller
      tags: ['never', 'create_ec2']


# PROVISION APP
---

- hosts: app
  gather_facts: yes
  become: true
  tasks:
  - name: copying file over to web VM
    copy:
      src: /home/ubuntu/contents
      dest: /home/ubuntu/

  - name: copying reverse proxy config over to web VM
    copy:
      src: /home/ubuntu/contents/default
      dest: /etc/nginx/sites-available/

  - name: set env var DB_HOST
    become_user: ubuntu
    lineinfile:
      path: /home/ubuntu/.bashrc
      line: export DB_HOST='mongodb://176.34.165.251:27017/posts'
      create: yes

  - name: download a specific version of nodejs
    shell: curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -

  - name: install the required packages (with downloaded nodejs downgrade)
    apt:
      pkg:
        - nginx
        - nodejs
        - npm
      update_cache: yes

  - name: nginx restart
    service: name=nginx state=restarted

  - name: nginx enable
    service: name=nginx enabled=yes

  - name: install and run the app
    #environment:
      #DB_HOST='mongodb://176.34.165.251:27017/posts'
    shell:
      cd app; npm install; node seeds/seed.js; screen -d -m npm start


# PROVISION DB
---

- hosts: db
  gather_facts: yes
  become: true
  tasks:
  - name: install mongodb
    apt:
      pkg:
        - mongodb
      update_cache: yes
  - name: set reverse proxy config
    lineinfile:
      path: /etc/mongodb.conf
      regexp: '^bind_ip = '
      line: 'bind_ip = 0.0.0.0'
    #copy:
      #src: /home/ubuntu/contents/mongod.conf
      #dest: /etc/mongodb.conf
  - name: enable mongodb
    shell:
      systemctl enable mongodb; systemctl restart mongodb

# HOSTS FILE

[app]
34.240.210.178 ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/appkey

[db]
176.34.165.251 ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/dbkey

# Launch Commands

cd /etc/ansible
sudo ansible-playbook ec2_db.yml --ask-vault-pass --tags create_ec2 --tags=ec2-create -vvv
sudo ansible-playbook provision_instances.yml --ask-vault-pass -vvv

# Other Commands 

scp -i <path to your access key>.pem -r <origin> ubuntu@ec2-3-250-15-190.eu-west-1.compute.amazonaws.com:~
ssh-keygen -t rsa -b 4096
```

test 2
