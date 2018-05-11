FROM ubuntu:14.04

RUN ["/usr/sbin/useradd", "td-agent"]
RUN ["/bin/mkdir", "/opt/td-agent", "/var/cache/omnibus"]
RUN ["/bin/chown", "td-agent:td-agent", "/opt/td-agent", "/var/cache/omnibus"]

RUN ["/usr/bin/apt-get", "update"]
RUN ["/usr/bin/apt-get", "install", "software-properties-common", "-y"]
RUN ["apt-add-repository", "ppa:brightbox/ruby-ng", "-y"]
RUN ["/usr/bin/apt-get", "update"]
RUN ["/usr/bin/apt-get", "install", "ruby2.3", "-y"]
RUN ["/usr/bin/apt-get", "install", "ruby2.3-dev", "-y"]
RUN ["/usr/bin/apt-get", "install", "ruby-switch", "-y"]
RUN ["ruby-switch", "--set", "ruby2.3"]
RUN ["/usr/bin/apt-get", "install", "git", "-y"]
RUN ["/usr/bin/apt-get", "install", "curl", "-y"]
RUN ["/usr/bin/apt-get", "install", "build-essential", "-y"]
RUN ["/usr/bin/apt-get", "install", "autoconf", "-y"]
RUN ["/usr/bin/gem", "install", "bundler", "--no-rdoc", "--no-ri"]

COPY . .

RUN ["bundle", "install", "--binstubs"]
RUN ["bin/gem_downloader", "core_gems.rb"]
RUN ["bin/gem_downloader", "plugin_gems.rb"]
RUN ["bin/omnibus", "build", "td-agent2"]
