#!/bin/sh
# Test directory for the integration tests: LDAPS with a fresh CA, which is
# published in /ca for the clients, and the users from users.ldif.
set -e

cd /etc/ldap
openssl req -x509 -newkey rsa:2048 -nodes -days 7 -subj '/CN=Test CA' \
  -keyout ca.key -out /ca/ca.crt 2>/dev/null
openssl req -newkey rsa:2048 -nodes -subj '/CN=ldap' -keyout ldap.key -out ldap.csr 2>/dev/null
printf 'subjectAltName=DNS:ldap\n' > ldap.ext
openssl x509 -req -in ldap.csr -CA /ca/ca.crt -CAkey ca.key -CAcreateserial -days 7 \
  -extfile ldap.ext -out ldap.crt 2>/dev/null
chown openldap ldap.key
chmod 0644 /ca/ca.crt
install -d -o openldap -g openldap /run/slapd

slapd -h 'ldapi:///' -u openldap -g openldap
until ldapsearch -Q -Y EXTERNAL -H ldapi:/// -b cn=config -s base >/dev/null 2>&1; do sleep 1; done
ldapmodify -Q -Y EXTERNAL -H ldapi:/// <<LDIF
dn: cn=config
changetype: modify
replace: olcTLSCACertificateFile
olcTLSCACertificateFile: /ca/ca.crt
-
replace: olcTLSCertificateFile
olcTLSCertificateFile: /etc/ldap/ldap.crt
-
replace: olcTLSCertificateKeyFile
olcTLSCertificateKeyFile: /etc/ldap/ldap.key
LDIF
sed "s|@PASSWORD@|$(slappasswd -s secret)|" /srv/users.ldif \
  | ldapadd -x -D cn=admin,dc=example,dc=test -w admin -H ldapi:///
kill "$(cat /run/slapd/slapd.pid)"
while [ -e /run/slapd/slapd.pid ]; do sleep 1; done

exec slapd -h 'ldapi:/// ldaps:///' -u openldap -g openldap -d 0
