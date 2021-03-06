{% from 'vars.jinja' import server_env with context -%}

base:
  '*':
    - early-packages
    - update-packages
    - base-packages
    - service.firewall
    - service.network
    - auth.root
    - service.ssh
    - repo
    - misc
    - software.git
    - software.nodejs
    - software.npm
    # Doesn't seem to be installed, leaving here as a placemarker.
    # - service.salt-minion
    - service.ntp
    - service.postfix
    - service.prosody
    - service.nginx
    - service.jitsi-videobridge
    - service.jicofo
    - software.jitsi-meet
