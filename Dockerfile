FROM openshift/base-centos7

EXPOSE 8080/tcp

# OpenVPN is not available via standard repos available in cent os .. 
# It's available via EPEL repository. 
# First install EPEL repo and then install open vpn.
RUN yum update -y
RUN yum install -y epel-release

RUN yum install -y openvpn easy-rsa

ENV OPENVPN_DIR=/opt/openvpn

RUN mkdir -p /dev/net \
    && if [ ! -c /dev/net/tun ]; then mknod /dev/net/tun c 10 200; fi \
    && mkdir -p /opt/openvpn && \
    cp -r /usr/share/easy-rsa/2.0/ ${OPENVPN_DIR}/easy-rsa

# Generate CA and server certificates
RUN cd ${OPENVPN_DIR}/easy-rsa \
    && . ./vars \
    && ./clean-all \
    && ./pkitool --batch --initca \
    && ./pkitool --batch --server server \
    && ./build-dh

COPY openvpn.sh ${OPENVPN_DIR}/openvpn.sh

COPY verify_user_pass.sh client_command.sh updown.sh /${OPENVPN_DIR}/

CMD ["/opt/openvpn/openvpn.sh"]
