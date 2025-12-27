# Ansible — Instruções para o LLM

Contexto: Automação de infraestrutura com playbooks idempotentes.

## Objetivo do assistant

- Gerar roles organizadas, playbooks com handlers, tasks idempotentes.
- Seguir ansible-lint e boas práticas.

## Estrutura esperada

### Role structure

```
roles/
└── webserver/
    ├── defaults/
    │   └── main.yml
    ├── handlers/
    │   └── main.yml
    ├── tasks/
    │   └── main.yml
    ├── templates/
    │   └── nginx.conf.j2
    ├── files/
    ├── vars/
    │   └── main.yml
    └── meta/
        └── main.yml
```

### Role: webserver

```yaml
# roles/webserver/defaults/main.yml
---
nginx_version: '1.24'
nginx_worker_processes: auto
nginx_worker_connections: 1024
nginx_client_max_body_size: '10M'
nginx_port: 80
nginx_ssl_port: 443
nginx_user: www-data
nginx_log_dir: /var/log/nginx
```

```yaml
# roles/webserver/vars/main.yml
---
nginx_config_path: /etc/nginx
nginx_sites_available: '{{ nginx_config_path }}/sites-available'
nginx_sites_enabled: '{{ nginx_config_path }}/sites-enabled'
```

```yaml
# roles/webserver/tasks/main.yml
---
- name: Install NGINX
  ansible.builtin.apt:
    name: nginx
    state: present
    update_cache: true
  become: true
  when: ansible_os_family == "Debian"

- name: Ensure NGINX config directory exists
  ansible.builtin.file:
    path: '{{ nginx_config_path }}'
    state: directory
    owner: root
    group: root
    mode: '0755'
  become: true

- name: Deploy NGINX configuration
  ansible.builtin.template:
    src: nginx.conf.j2
    dest: '{{ nginx_config_path }}/nginx.conf'
    owner: root
    group: root
    mode: '0644'
    validate: nginx -t -c %s
  become: true
  notify:
    - Reload NGINX

- name: Create log directory
  ansible.builtin.file:
    path: '{{ nginx_log_dir }}'
    state: directory
    owner: '{{ nginx_user }}'
    group: '{{ nginx_user }}'
    mode: '0755'
  become: true

- name: Enable NGINX service
  ansible.builtin.systemd:
    name: nginx
    enabled: true
    state: started
  become: true

- name: Configure firewall for HTTP/HTTPS
  community.general.ufw:
    rule: allow
    name: '{{ item }}'
  loop:
    - 'Nginx Full'
  become: true
  when: ansible_os_family == "Debian"
```

```yaml
# roles/webserver/handlers/main.yml
---
- name: Reload NGINX
  ansible.builtin.systemd:
    name: nginx
    state: reloaded
  become: true

- name: Restart NGINX
  ansible.builtin.systemd:
    name: nginx
    state: restarted
  become: true
```

```jinja2
# roles/webserver/templates/nginx.conf.j2
user {{ nginx_user }};
worker_processes {{ nginx_worker_processes }};
pid /run/nginx.pid;

events {
  worker_connections {{ nginx_worker_connections }};
}

http {
  sendfile on;
  tcp_nopush on;
  types_hash_max_size 2048;
  client_max_body_size {{ nginx_client_max_body_size }};

  include /etc/nginx/mime.types;
  default_type application/octet-stream;

  access_log {{ nginx_log_dir }}/access.log;
  error_log {{ nginx_log_dir }}/error.log;

  gzip on;
  gzip_vary on;
  gzip_types text/plain text/css application/json application/javascript;

  include {{ nginx_sites_enabled }}/*;
}
```

```yaml
# roles/webserver/meta/main.yml
---
galaxy_info:
  author: Your Name
  description: NGINX webserver role
  company: Your Company
  license: MIT
  min_ansible_version: '2.9'
  platforms:
    - name: Ubuntu
      versions:
        - focal
        - jammy
  galaxy_tags:
    - webserver
    - nginx

dependencies: []
```

### Playbook

