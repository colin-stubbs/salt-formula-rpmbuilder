rpmbuilder:
  lookup:
    locations:
      home_basedir: /srv/nfs/home
  users:
    rpmbuilder:
      rpmbuild:
        source: salt://rpmbuilder/files/rpmbuild
      rpmmacros:
        _topdir: '%(echo $HOME)/rpmbuild'
        packager: 'Your Name <email>'
        vendor: 'Your Organisation'
        _signature: gpg
        _gpg_name: 'Some GPG Key'
      options:
        fullname: RPM Builder
        shell: /bin/bash
