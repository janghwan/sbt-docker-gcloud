# 
# Scala, SBT, Docker and Gcloud client
#

# Pull base image
FROM openjdk:8u171

# Env variables
ENV SCALA_VERSION 2.12.6
ENV SBT_VERSION 1.1.6

# Scala expects this file
RUN touch /usr/lib/jvm/java-8-openjdk-amd64/release

# Install Scala
## Piping curl directly in tar
RUN \
  curl -fsL https://downloads.typesafe.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.tgz | tar xfz - -C /root/ && \
  echo >> /root/.bashrc && \
  echo "export PATH=~/scala-$SCALA_VERSION/bin:$PATH" >> /root/.bashrc

# Install sbt and docker 
ARG DOCKER_VERSION=""
RUN \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get -y install \
  apt-transport-https \
  ca-certificates \
  curl \
  gettext \
  gnupg2 \
  software-properties-common \
  && \
  (curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -) && \
  (add-apt-repository \
      "deb [arch=amd64] https://download.docker.com/linux/debian \
      $(lsb_release -cs) \
      stable") && \
  curl -L -o sbt-$SBT_VERSION.deb https://dl.bintray.com/sbt/debian/sbt-$SBT_VERSION.deb && \
  dpkg -i sbt-$SBT_VERSION.deb && \
  (echo "deb https://packages.cloud.google.com/apt cloud-sdk-$(lsb_release -c -s) main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list) && \
  (curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -) && \
  rm sbt-$SBT_VERSION.deb && \
  apt-get update && \
  apt-get -y install \
    sbt \
    docker-ce=$(apt-cache show docker-ce | grep 'Version:' | awk '{print $NF}' | grep "$DOCKER_VERSION" | head -n 1) && \
  rm -rf /var/lib/apt/lists/* && \
  sbt sbtVersion

# Define working directory
ENV HOME /root
WORKDIR /root

# install gcloud 
RUN \
	(echo "deb https://packages.cloud.google.com/apt cloud-sdk-$(lsb_release -c -s) main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list) && \
	(curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -) && \
	apt-get update && \
	apt-get -y install \
		curl \
		google-cloud-sdk \
		google-cloud-sdk-app-engine-python \
		google-cloud-sdk-app-engine-python-extras \
		kubectl \
		python-crypto \
		python-dev \
		vim \
		wget \
	&& \
	rm -rf /var/lib/apt/lists/* && \
	wget -q 'https://bootstrap.pypa.io/get-pip.py' -O get-pip.py && \
	python get-pip.py && \
	rm get-pip.py && \
	pip install \
		kubernetes \
		oauth2client \
		google-api-python-client \
		Jinja2 \
		google-api-helper \
		protobuf

ENV PATH="${PATH}:/usr/lib/google-cloud-sdk/bin"

CMD ["/bin/bash"]
