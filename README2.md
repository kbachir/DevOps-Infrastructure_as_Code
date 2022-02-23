# IaC

## Ansible and Terraform
- Configuration Management 
- Orchestration
- Push Config - Ansible to push config
- Terraform for Orchestration
- Ansible YAML/YML.file

### Setting up Ansible Controller

- Install required dependencies i.e Python
- Install Ansible
- Tree
- Set up the agent nodes
- Default folder structures etc/ansible
- Hosts file - agent node called IP of the web

### Controller Setup:

`sudo apt-get install software-properties-common -y` 
`sudo apt-add-repository ppa:ansible/ansible -y`
`sudo apt-get install ansible -y`
`sudo apt-get install tree -y`
`ansible --version` 
```
ssh vagrant@192.168.33.10
password: vagrant
```

This is how we'll get into the web or db VMs through the controller

`ping <IP>` to ping and check if the node is reachable

`ansible web -m ping`
web = name of VM
-m = module
-a = argument
- Can use 'all' in place of 'web' to check all VMs

### Hosts Setup & Informing Controller of Nodes

in /etc/ansible: `tree`, `sudo nano hosts`, in here we can add IPs for node instances. 
- Do this by [header name] followed by the list of IPs.
- We can add `ansible_connection=ssh ansible_ssh_user=vagrant ansible_ssh_pass=vagrant`.
This is defining pre-existing variables and telling ansible that it should use these parameters to ping the VM.
- Without these, it will deny you permission as there is no ssh key/password specified.
- This only works if the VM fingerprint has been added already.

### Ansible Playbooks

- They are YAML/yml files with scripts to implement configuration management
- Playbooks are reusable, meaning they can be used for multiple instances with us only needing to change the IP/path
- They save us time 
- We can create a playbook by using `filename.yml` or `filename.yaml`
- YAML files start with three dashes `---`. YAML files can be used for Docker, Kubernetes and other services. YAML is a very useful language.

```
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

# add the instructions for the actual task - i.e install nginx in web server (tasks are the instructions. The 'name' key is what the gather_facts will return. The name is not case sensitive, but the actual instruction under is. pkg=package, state=check status)
  tasks: 
  - name: Installing Nginx web-server in our app machine
    apt: pkg=nginx state=present

# HINT: be mindful of indentation 
# best practice is to use 2 spaces - avoid using tab. 

# [To run, we use `ansible-playbook install_nginx.yml`]

# We can then check status with `ansible web -a "systemctl status nginx"`, and if we check the IP of web, we'll see nginx installed!
```

If we want to migrate these to AWS, here's what we do:
- Update the hosts file with the correct IPs of the instances through 

### Ansible Adhoc Commands

`ansible all -a "uname -a"` will return the name of all servers
-a = relates to system (?)
`ansible all -a "free"`
`ansible all -a "uptime"`
`ansible all -m copy -a "src=/filepath/filename.txt dest=/filepath/filename.txt`
