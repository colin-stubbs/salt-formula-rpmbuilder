{# rpmbuilder #}

{% from "rpmbuilder/map.jinja" import rpmbuilder_settings with context %}

{# install packages #}
rpmbuild_packages:
  pkg.installed:
    - pkgs: {{ rpmbuilder_settings.lookup.packages }}

{# ensure users exist with appropriate content in rpmbuild location #}
{% if 'users' in rpmbuilder_settings %}
{% for user, user_options in rpmbuilder_settings.users.items() %}
{{ user }}:
  group.present:
    - name: {{ user }}
  user.present:
    - name: {{ user }}
    - home: {{ rpmbuilder_settings.lookup.locations.home_basedir }}/{{ user }}
    - require:
      - group: {{ user }}
{% for option, option_value in user_options.options.items()|default({}) %}
    - {{ option }}: {{ option_value }}
{% endfor %}

{% if 'gnupg' in user_options and 'source' in user_options.gnupg %}
user-{{ user }}-gnupg:
  file.recurse:
    - name: {{ rpmbuilder_settings.lookup.locations.home_basedir }}/{{ user }}/.gnupg
    - source: {{ user_options.gnupg.source }}
    - clean: True
    - user: {{ user }}
    - group: {{ user }}
    - dir_mode: 0700
    - recurse:
      - user
      - group
    - require:
      - group: {{ user }}
      - user: {{ user }}
{% endif %}

user-{{ user }}-rpmbuild:
  file.directory:
    - name: {{ rpmbuilder_settings.lookup.locations.home_basedir }}/{{ user }}/rpmbuild
    - makedirs: True
{% if 'rpmbuild' in user_options and 'source' in user_options.rpmbuild and user_options.rpmbuild.source != '' %}
    - source: {{ user_options.rpmbuild.source }}
{% endif %}
    - user: {{ user }}
    - group: {{ user }}
    - dir_mode: 0750
    - recurse:
      - user
      - group
      - mode
    - require:
      - group: {{ user }}
      - user: {{ user }}

user-{{ user }}-dot-rpmmacros:
  file.managed:
    - name: {{ rpmbuilder_settings.lookup.locations.home_basedir }}/{{ user }}/.rpmmacros
    - source: salt://rpmbuilder/files/rpmmacros
    - template: jinja
    - context:
      rpmmacros: {{ user_options.rpmmacros|default({}) }}
    - user: {{ user }}
    - group: {{ user }}
    - mode: 0600
    - require:
      - group: {{ user }}
      - user: {{ user }}

{% endfor %}
{% endif %}

{# EOF #}
