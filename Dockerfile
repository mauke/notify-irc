from alpine:3.22.1 as base
run apk add --no-cache wget xz make gcc binutils libc-dev openssl-dev

from base as build
run mkdir -p /src \
    && cd /src \
    && wget https://www.cpan.org/src/5.0/perl-5.40.3.tar.gz \
    && tar xf perl-*.tar.gz \
    && cd perl-*/ \
    && ./Configure -Doptimize='-O2 -march=native' -Dman1dir=none -Dman3dir=none -Dprefix=/usr/local -des \
    && make -j$(nproc) \
    && make install DESTDIR=/tmp/perl \
    && cd /tmp/perl/usr/local \
    && tar cfJ /tmp/perl-usr-local.tar.xz .

from base
run apk add --no-cache openssl zlib zlib-dev
copy --from=build /tmp/perl-usr-local.tar.xz /tmp/
run mkdir -p /usr/local \
    && cd /usr/local \
    && tar xf /tmp/perl-usr-local.tar.xz \
    && rm /tmp/perl*.tar.xz \
    && wget -O- https://cpanmin.us/ | perl - App::cpanminus

workdir /app
run cpanm -n Net::SSLeay IO::Socket::SSL
run --mount=type=bind,source=cpanfile,target=cpanfile cpanm --installdeps . || { cat /root/.cpanm/work/*/build.log; false; }
copy notify-irc .

entrypoint ["perl", "notify-irc"]
