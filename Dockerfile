# Build the package
# We are using Xenial to build for now since BrightBox ruby doesn't
# work correctly for ruby 2.3
FROM ubuntu:xenial AS build

RUN mkdir build
RUN /usr/sbin/useradd td-agent
RUN /bin/mkdir /opt/td-agent /var/cache/omnibus
RUN /bin/chown td-agent:td-agent /opt/td-agent /var/cache/omnibus

RUN /usr/bin/apt-get update
RUN /usr/bin/apt-get install software-properties-common -y
RUN apt-add-repository ppa:brightbox/ruby-ng -y
RUN /usr/bin/apt-get update
RUN apt-get install software-properties-common
RUN apt-add-repository ppa:brightbox/ruby-ng
RUN apt-get update
RUN apt-get install ruby2.3 --yes
RUN apt-get install ruby2.3-dev --yes
RUN apt-get install ruby-switch --yes
RUN /usr/bin/ruby-switch --set ruby2.3
RUN /usr/bin/apt-get install git -y
RUN git config --global user.email sre@hivehome.com
RUN git config --global user.name "td-agent docker build"
RUN /usr/bin/apt-get install curl -y
RUN /usr/bin/apt-get install build-essential -y
RUN /usr/bin/apt-get install autoconf -y
RUN /usr/bin/gem install bundler --no-rdoc --no-ri

COPY . ./build

RUN cd build; bundle install --binstubs
RUN cd build; bin/gem_downloader core_gems.rb
RUN cd build; bin/gem_downloader plugin_gems.rb
RUN cd build; bin/omnibus build td-agent2
RUN rm -rf ./build

# Produce the interim installation container. We use 'latest' to install and
# run since that's half of the point of this exercise.
FROM ubuntu:latest AS install
COPY --from=build pkg/td-agent*.deb ./
RUN cd ./ && ls td-agent*.deb | head -1 | xargs dpkg -i
RUN rm -rf ./td-agent*.deb

# Produce the runtime container
FROM install
# TODO: add CMD or ENTRYPOINT statement here
