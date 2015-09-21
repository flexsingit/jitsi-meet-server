{% from 'vars.jinja' import
  jitsi_videobridge_password,
  jicofo_domain_password,
  jicofo_user_password,
  server_id
with context %}

include:
  - repo.jitsi
  - service.prosody

jitsi-meet-packages:
  pkg.installed:
    - pkgs:
      - default-jre
      - jicofo
      - jitsi-videobridge
      - nginx
    - require:
      - pkgrepo: jitsi-repo

/etc/prosody/conf.avail/{{ server_id }}.cfg.lua:
  file.managed:
    - source: salt://etc/prosody/conf.avail/domain.cfg.lua.jinja
    - template: jinja
    - context:
      server_id: {{ server_id }}
      jitsi_videobridge_password: {{ jitsi_videobridge_password }}
      jicofo_domain_password: {{ jicofo_domain_password }}
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: jitsi-meet-packages

symlink-prosody-config:
  file.symlink:
    - name: /etc/prosody/conf.d/{{ server_id }}.cfg.lua
    - target: /etc/prosody/conf.avail/{{ server_id }}.cfg.lua
    - require:
      - file: /etc/prosody/conf.avail/{{ server_id }}.cfg.lua

/etc/ssl/private/{{ server_id }}.key:
  file.managed:
    - source: salt://software/jitsi-meet/certs/server.key
    - user: root
    - group: ssl-cert
    - mode: 640

/etc/ssl/certs/{{ server_id }}.pem:
  file.managed:
    - user: root
    - group: root
    - mode: 644

build-{{ server_id }}-ssl-cert:
  file.append:
    - name: /etc/ssl/certs/{{ server_id }}.pem
    - sources:
      - salt://software/jitsi-meet/certs/server.crt
      - salt://software/jitsi-meet/certs/chain.pem

add-prosody-user:
  cmd.run:
    - name: prosodyctl register focus auth.{{ server_id }} {{ jicofo_user_password }}
    - unless: test -n "`prosodyctl mod_listusers | grep focus@auth.{{ server_id }}`"
    - require:
      - file: /usr/lib/prosody/modules/mod_listusers.lua

extend:
  prosody-service:
    service:
      - watch:
        - cmd: add-prosody-user
