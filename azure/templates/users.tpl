users:
 - default
 - name: ${harsha_id}
   gecos: ${harsha_name}
   primary-group: users
   groups: ${user_group}
   shell: /bin/bash
   ssh_authorized_keys:
    - ${harsha_key}
