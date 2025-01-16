#!/bin/bash

# Acessa o diretório correto
cd /home/ubuntu || exit 1

# Instalar pip
curl -fsSL https://bootstrap.pypa.io/get-pip.py -o get-pip.py
sudo python3 get-pip.py || { echo "Erro ao instalar o pip"; exit 1; }

# Instalar Ansible
sudo python3 -m pip install ansible || { echo "Erro ao instalar o Ansible"; exit 1; }

# Criar o Playbook
cat > playbook.yml <<EOT
---
- hosts: localhost
  tasks:
    - name: Instalando Python3 e virtualenv
      apt:
        pkg:
          - python3
          - virtualenv
        update_cache: yes
      become: yes

    - name: Git Clone
      ansible.builtin.git:
        repo: https://github.com/guilhermeonrails/clientes-leo-api
        dest: /home/ubuntu/tcc
        version: master
        force: yes

    - name: Instalando dependências com o pip (Django e Django Rest)
      pip:
        virtualenv: /home/ubuntu/tcc/venv/
        requirements: /home/ubuntu/tcc/requirements.txt

    - name: Alterando o Host do settings
      lineinfile:
        path: /home/ubuntu/tcc/setup/settings.py
        regexp: 'ALLOWED_HOSTS'
        line: 'ALLOWED_HOSTS = ["*"]'
        backrefs: yes

    - name: Configurando o banco de dados
      shell: |
        . /home/ubuntu/tcc/venv/bin/activate
        python /home/ubuntu/tcc/manage.py migrate

    - name: Carregando os dados iniciais
      shell: |
        . /home/ubuntu/tcc/venv/bin/activate
        python /home/ubuntu/tcc/manage.py loaddata clientes.json

    - name: Alterando o horário
      lineinfile:
        path: /home/ubuntu/tcc/setup/settings.py
        regexp: 'LANGUAGE_CODE'
        line: "LANGUAGE_CODE = 'pt-br'"
        backrefs: yes

    - name: Iniciando o Servidor
      shell: |
        . /home/ubuntu/tcc/venv/bin/activate
        nohup python /home/ubuntu/tcc/manage.py runserver 0.0.0.0:8000 > /home/ubuntu/tcc/server.log 2>&1 &

    - name: Criando uma pasta
      shell: "mkdir /home/ubuntu/pasta-teste"
EOT

# Executar o Playbook
sudo ansible-playbook playbook.yml
