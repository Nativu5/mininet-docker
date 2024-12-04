FROM rockylinux/rockylinux:8
ARG TARGETPLATFORM

LABEL org.opencontainers.image.source=https://github.com/Nativu5/Mininet-Docker
LABEL org.opencontainers.image.description="Mininet in Docker (Rocky Linux 8)"

# Add EPEL and PowerTools repositories
RUN dnf update -y \
    && dnf install -y epel-release \
    && dnf install -y --allowerasing yum-utils curl tar unzip \
    && dnf config-manager --set-enabled powertools \
    && dnf clean all

# OpenVSwitch
# WARN: To use openvswitch in container, /lib/modules/$(uname -r) shall be mounted. 
RUN dnf install -y centos-release-nfv-openvswitch \
    && sed -i \
    -e 's|^#baseurl=http://mirror.centos.org/centos/\$nfvsigdist/nfv/\$basearch/openvswitch-2/|baseurl=https://vault.centos.org/$nfvsigdist/nfv/$basearch/openvswitch-2/|' \
    -e 's|^mirrorlist=|#mirrorlist=|' /etc/yum.repos.d/CentOS-NFV-OpenvSwitch.repo \
    && dnf install -y initscripts openvswitch3.1 \
    && systemctl enable openvswitch \
    && dnf clean all

# Mininet
# We need this patch to make install.sh work. 
COPY mininet-install.patch /tmp/mininet-install.patch

RUN dnf install -y sudo git patch python3.12 python3.12-pip \
    && pip3.12 install --upgrade pip \
    && git clone https://github.com/mininet/mininet.git /root/mininet \
    && cd /root/mininet \
    && patch /root/mininet/util/install.sh < /tmp/mininet-install.patch \
    && PYTHON=python3.12 bash /root/mininet/util/install.sh -nf \
    && mkdir -p /etc/network \
    && echo "iface nat0-eth0 inet manual" > /etc/network/interfaces \
    && rm -rf /tmp/mininet-install.patch \
    && dnf clean all

# Set the working directory
WORKDIR /root

# Default command
CMD ["/usr/sbin/init"]
