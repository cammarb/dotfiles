FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y bash sudo

COPY installer.sh /usr/local/bin/installer.sh

RUN chmod +x /usr/local/bin/installer.sh

CMD ["bash", "/usr/local/bin/installer.sh"]
