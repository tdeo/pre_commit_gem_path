FROM ubuntu:18.04

RUN apt-get update
RUN apt-get install -y python3-pip

RUN mkdir ~/.gnupg
RUN echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf

RUN gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB

RUN pip3 install pre-commit

RUN apt-get install -y \
  git \
  procps curl ca-certificates gnupg2 build-essential \
  --no-install-recommends

RUN curl -sSL https://get.rvm.io | bash -s

RUN /bin/bash -l -c ". /etc/profile.d/rvm.sh && rvm install 2.6.5"

RUN mkdir -p /apps/test/

WORKDIR /apps/test/

RUN git init .

ADD .pre-commit-config.yaml ./
ADD file.rb ./

RUN echo 'gem: --no-ri --no-rdoc' >> ~/.gemrc

RUN /bin/bash -lc '. /etc/profile.d/rvm.sh && \
  env | sort -i && \
  which gem && \
  gem install rubocop && \
  gem list && \
  env | sort -i && \
  pre-commit run rubocop --files file.rb || true'

RUN /bin/bash -lc '. /etc/profile.d/rvm.sh && \
  unset GEM_PATH && \
  pre-commit run rubocop --files file.rb'
