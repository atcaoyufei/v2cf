FROM alpine

RUN apk update \
    && apk --no-cache add ca-certificates unzip \
    && wget -c -O /tmp/v2ray-linux-64.zip https://github.com/v2ray/v2ray-core/releases/latest/download/v2ray-linux-64.zip \
    && mkdir /etc/v2ray \
    && mkdir /tmp/v2ray \
    && unzip /tmp/v2ray-linux-64.zip -d /tmp/v2ray \
    && install -m 755 /tmp/v2ray/v2ray /usr/local/bin/v2ray \
    && install -m 755 /tmp/v2ray/v2ctl /usr/local/bin/v2ctl \
    && apk del wget unzip \
    && rm -rf /tmp/* \
    && v2ray -version

ADD config.json /etc/v2ray/config.json

CMD ["v2ray", "-config=/etc/v2ray/config.json"]
