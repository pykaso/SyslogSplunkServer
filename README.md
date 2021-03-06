# SyslogSplunkForwarder for mobile applications
Syslog server with Splunk Universal Forwarder for Docker baked to allow remote logging from mobile applications. For easy iOS integration please check the [SwiftSyslog repository](https://github.com/pykaso/SwiftSyslog).

Syslog-ng is installed with all of its modules and preconfigured to listen on port **6514** with **TLS required** and client authentication disabled. If needed, You can use your own `syslog-ng.conf`.

The server is configured to accept only messages with the whitelisted access token. Whitelisted access tokens must be stored in `enabled_tokens.list` file. Default `enabled_tokens.list` file in docker container contains one testing token `"valid-token"`.

Accepted log entries are stored to `messages_${YEAR}-${MONTH}-${DAY}.log`  files in directory `/var/log/splunk` This directory should be mounted as volume to some other place.



Docker hub site: https://hub.docker.com/r/pykaso/mobile-syslog-splunk



## Requirements

- The X.509 certificate in PEM format on the syslog-ng server that identifies the server. Don't forget to set the `Common Name` parameter value to the hostname or the IP address of the server.
- The private key matching the certificate in PEM format

- Splunk Cloud account
- The "Universal forwarder credentials package". This package can be downloaded from your Splunk Cloud account.



## Setup

Create a new directory `cert.d` and copy your `serverkey.pem` and `servercert.pem` to it.

For whitelisting the mobile clients, create a new file named `enabled_tokens.list` and put here access tokens in a format You like. One token per line. You can use UUID for example.  There must be at least one token.

The created directory `cert.d`, file `enabled_tokens.list` and downloaded universal forwarder credentials package named `splunkclouduf.spl` are expected to be mounted to the docker container.

Admin password for Splunk forwarder used to setup admin account must be provided as environment variable named `SPLUNK_PASSWD`



## Using default configuration

By default syslog-ng will not print any debug messages to the console.

```
docker run --name syslog-splunk-forwarder -it -p 6514:6514 \
--env SPLUNK_PASSWD=securepasswd \
-v "/Users/pykaso/samples/syslog-ng-config/conf.d":/etc/syslog-ng/conf.d \
-v "/Users/pykaso/samples/splunk-forwarder/splunkclouduf.spl":"/install/splunkclouduf.spl" \
-v "/Users/pykaso/mobile-logs":/var/log/splunk pykaso/mobile-syslog-splunk
```



or with debug meesages output for syslog-ng server:

```
docker run --name syslog-splunk-forwarder -it -p 6514:6514 \
--env SPLUNK_PASSWD=securepasswd \
-v "/Users/pykaso/samples/syslog-ng-config/conf.d":/etc/syslog-ng/conf.d \
-v "/Users/pykaso/samples/splunk-forwarder/splunkclouduf.spl":"/install/splunkclouduf.spl" \
-v "/Users/pykaso/mobile-logs":/var/log/splunk pykaso/mobile-syslog-splunk -edv
```



## Using custom syslog-ng configuration

You can override the default configuration by mounting a configuration file under `/etc/syslog-ng/syslog-ng.conf`:

```
docker run --name syslog-splunk-forwarder -it -p 6514:6514 \
--env SPLUNK_PASSWD=securepasswd \
-v "/Users/pykaso/samples/syslog-ng-config/syslog-ng.conf":/etc/syslog-ng/syslog-ng.conf 
-v "/Users/pykaso/samples/syslog-ng-config/conf.d":/etc/syslog-ng/conf.d \
-v "/Users/pykaso/samples/splunk-forwarder/splunkclouduf.spl":"/install/splunkclouduf.spl" \
-v "/Users/pykaso/mobile-logs":/var/log/splunk pykaso/mobile-syslog-splunk
```



## Build

Clone this repository, enter to `docker-image` directory and run command below to build container locally.

```
docker build -t syslog-splunk .
```



## Test

To check if everything is working properly, try to send log testing message from command line. Message format is standard [Rfc5424](https://tools.ietf.org/html/rfc5424) message.

```
echo -e "<12>1 2020-04-15T12:25:07.748000+02:00 cmdline 0.0.0 - - [meta token=\"valid-token\"] Hello from command line" | openssl s_client -connect 0.0.0.0:6514
```



## The syslog message structure

Syslog message, defined by [Rfc5424](https://tools.ietf.org/html/rfc5424) is composed of a three parts:

- **header**

  - Priority
  - Version
  - Timestamp
  - Hostname
  - Application
  - Process id
  - Message id

- **structured data** - section with square brackets

- **message**

  

```
<priority>VERSION ISOTIMESTAMP HOSTNAME APPLICATION PID MESSAGEID [STRUCTURED-DATA] MESSAGE
```



## TODO

- Log rotation - for example, using cron on host computer.

  

  Example: remove files older than 30 days

  ```
  find /Users/pykaso/mobile-logs -daystart -type f -mtime +30 -exec rm {} \; 
  ```

  

  