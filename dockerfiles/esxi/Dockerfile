# NOTE
# You need to download https://my.vmware.com/group/vmware/downloads/get-download?downloadGroup=OVFTOOL440
# and place ovftool.bundle inside secgen directory

FROM ruby:2.5.4

RUN apt update -y && apt upgrade -y
RUN apt install -y --no-install-recommends \
    locales \
    rsync \
    build-essential \
    exiftool \
    graphviz \
    graphviz-dev \
    libpcap0.8-dev

RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN wget "https://releases.hashicorp.com/vagrant/2.2.10/vagrant_2.2.10_x86_64.deb" && \
    dpkg -i vagrant_2.2.10_x86_64.deb && \
    rm -rf vagrant_2.2.10_x86_64.deb

# Requirements for building base images for Windows
RUN vagrant plugin install winrm && vagrant plugin install winrm-fs
RUN wget "https://releases.hashicorp.com/packer/1.6.4/packer_1.6.4_linux_amd64.zip" && \
    unzip packer_1.6.4_linux_amd64.zip && \
    mv packer /usr/local/bin/packer && \
    rm packer_1.6.4_linux_amd64.zip

# VMWare ESXi plugin
RUN git clone https://github.com/dezull/vagrant-vmware-esxi.git && \
    cd vagrant-vmware-esxi && \
    gem build vagrant-vmware-esxi.gemspec && \
    vagrant plugin install ./vagrant-vmware-esxi-2.5.0.gem && \
    cd .. && \
    rm -rf vagrant-vmware-esxi

COPY ovftool.bundle .
RUN chmod +x ovftool.bundle && \
    ./ovftool.bundle --eulas-agreed && \
    rm ovftool.bundle

# ESXI dummy box for remote clone
RUN mkdir ~/dummybox && \
    cd ~/dummybox && \
    echo '{"provider":"vmware"}' > metadata.json && \
    tar cvf dummy.box metadata.json && \
    vagrant box add --name esxi_clone/dummy dummy.box && \
    cd .. && \
    rm -rf dummybox

WORKDIR /secgen
COPY Gemfile /secgen/Gemfile
COPY Gemfile.lock /secgen/Gemfile.lock
RUN bundle install

COPY . /secgen
RUN rm ovftool.bundle

CMD ["ruby", "secgen.rb"]
