# Pull base image.
FROM bigboards/java-8-__arch__

MAINTAINER bigboards
USER root

ENV NOTVISIBLE "in users profile"

RUN mkdir /apps && chmod a+rx /apps

RUN apt-get update \
 && apt-get -y install build-essential gfortran libatlas-base-dev python-pip python-dev pkg-config \
                       libpng-dev libjpeg8-dev libfreetype6-dev libssl-dev libffi-dev libfreetype6-dev \
                       libblas-dev liblapack-dev openssh-server \
 && apt-get clean \
 && apt-get autoclean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/apt/archives/*.deb \
 && mkdir -p /var/run/sshd \
 && sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
 && sed -i 's/Port 22/Port 2222/' /etc/ssh/sshd_config \
 && sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd \
 && echo "export VISIBLE=now" >> /etc/profile \
 && chsh -s /bin/bash bb

# These libs still give errors when installing: json matplotlib
# And these could not be found yet: h2o lightning
RUN pip install --upgrade pip Cython ConfigParser requests numpy scipy pandas scikit-learn sqlalchemy seaborn ibis py4j matplotlib sparkts

ENV PATH /opt/anaconda/bin:$PATH

# external ports
EXPOSE 2222

# Define default command.
CMD ["/usr/sbin/sshd", "-D"]