# sssd

[![Puppet Forge](https://img.shields.io/puppetforge/v/sgnl05/sssd.svg)](https://forge.puppetlabs.com/sgnl05/sssd)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/sgnl05/sssd.svg)](https://forge.puppetlabs.com/sgnl05/sssd)
[![Puppet Forge Score](https://img.shields.io/puppetforge/f/sgnl05/sssd.svg)](https://forge.puppetlabs.com/sgnl05/sssd/scores)

#### Table of Contents

1. [Overview](#overview)
2. [Usage - Configuration options and additional functionality](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)
5. [Credits](#credits)

## Overview

This module installs and configures SSSD (System Security Services Daemon)

[SSSD][0] is used to provide access to identity and authentication remote resource through a common framework that can provide caching and offline support to the system.

## Documented with Puppet Strings

[Puppet Strings documentation](http://sgnl05.github.io/sgnl05-sssd/doc/)

## Usage

Example configuration:

```puppet
class {'::sssd':
  config => {
    'sssd' => {
      'domains'             => 'ad.example.com',
      'config_file_version' => 2,
      'services'            => ['nss', 'pam'],
    },
    'domain/ad.example.com' => {
      'ad_domain'                      => 'ad.example.com',
      'ad_server'                      => ['server01.ad.example.com', 'server02.ad.example.com'],
      'krb5_realm'                     => 'AD.EXAMPLE.COM',
      'realmd_tags'                    => 'joined-with-samba',
      'cache_credentials'              => true,
      'id_provider'                    => 'ad',
      'krb5_store_password_if_offline' => true,
      'default_shell'                  => '/bin/bash',
      'ldap_id_mapping'                => false,
      'use_fully_qualified_names'      => false,
      'fallback_homedir'               => '/home/%d/%u',
      'access_provider'                => 'simple',
      'simple_allow_groups'            => ['admins', 'users'],
    }
  }
}
```

...or the same config in Hiera:

```yaml
sssd::config:
  'sssd':
    'domains': 'ad.example.com'
    'config_file_version': 2
    'services':
      - 'nss'
      - 'pam'
  'domain/ad.example.com':
    'ad_domain': 'ad.example.com'
    'ad_server':
      - 'server01.ad.example.com'
      - 'server02.ad.example.com'
    'krb5_realm': 'AD.EXAMPLE.COM'
    'realmd_tags': 'joined-with-samba'
    'cache_credentials': true
    'id_provider': 'ad'
    'krb5_store_password_if_offline': true
    'default_shell': '/bin/bash'
    'ldap_id_mapping': false
    'use_fully_qualified_names': false
    'fallback_homedir': '/home/%d/%u'
    'access_provider': 'simple'
    'simple_allow_groups':
      - 'admins'
      - 'users'
```

Will be represented in sssd.conf like this:

```ini
[sssd]
domains = ad.example.com
config_file_version = 2
services = nss, pam

[domain/ad.example.com]
ad_domain = ad.example.com
ad_server = server01.ad.example.com, server02.ad.example.com
krb5_realm = AD.EXAMPLE.COM
realmd_tags = joined-with-samba
cache_credentials = true
id_provider = ad
krb5_store_password_if_offline = true
default_shell = /bin/bash
ldap_id_mapping = false
use_fully_qualified_names = false
fallback_homedir = /home/%d/%u
access_provider = simple
simple_allow_groups = admins, users
```

Tip: Using 'ad' as `id_provider` require you to run 'adcli join domain' on the target node. *adcli join* creates a computer account in the domain for the local machine, and sets up a keytab for the machine.

Example:

```bash
$ sudo adcli join ad.example.com
```

Or you can use a relevant [module][1] for automation.

## Limitations

This module requires OpenVox 8.

### Tested on

* Debian 12 and 13
* EL 8 and 9
* SLES 15
* Ubuntu 22.04 and 24.04

The integration tests log in as an LDAP user on Debian 12 and 13, Ubuntu 24.04,
Rocky Linux 9 and SLES 15.

### May work with

These platforms are end of life (EOL) and once worked with the module
and probably still do. We keep the data for them and if you use them a
warning will appear instead of a failure.

* Amazon Linux 2
* Debian 7 to 11
* EL 5 to 7
* Fedora 26 to 33
* Gentoo 3 and 4
* Suse 11 and 12
* Ubuntu 14.04 to 20.04

## Development

```sh
bundle install
bundle exec rake test rubocop
```

The integration tests apply the module with test-kitchen in systemd containers
against the LDAP server from `test/ldap`:

```sh
docker network create kitchen
docker build -t sssd-test-ldap test/ldap
docker run -d --name ldap --network kitchen -v ldap-ca:/ca sssd-test-ldap
bundle exec kitchen test
```

OpenVox ships SLES packages for x86_64 only. On other hosts, enable amd64 emulation
before running the SLES platform, e.g. `docker run --privileged --rm tonistiigi/binfmt --install amd64`.

## Versioning
The v1 series of this module will support both Puppet v3 and v4. The v2
series of this module will drop support for Puppet v3.

## Credits

* sssd.conf template from [walkamongus-sssd][2] by Chadwick Banning
* See `CHANGELOG.md` file for additional credits

[0]: https://docs.pagure.org/SSSD.sssd/
[1]: https://forge.puppet.com/modules?sort=rank&q=adcli
[2]: https://github.com/walkamongus/sssd
