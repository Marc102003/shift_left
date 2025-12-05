FROM registry.access.redhat.com/ubi7/ubi:7.7

# Variable d'entorn
ENV JBOSS_HOME=/opt/jboss

# Copiar JBoss EAP
COPY jboss-eap-7.2.0.zip /tmp/jboss-eap-7.2.0.zip

# Instal·lació de Java i eines, creació usuari jboss, descompressió JBoss
RUN yum -y install java-1.8.0-openjdk-headless unzip openssl passwd \
    && yum clean all \
    && rm -rf /var/cache/yum \
    \
    && useradd -r -s /sbin/nologin jboss \
    && echo "jboss:password" | chpasswd \
    && usermod -aG wheel jboss \
    \
    && unzip /tmp/jboss-eap-7.2.0.zip -d /opt \
    && rm -f /tmp/jboss-eap-7.2.0.zip \
    && mv /opt/jboss-eap-7.2 ${JBOSS_HOME} \
    \
    && ${JBOSS_HOME}/bin/add-user.sh admin admin123 --silent \
    \
    && echo 'JAVA_OPTS="$JAVA_OPTS -Djboss.bind.address=0.0.0.0 -Djboss.bind.address.management=0.0.0.0"' >> ${JBOSS_HOME}/bin/standalone.conf \
    \
    && chown -R jboss:0 ${JBOSS_HOME} \
    && chmod -R 775 ${JBOSS_HOME} \
    \
    && yum clean all \
    && rm -rf /var/cache/yum /tmp/*

# Exposar ports dins del contenidor
EXPOSE 8080 9990 9090

# Canviar a usuari jboss
USER jboss

# Comanda d’arrencada
CMD ["/opt/jboss/bin/standalone.sh", "-b", "0.0.0.0", "-bmanagement", "0.0.0.0"]

