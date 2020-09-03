FROM ubuntu:latest as base
MAINTAINER Roxsen

ENV DEBIAN_FRONTEND noninteractive
RUN echo 'APT::Install-Recommends 0;' >> /etc/apt/apt.conf.d/01norecommends \
 && echo 'APT::Install-Suggests 0;' >> /etc/apt/apt.conf.d/01norecommends \
 && apt-get update \
 && sed -i 's/101/0/g' /usr/sbin/policy-rc.d \
 && apt-get install -y wget nano ca-certificates sudo cron python fontconfig openssh-client\
 && rm -rf /var/lib/apt/lists/* \
 && echo "export TERM=dumb" >> ~/.bashrc

FROM base

ENV FRAPPE_USER=frappe \
    MYSQL_PASSWORD=Pa55w0rD1! \
    ADMIN_PASSWORD=4DM1NPa55w0rD1! \
    DEBIAN_FRONTEND=noninteractive
RUN useradd $FRAPPE_USER && mkdir /home/$FRAPPE_USER && chown -R $FRAPPE_USER.$FRAPPE_USER /home/$FRAPPE_USER
WORKDIR /home/$FRAPPE_USER
RUN wget https://raw.githubusercontent.com/frappe/bench/master/playbooks/install.py && \
    sed -i -e 's,frappe/bench,lukptr/bench-docker,' install.py && apt update && \
    python install.py --production --user $FRAPPE_USER --mysql-root-password $MYSQL_PASSWORD --admin-password $ADMIN_PASSWORD && \
    su - $FRAPPE_USER -c "cd /home/$FRAPPE_USER/.bench && git remote set-url origin https://github.com/frappe/bench && \
    git fetch && git reset --hard origin/master" && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/ /home/$FRAPPE_USER/.cache
COPY production.conf /etc/supervisor/conf.d/
WORKDIR /home/$FRAPPE_USER/frappe-bench
EXPOSE 80

CMD ["/usr/bin/supervisord","-n"]
