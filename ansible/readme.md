# Ansible – Application Deployment Automation (Dynamic Inventory)

## 📌 Overview

This Ansible setup is used to **automate Docker-based application deployment** on AWS EC2 instances as part of a complete **CI/CD pipeline**.

Instead of a static `inventory.ini`, this project uses **AWS EC2 Dynamic Inventory** to automatically discover target servers using **EC2 tags**.

Ansible is triggered **indirectly by Jenkins** (via SSH into the Ansible Control Node) and performs:

* Docker installation (if required)
* Pulling the latest Docker image from Docker Hub
* Stopping and removing old containers
* Running the updated application container

This implementation follows **Infrastructure as Code (IaC)** and **cloud-native automation** best practices.

---

## 🏗 Architecture Role in CI/CD

**Pipeline Flow:**

```
GitHub → Jenkins → Docker Hub → Ansible → Docker Host → Application
```

* Jenkins builds and pushes the Docker image
* Jenkins SSHs into the Ansible Control Node
* Ansible dynamically discovers EC2 hosts using AWS tags
* Ansible deploys the container on the Docker Host
* Application is exposed via the Docker Host public IP

---

## 📂 Directory Structure

```
ansible/
├── inventory/
│   └── aws_ec2.yml
├── deploy-app.yml
├── jenkins-docker.yml
├── roles/
│   └── docker/
│       └── tasks/
│           └── main.yml
```

---

## 📄 Dynamic Inventory – aws_ec2.yml

This project uses the **AWS EC2 Dynamic Inventory plugin** to discover instances automatically.

📍 **AWS Region:** `us-east-1`
📍 **Project Tag:** `Devops-Capestone-project`

```yaml
# ansible/inventory/aws_ec2.yml
plugin: amazon.aws.aws_ec2

regions:
  - us-east-1

filters:
  tag:Project: Devops-Capestone-project
  instance-state-name: running

hostnames:
  - private-ip-address

keyed_groups:
  - key: tags.Name
    prefix: role
    separator: '_'

  - key: tags.Env
    prefix: env
    separator: '_'

  - key: tags.Project
    prefix: project
    separator: '_'

compose:
  ansible_host: private_ip_address
  ansible_user: ubuntu
  ansible_python_interpreter: /usr/bin/python3
```

### 🧠 Why Dynamic Inventory?

* No hardcoded IP addresses
* Automatically adapts to Terraform-created infrastructure
* Targets hosts based on tags like `Name`, `Env`, and `Project`
* Scales easily as infrastructure grows

---

## 📄 deploy-app.yml

Deploys the OnlineBookStore application container on the **Docker Host**, discovered dynamically.

```yaml
---
- name: Deploy OnlineBookStore Application
  hosts: role_docker
  become: yes

  tasks:
    - name: Deploy application container
      docker_container:
        name: onlinebookstore
        image: kishangollamudi/onlinebookstore:latest
        state: started
        restart_policy: always
        ports:
          - "8081:8080"
        recreate: yes
```

---

## 📄 jenkins-docker.yml

Installs and configures Docker on the **Jenkins EC2 instance** using dynamic inventory.

```yaml
---
- name: Install Docker on Jenkins server
  hosts: role_jenkins
  become: yes
  roles:
    - docker
```

---

## 📄 roles/docker/tasks/main.yml

Reusable Docker installation role used across multiple servers.

```yaml
---
- name: Install required system packages
  apt:
    name:
      - ca-certificates
      - curl
      - gnupg
      - lsb-release
      - python3-pip
    state: present
    update_cache: yes

- name: Install Docker
  apt:
    name: docker.io
    state: present

- name: Start and enable Docker
  systemd:
    name: docker
    state: started
    enabled: yes

- name: Install Docker SDK for Python
  pip:
    name: docker
    executable: pip3

- name: Add ubuntu user to docker group
  user:
    name: ubuntu
    groups: docker
    append: yes

- name: Add jenkins user to docker group
  user:
    name: jenkins
    groups: docker
    append: yes
```

---

## 🔐 SSH Prerequisites (Jenkins → Ansible)

From the **Jenkins server**, passwordless SSH access to the Ansible Control Node must be configured:

```bash
sudo -u jenkins ssh ubuntu@<ANSIBLE_CONTROL_IP>
```

If not configured:

```bash
sudo -u jenkins ssh-keygen
sudo -u jenkins ssh-copy-id ubuntu@<ANSIBLE_CONTROL_IP>
```

---

## ▶️ How to Run Manually (Optional)

From the Ansible Control Node:

```bash
ansible-playbook -i inventory/aws_ec2.yml deploy-app.yml
```

Validate dynamic inventory:

```bash
ansible-inventory -i inventory/aws_ec2.yml --graph
```

---

## 🌐 Application Access

Once deployment is complete, the application is available at:

```
http://<DOCKER_HOST_PUBLIC_IP>:8081
```

---

## ✅ Key DevOps Concepts Demonstrated

* Infrastructure as Code (IaC)
* AWS EC2 Dynamic Inventory
* Configuration Management with Ansible
* Dockerized application deployment
* Jenkins → Ansible integration
* Tag-based host targeting
* Secure SSH-based automation
* Zero-downtime container redeployment

---

## 📌 Notes

* No static IPs or inventories are used
* Infrastructure is discovered dynamically from AWS
* No secrets are hardcoded
* Credentials are managed in Jenkins
* Ansible is used strictly for deployment automation
* Jenkins does **not** install software directly
