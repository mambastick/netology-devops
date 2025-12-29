# Работа с roles

[Оригинальное задание тут](https://github.com/netology-code/mnt-homeworks/tree/MNT-video/08-ansible-04-role)

[Основная часть (Playbook) (release 08.04)](https://github.com/mambastick/netology-ansible/releases/tag/08.04)

[Vector (Ansible Role) (release 1.0.0)](https://github.com/mambastick/netology-vector-role)

[Lighthouse (Ansible Role) (release 1.0.1)](https://github.com/mambastick/netology-lighthouse-role/releases/tag/1.0.1)

# Скриншоты выполнения
![Lighthouse demo](images/image.png)
![Clickhouse demo](images/image-1.png)
![Ansible playbook demo](images/image-2.png)

# Полный лог работы playbook
```ansible
golodniy@golodniy-book:~/Документы/Projects/netology-ansible$ ansible-playbook -i ./inventory/prod.yml ./site.yml

PLAY [Install Clickhouse] *********************************************************************************************************

TASK [Gathering Facts] ************************************************************************************************************
[WARNING]: Host 'clickhouse-01' is using the discovered Python interpreter at '/usr/bin/python3.9', but future installation of another Python interpreter could cause a different interpreter to be discovered. See https://docs.ansible.com/ansible-core/2.20/reference_appendices/interpreter_discovery.html for more information.
ok: [clickhouse-01]

TASK [clickhouse : Include OS Family Specific Variables] **************************************************************************
[WARNING]: Deprecation warnings can be disabled by setting `deprecation_warnings=False` in ansible.cfg.
[DEPRECATION WARNING]: INJECT_FACTS_AS_VARS default to `True` is deprecated, top-level facts will not be auto injected after the change. This feature will be removed from ansible-core version 2.24.
Origin: /home/golodniy/Документы/Projects/netology-ansible/roles/clickhouse/tasks/main.yml:8:11

6     params:
7       files:
8         - "{{ ansible_os_family | lower }}.yml"
            ^ column 11

Use `ansible_facts["fact_name"]` (no `ansible_` prefix) instead.

ok: [clickhouse-01]

TASK [clickhouse : include_tasks] *************************************************************************************************
included: /home/golodniy/Документы/Projects/netology-ansible/roles/clickhouse/tasks/precheck.yml for clickhouse-01

TASK [clickhouse : Requirements check | Checking sse4_2 support] ******************************************************************
ok: [clickhouse-01]

TASK [clickhouse : Requirements check | Not supported distribution && release] ****************************************************
skipping: [clickhouse-01]

TASK [clickhouse : include_tasks] *************************************************************************************************
included: /home/golodniy/Документы/Projects/netology-ansible/roles/clickhouse/tasks/params.yml for clickhouse-01

TASK [clickhouse : Set clickhouse_service_enable] *********************************************************************************
ok: [clickhouse-01]

TASK [clickhouse : Set clickhouse_service_ensure] *********************************************************************************
ok: [clickhouse-01]

TASK [clickhouse : include_tasks] *************************************************************************************************
included: /home/golodniy/Документы/Projects/netology-ansible/roles/clickhouse/tasks/install/dnf.yml for clickhouse-01

TASK [clickhouse : Install by YUM | Ensure clickhouse repo GPG key imported] ******************************************************
ok: [clickhouse-01]

TASK [clickhouse : Install by YUM | Ensure clickhouse repo installed] *************************************************************
ok: [clickhouse-01]

TASK [clickhouse : Install by YUM | Ensure clickhouse package installed (latest)] *************************************************
skipping: [clickhouse-01]

TASK [clickhouse : Install by YUM | Ensure clickhouse package installed (version 22.3.3.44)] **************************************
ok: [clickhouse-01]

TASK [clickhouse : include_tasks] *************************************************************************************************
included: /home/golodniy/Документы/Projects/netology-ansible/roles/clickhouse/tasks/configure/sys.yml for clickhouse-01

TASK [clickhouse : Check clickhouse config, data and logs] ************************************************************************
ok: [clickhouse-01] => (item=/var/log/clickhouse-server)
ok: [clickhouse-01] => (item=/etc/clickhouse-server)
ok: [clickhouse-01] => (item=/var/lib/clickhouse/tmp/)
ok: [clickhouse-01] => (item=/var/lib/clickhouse/)

TASK [clickhouse : Config | Create config.d folder] *******************************************************************************
ok: [clickhouse-01]

TASK [clickhouse : Config | Create users.d folder] ********************************************************************************
ok: [clickhouse-01]

TASK [clickhouse : Config | Generate system config] *******************************************************************************
ok: [clickhouse-01]

TASK [clickhouse : Config | Generate users config] ********************************************************************************
ok: [clickhouse-01]

TASK [clickhouse : Config | Generate remote_servers config] ***********************************************************************
skipping: [clickhouse-01]

TASK [clickhouse : Config | Generate macros config] *******************************************************************************
skipping: [clickhouse-01]

TASK [clickhouse : Config | Generate zookeeper servers config] ********************************************************************
skipping: [clickhouse-01]

TASK [clickhouse : Config | Remove default http_port from base config] ************************************************************
ok: [clickhouse-01]

TASK [clickhouse : Config | Remove default tcp_port from base config] *************************************************************
ok: [clickhouse-01]

TASK [clickhouse : Config | Fix interserver_http_port and intersever_https_port collision] ****************************************
skipping: [clickhouse-01]

TASK [clickhouse : Notify Handlers Now] *******************************************************************************************

TASK [clickhouse : include_tasks] *************************************************************************************************
included: /home/golodniy/Документы/Projects/netology-ansible/roles/clickhouse/tasks/service.yml for clickhouse-01

TASK [clickhouse : Ensure clickhouse-server.service is enabled: True and state: started] ******************************************
ok: [clickhouse-01]

TASK [clickhouse : Wait for Clickhouse Server to Become Ready] ********************************************************************
ok: [clickhouse-01]

TASK [clickhouse : include_tasks] *************************************************************************************************
included: /home/golodniy/Документы/Projects/netology-ansible/roles/clickhouse/tasks/configure/db.yml for clickhouse-01

TASK [clickhouse : Set ClickHose Connection String] *******************************************************************************
ok: [clickhouse-01]

TASK [clickhouse : Gather list of existing databases] *****************************************************************************
ok: [clickhouse-01]

TASK [clickhouse : Config | Delete database config] *******************************************************************************
skipping: [clickhouse-01] => (item={'name': 'logs'}) 
skipping: [clickhouse-01]

TASK [clickhouse : Config | Create database config] *******************************************************************************
skipping: [clickhouse-01] => (item={'name': 'logs'}) 
skipping: [clickhouse-01]

TASK [clickhouse : include_tasks] *************************************************************************************************
included: /home/golodniy/Документы/Projects/netology-ansible/roles/clickhouse/tasks/configure/dict.yml for clickhouse-01

TASK [clickhouse : Config | Generate dictionary config] ***************************************************************************
skipping: [clickhouse-01]

TASK [clickhouse : include_tasks] *************************************************************************************************
skipping: [clickhouse-01]

PLAY [Install Vector] *************************************************************************************************************

TASK [Gathering Facts] ************************************************************************************************************
[WARNING]: Host 'vector-01' is using the discovered Python interpreter at '/usr/bin/python3.9', but future installation of another Python interpreter could cause a different interpreter to be discovered. See https://docs.ansible.com/ansible-core/2.20/reference_appendices/interpreter_discovery.html for more information.
ok: [vector-01]

TASK [vector : Vector | Download package] *****************************************************************************************
ok: [vector-01]

TASK [vector : Vector | Install package] ******************************************************************************************
ok: [vector-01]

TASK [vector : Vector | Ensure config directory exists] ***************************************************************************
[DEPRECATION WARNING]: INJECT_FACTS_AS_VARS default to `True` is deprecated, top-level facts will not be auto injected after the change. This feature will be removed from ansible-core version 2.24.
Origin: /home/golodniy/Документы/Projects/netology-ansible/roles/vector/defaults/main.yml:12:22

10 vector_config_dir: "/etc/vector"
11 vector_config_owner: "{{ ansible_user_id }}"
12 vector_config_group: "{{ ansible_user_gid }}"
                        ^ column 22

Use `ansible_facts["fact_name"]` (no `ansible_` prefix) instead.

[DEPRECATION WARNING]: INJECT_FACTS_AS_VARS default to `True` is deprecated, top-level facts will not be auto injected after the change. This feature will be removed from ansible-core version 2.24.
Origin: /home/golodniy/Документы/Projects/netology-ansible/roles/vector/defaults/main.yml:11:22

 9
10 vector_config_dir: "/etc/vector"
11 vector_config_owner: "{{ ansible_user_id }}"
                        ^ column 22

Use `ansible_facts["fact_name"]` (no `ansible_` prefix) instead.

ok: [vector-01]

TASK [vector : Vector | Deploy configuration] *************************************************************************************
ok: [vector-01]

TASK [vector : Vector | Install systemd unit] *************************************************************************************
ok: [vector-01]

TASK [vector : Vector | Ensure service enabled] ***********************************************************************************
ok: [vector-01]

PLAY [Install Lighthouse] *********************************************************************************************************

TASK [Gathering Facts] ************************************************************************************************************
[WARNING]: Host 'lighthouse-01' is using the discovered Python interpreter at '/usr/bin/python3.9', but future installation of another Python interpreter could cause a different interpreter to be discovered. See https://docs.ansible.com/ansible-core/2.20/reference_appendices/interpreter_discovery.html for more information.
ok: [lighthouse-01]

TASK [lighthouse : include_tasks] *************************************************************************************************
included: /home/golodniy/Документы/Projects/netology-ansible/roles/lighthouse/tasks/clone_repository.yml for lighthouse-01

TASK [lighthouse : Lighthouse | Clone repository] *********************************************************************************
[DEPRECATION WARNING]: INJECT_FACTS_AS_VARS default to `True` is deprecated, top-level facts will not be auto injected after the change. This feature will be removed from ansible-core version 2.24.
Origin: /home/golodniy/Документы/Projects/netology-ansible/roles/lighthouse/defaults/main.yml:3:17

1 ---
2 # defaults file for lighthouse-role
3 lighthouse_dir: "/home/{{ ansible_user_id }}/lighthouse"
                  ^ column 17

Use `ansible_facts["fact_name"]` (no `ansible_` prefix) instead.

ok: [lighthouse-01]

PLAY RECAP ************************************************************************************************************************
clickhouse-01              : ok=26   changed=0    unreachable=0    failed=0    skipped=10   rescued=0    ignored=0   
lighthouse-01              : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
vector-01                  : ok=7    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```