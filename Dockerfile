FROM alpine:3.5
MAINTAINER s7b4 <baron.stephane@gmail.com>

ENV APP_USER lstu
ENV APP_HOME /opt/$APP_USER
ENV APP_WORK /home/$APP_USER
ENV APP_TAG 0.08-2

# set user/group IDs
RUN addgroup $APP_USER && \
	adduser -G $APP_USER -D -H -s /bin/bash -h $APP_HOME $APP_USER

# Base
RUN apk --no-cache add bash \
		su-exec \
		ca-certificates \
		wget \
		openssl \
		tar \
		perl-dev \
		musl-dev \
		zlib-dev \
		sqlite \
		sqlite-dev \
		postgresql-dev \
		gcc \
		make && \
	PERL_MM_USE_DEFAULT=1 cpan install Carton && \
	rm -rf "$HOME/.cpan"*

# Install lstu
RUN mkdir -p $APP_HOME $APP_WORK && \
	wget -O - "https://framagit.org/luc/lstu/repository/archive.tar.gz?ref=$APP_TAG" \
		| tar xz --strip-component=1 -C $APP_HOME && \
	cd $APP_HOME && \
	make installdeps && \
	rm -rf "$HOME/.cpan"* && \
	rm -rf "$APP_HOME/log" "$APP_HOME/t"

COPY scripts/entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 8080
VOLUME $APP_WORK
