FROM debian:13-slim

RUN echo 'slapd slapd/domain string example.test' | debconf-set-selections \
 && echo 'slapd shared/organization string Example' | debconf-set-selections \
 && echo 'slapd slapd/password1 password admin' | debconf-set-selections \
 && echo 'slapd slapd/password2 password admin' | debconf-set-selections \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends slapd ldap-utils openssl \
 && apt-get clean

COPY start.sh users.ldif /srv/
CMD ["/bin/sh", "/srv/start.sh"]
