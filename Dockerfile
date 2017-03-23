FROM alpine:3.5
LABEL maintainer "s7b4 <baron.stephane@gmail.com>"

ENV APP_USER lstu
ENV APP_HOME /opt/$APP_USER
ENV APP_WORK /home/$APP_USER
ENV APP_TAG 0.08-2

# set user/group IDs
RUN addgroup $APP_USER && \
	adduser -G $APP_USER -D -H -s /bin/bash -h $APP_HOME $APP_USER

# Base
RUN apk --no-cache --upgrade add \
		su-exec \
		ca-certificates \
		wget \
		tar \
		perl \
		perl-dev \
		zlib \
		sqlite \
		gcc \
		make \
		libressl \
		musl-dev \
		sqlite-libs \
		postgresql-libs \
		libressl2.4-libtls \
	&& PERL_MM_USE_DEFAULT=1 cpan install Carton >/dev/null \
	&& rm -rf "$HOME/.cpan"*

# Install lstu
RUN mkdir -p $APP_HOME $APP_WORK \
	&& wget -O - "https://framagit.org/luc/lstu/repository/archive.tar.gz?ref=$APP_TAG" \
		| tar xz --strip-component=1 -C $APP_HOME \
	&& cd $APP_HOME \
	&& apk --no-cache --upgrade add \
		sqlite-dev \
		postgresql-dev \
		zlib-dev \
	&& make installdeps \
	&& apk --no-cache del \
		sqlite-dev \
		postgresql-dev \
		zlib-dev \
	&& rm -rf "$APP_HOME/log" "$APP_HOME/t" \
	&& rm -rf "$HOME/.cpan"*

COPY scripts/entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 8080
VOLUME $APP_WORK
