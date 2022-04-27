FROM debian:latest as server
LABEL org.opencontainers.image.title="OFVp SSH Server"
LABEL org.opencontainers.image.description="SSH Server for OFVp"
LABEL org.opencontainers.image.vendor="ofvp_project"
LABEL org.opencontainers.image.licenses="GPL-3.0-or-later"
LABEL org.opencontainers.image.source="https://github.com/OFVp-Project/OpenSSH"

# Install core packages
ENV DEBIAN_FRONTEND="noninteractive"
RUN apt update && apt -y install wget curl git python3-minimal

# Install latest node
RUN VERSION=$(wget -qO- https://api.github.com/repos/Sirherobrine23/DebianNodejsFiles/releases/latest |grep 'name' | grep "nodejs"|grep "$(dpkg --print-architecture)"|cut -d '"' -f 4 | sed 's|nodejs_||g' | sed -e 's|_.*.deb||g'|sort | uniq|tail -n 1); wget -q "https://github.com/Sirherobrine23/DebianNodejsFiles/releases/download/debs/nodejs_${VERSION}_$(dpkg --print-architecture).deb" -O /tmp/nodejs.deb && dpkg -i /tmp/nodejs.deb && rm -rfv /tmp/nodejs.deb && npm install -g npm@latest

# Install Openssh Server
RUN apt update && \
  apt install -y openssh-server && \
  rm -fv /etc/ssh/sshd_config /etc/ssh/ssh_host_* && \
  ln -s -v /data/ssh_config.conf /etc/ssh/sshd_config && \
  ln -s -v /data/Banner.html /etc/ssh/banner

# Setup Project
ENV DAEMON_PASSWORD=""
ENV DAEMON_USER=""
ENV DAEMON_HOST="http://localhost:5000"
EXPOSE 22/tcp
VOLUME [ "/data" ]
WORKDIR /app
ENTRYPOINT [ "node", "--trace-warnings", "dist/index.js" ]
COPY package*.json ./
RUN npm install --no-save
COPY ./ ./
RUN npm run build