```yaml
# playbooks/webserver.yml
---
- name: Configure webservers
  hosts: webservers
  become: true

  vars:
    nginx_port: 8080

  pre_tasks:
    - name: Update apt cache
      ansible.builtin.apt:
        update_cache: true
        cache_valid_time: 3600
      when: ansible_os_family == "Debian"

    - name: Gather service facts
      ansible.builtin.service_facts:

  roles:
    - role: webserver
      tags:
        - webserver
        - nginx

  post_tasks:
    - name: Verify NGINX is running
      ansible.builtin.uri:
        url: 'http://localhost:{{ nginx_port }}'
        status_code: 200
      delegate_to: localhost
      become: false
```

### Inventory

```ini
# inventory/production/hosts
[webservers]
web1.example.com ansible_host=192.168.1.10
web2.example.com ansible_host=192.168.1.11

[webservers:vars]
ansible_user=deploy
ansible_ssh_private_key_file=~/.ssh/deploy_rsa
ansible_python_interpreter=/usr/bin/python3
```

```yaml
# inventory/production/group_vars/webservers.yml
---
nginx_worker_processes: 4
nginx_worker_connections: 2048
nginx_client_max_body_size: '50M'

# Environment-specific settings
environment: production
log_level: warn
```

### ansible.cfg

```ini
[defaults]
inventory = inventory/production/hosts
remote_user = deploy
host_key_checking = False
retry_files_enabled = False
gathering = smart
fact_caching = jsonfile
fact_caching_connection = /tmp/ansible_facts
fact_caching_timeout = 3600
roles_path = ./roles
collections_paths = ./collections
stdout_callback = yaml
timeout = 30

[privilege_escalation]
become = True
become_method = sudo
become_user = root
become_ask_pass = False

[ssh_connection]
pipelining = True
ssh_args = -o ControlMaster=auto -o ControlPersist=60s
```

### .ansible-lint

```yaml
---
skip_list:
  - yaml[line-length]

use_default_rules: true

exclude_paths:
  - .venv/
  - molecule/
  - .cache/

warn_list:
  - experimental
  - no-changed-when

kinds:
  - yaml: '**/inventory/*/group_vars/*.yml'
  - yaml: '**/inventory/*/host_vars/*.yml'
```

### requirements.yml

```yaml
---
collections:
  - name: community.general
    version: '>=7.0.0'
  - name: ansible.posix
    version: '>=1.5.0'

roles:
  - name: geerlingguy.docker
    version: '6.1.0'
```

## Restrições

- **Idempotência**: tasks devem ser idempotentes (executar múltiplas vezes = mesmo resultado)
- **Modules**: SEMPRE prefira modules nativos sobre `shell`/`command`
- **become**: use apenas quando necessário (root operations)
- **Handlers**: use para restart/reload de serviços
- **Check mode**: tasks devem suportar `--check`
- **Tags**: adicione tags para execuções seletivas
- **Validation**: use `validate` parameter quando disponível
- **YAML**: 2 espaços de indentação
- **Naming**: names descritivos em tasks

## Comandos

```bash
# Lint
ansible-lint playbooks/webserver.yml

# Syntax check
ansible-playbook playbooks/webserver.yml --syntax-check

# Dry run (check mode)
ansible-playbook playbooks/webserver.yml --check

# Run playbook
ansible-playbook playbooks/webserver.yml

# Run with tags
ansible-playbook playbooks/webserver.yml --tags nginx

# Limit to specific hosts
ansible-playbook playbooks/webserver.yml --limit web1.example.com

# Install collections
ansible-galaxy collection install -r requirements.yml

# Ad-hoc command
ansible webservers -m ping
ansible webservers -m shell -a "systemctl status nginx"
```

## Saída esperada

1. Role com defaults, tasks, handlers, templates
2. Playbook com pre_tasks, roles, post_tasks
3. Inventory com group_vars
4. ansible.cfg configurado
5. .ansible-lint para validação
6. requirements.yml com dependencies
7. Comandos de execução e validação
