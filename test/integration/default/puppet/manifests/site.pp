class { 'sssd':
  config => {
    'sssd'                => {
      'domains'             => 'example.test',
      'config_file_version' => 2,
      'services'            => ['nss', 'pam'],
    },
    'domain/example.test' => {
      'id_provider'      => 'ldap',
      'auth_provider'    => 'ldap',
      'ldap_uri'         => 'ldaps://ldap',
      'ldap_search_base' => 'dc=example,dc=test',
      'ldap_tls_cacert'  => '/etc/ldap-ca/ca.crt',
    },
  },
}
