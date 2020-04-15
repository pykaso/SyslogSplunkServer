FROM balabit/syslog-ng
MAINTAINER admin@pykaso.net

ENV SPLUNK_VERSION 8.0.3
ENV SPLUNK_BUILD a6754d8441bf
ENV SPLUNK_NAME ${SPLUNK_VERSION}-${SPLUNK_BUILD}

RUN apt-get update && apt-get install -y procps

# syslog-ng
COPY ./syslog-ng-config/syslog-ng.conf /etc/syslog-ng/syslog-ng.conf
COPY ./syslog-ng-config/enabled_tokens.list /etc/syslog-ng/conf.d/enabled_tokens.list

# Universal Splunk forwarder
RUN mkdir -p /install
WORKDIR /install

RUN wget -O splunkforwarder-${SPLUNK_NAME}-linux-2.6-amd64.deb "https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=${SPLUNK_VERSION}&product=universalforwarder&filename=splunkforwarder-${SPLUNK_NAME}-linux-2.6-amd64.deb&wget=true" && dpkg -i splunkforwarder-${SPLUNK_NAME}-linux-2.6-amd64.deb

VOLUME ["/etc/syslog-ng", "/var/log/splunk"]

EXPOSE 6514/tcp

COPY start.sh start.sh

ENTRYPOINT ["/install/start.sh"]