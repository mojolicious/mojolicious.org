FROM perl:latest
WORKDIR /opt/mojo

COPY lib/ lib/
COPY public/ public/
COPY templates/ templates/
COPY fortune.txt .
COPY mojodocs.pl .
COPY mojolicious.pl .

# add data for git repo invalidation (from https://stackoverflow.com/a/39278224/468327)

ADD https://api.github.com/repos/mojolicious/sql-abstract-pg/git/refs/heads/main sql-abstract-pg.json
RUN cpanm -n git://github.com/mojolicious/sql-abstract-pg

ADD https://api.github.com/repos/mojolicious/mojo/git/refs/heads/main mojo.json
RUN cpanm -n git://github.com/mojolicious/mojo

ADD https://api.github.com/repos/mojolicious/mojo-pg/git/refs/heads/main mojo-pg.json
RUN cpanm -n git://github.com/mojolicious/mojo-pg

ADD https://api.github.com/repos/mojolicious/minion/git/refs/heads/main minion.json
RUN cpanm -n git://github.com/mojolicious/minion

EXPOSE 3000
ENTRYPOINT ["perl", "mojolicious.pl"]
CMD ["prefork"]

