FROM perl:latest
WORKDIR /opt/mojo

COPY lib/ lib/
COPY public/ public/
COPY templates/ templates/
COPY fortune.txt .
COPY mojodocs.pl .
COPY mojolicious.pl .

#NOTE use --no-cache to prevent caching
RUN cpanm -n https://github.com/mojolicious/sql-abstract-pg/archive/refs/heads/main.tar.gz \
  && cpanm -n https://github.com/mojolicious/mojo/archive/refs/heads/main.tar.gz \
  && cpanm -n https://github.com/mojolicious/mojo-pg/archive/refs/heads/main.tar.gz \
  && cpanm -n https://github.com/mojolicious/minion/archive/refs/heads/main.tar.gz

EXPOSE 3000
ENTRYPOINT ["perl", "mojolicious.pl"]
CMD ["prefork"]

