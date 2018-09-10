# Build the package
FROM ubuntu:xenial AS build

RUN ["/usr/sbin/useradd", "td-agent"]
RUN ["/bin/mkdir", "/opt/td-agent", "/var/cache/omnibus"]
RUN ["/bin/chown", "td-agent:td-agent", "/opt/td-agent", "/var/cache/omnibus"]

RUN ["/usr/bin/apt-get", "update"]
RUN ["/usr/bin/apt-get", "install", "software-properties-common", "-y"]
RUN ["apt-add-repository", "ppa:brightbox/ruby-ng", "-y"]
RUN ["/usr/bin/apt-get", "update"]
RUN ["apt-get", "install", "software-properties-common"]
RUN ["apt-add-repository", "ppa:brightbox/ruby-ng"]
RUN ["apt-get", "update"]
RUN ["apt-get", "install", "ruby2.3", "--yes"]
RUN ["apt-get", "install", "ruby2.3-dev", "--yes"]
RUN ["apt-get", "install", "ruby-switch", "--yes"]
RUN ["/usr/bin/ruby-switch", "--set", "ruby2.3"]
RUN ["/usr/bin/apt-get", "install", "git", "-y"]
RUN ["git", "config", "--global", "user.email", "sre@hivehome.com"]
RUN ["git", "config", "--global", "user.name", "td-agent docker build"]
RUN ["/usr/bin/apt-get", "install", "curl", "-y"]
RUN ["/usr/bin/apt-get", "install", "build-essential", "-y"]
RUN ["/usr/bin/apt-get", "install", "autoconf", "-y"]
RUN ["/usr/bin/gem", "install", "bundler", "--no-rdoc", "--no-ri"]

COPY . .

RUN ["bundle", "install", "--binstubs"]
RUN ["bin/gem_downloader", "core_gems.rb"]
RUN ["bin/gem_downloader", "plugin_gems.rb"]
RUN ["bin/omnibus", "build", "td-agent2"]

# Produce the runtime container
FROM ubuntu:latest
COPY --from=build pkg/td-agent*.deb ./
RUN ["cd ./ && ls td-agent*.deb | head -1 | xargs dpkg -i"]
