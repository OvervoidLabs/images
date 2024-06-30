# Set environment variables
ENV NODE_VERSION=22.0.0
ENV YARN_VERSION=1.22.19

# Use the official Node.js image as the base image
FROM node:${NODE_VERSION}

# Create a node user and group with specific UID and GID
RUN groupadd --gid 1000 node && useradd --uid 1000 --gid node --shell /bin/bash --create-home node

# Install necessary packages for building and running applications
RUN set -ex; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
    autoconf \
    automake \
    bzip2 \
    default-libmysqlclient-dev \
    dpkg-dev \
    file \
    g++ \
    gcc \
    imagemagick \
    libbz2-dev \
    libc6-dev \
    libcurl4-openssl-dev \
    libdb-dev \
    libevent-dev \
    libffi-dev \
    libgdbm-dev \
    libglib2.0-dev \
    libgmp-dev \
    libjpeg-dev \
    libkrb5-dev \
    liblzma-dev \
    libmagickcore-dev \
    libmagickwand-dev \
    libmaxminddb-dev \
    libncurses5-dev \
    libncursesw5-dev \
    libpng-dev \
    libpq-dev \
    libreadline-dev \
    libsqlite3-dev \
    libssl-dev \
    libtool \
    libwebp-dev \
    libxml2-dev \
    libxslt-dev \
    libyaml-dev \
    make \
    patch \
    unzip \
    xz-utils \
    zlib1g-dev; \
    rm -rf /var/lib/apt/lists/*

# Install VCS and other necessary utilities
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
    git \
    mercurial \
    openssh-client \
    subversion \
    procps; \
    rm -rf /var/lib/apt/lists/*

# Install additional useful utilities
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gnupg \
    netbase \
    wget; \
    rm -rf /var/lib/apt/lists/*

# Install Yarn
RUN set -ex; \
    export GNUPGHOME="$(mktemp -d)"; \
    for key in \
        6A010C5166006599AA17F08146C2130DFD2497F5 \
        4ED778F539E3634C779C87C6D7062848A1AB005C \
        141F07595B7B3FFE74309A937405533BE57C7D57 \
        74F12602B6F1C4E913FAA37AD3A89613643B6201 \
        DD792F5973C6DE52C432CBDAC77ABFA00DDBF2B7 \
        61FC681DFB92A079F1685E77973F295594EC4689 \
        8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
        C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
        890C08DB8579162FEE0DF9DB8BEAB4DFCF555EF4 \
        C82FA3AE1CBEDC6BE46B9360C43CEC45C17AB93C \
        108F52B48DB57BB0CC439B2997B01419BD92F80A \
        A363A499291CBBC940DD62E41F10027AF002F8B0 \
        CC68F5A3106FF448322E48ED27F5E38D5B0A215F; \
    do \
        gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys "$key" || \
        gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key"; \
    done; \
    curl -fsSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz"; \
    curl -fsSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz.asc"; \
    gpg --batch --verify yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz; \
    gpgconf --kill all; \
    rm -rf "$GNUPGHOME"; \
    mkdir -p /opt; \
    tar -xzf yarn-v$YARN_VERSION.tar.gz -C /opt/; \
    ln -s /opt/yarn-v$YARN_VERSION/bin/yarn /usr/local/bin/yarn; \
    ln -s /opt/yarn-v$YARN_VERSION/bin/yarnpkg /usr/local/bin/yarnpkg; \
    rm yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz; \
    yarn --version; \
    rm -rf /tmp/*

# Download and install Node.js
RUN ARCH=; \
    dpkgArch="$(dpkg --print-architecture)"; \
    case "${dpkgArch##*-}" in \
        amd64) ARCH='x64';; \
        ppc64el) ARCH='ppc64le';; \
        s390x) ARCH='s390x';; \
        arm64) ARCH='arm64';; \
        armhf) ARCH='armv7l';; \
        i386) ARCH='x86';; \
        *) echo "unsupported architecture"; exit 1 ;; \
    esac; \
    export GNUPGHOME="$(mktemp -d)"; \
    set -ex; \
    for key in \
        4ED778F539E3634C779C87C6D7062848A1AB005C \
        141F07595B7B3FFE74309A937405533BE57C7D57 \
        74F12602B6F1C4E913FAA37AD3A89613643B6201 \
        DD792F5973C6DE52C432CBDAC77ABFA00DDBF2B7 \
        61FC681DFB92A079F1685E77973F295594EC4689 \
        8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
        C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
        890C08DB8579162FEE0DF9DB8BEAB4DFCF555EF4 \
        C82FA3AE1CBEDC6BE46B9360C43CEC45C17AB93C \
        108F52B48DB57BB0CC439B2997B01419BD92F80A \
        A363A499291CBBC940DD62E41F10027AF002F8B0 \
        CC68F5A3106FF448322E48ED27F5E38D5B0A215F; \
    do \
        gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys "$key" || \
        gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key"; \
    done; \
    curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$ARCH.tar.xz"; \
    curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc"; \
    gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc; \
    gpgconf --kill all; \
    rm -rf "$GNUPGHOME"; \
    grep " node-v$NODE_VERSION-linux-$ARCH.tar.xz\$" SHASUMS256.txt | sha256sum -c -; \
    tar -xJf "node-v$NODE_VERSION-linux-$ARCH.tar.xz" -C /usr/local --strip-components=1 --no-same-owner; \
    rm "node-v$NODE_VERSION-linux-$ARCH.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt; \
    ln -s /usr/local/bin/node /usr/local/bin/nodejs; \
    node --version; \
    npm --version

# Copy the provided file to /usr/local/bin/
COPY file:4d192565a7220e135cab6c77fbc1c73211b69f3d9fb37e62857b2c6eb9363d51 /usr/local/bin/

# Set the working directory
WORKDIR /app/data
WORKDIR /app

# Set the entrypoint script
ENTRYPOINT ["docker-entrypoint.sh"]

# Set the default command
CMD ["bash"]

# Add another CMD to handle npm install and start
CMD ["/bin/sh", "-c", "npm install && node ."]

# Add an additional file
ADD file:2cc4cba2834
