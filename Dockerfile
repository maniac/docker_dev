FROM debian:unstable

ENV RUSTUP_HOME=/usr/local/rustup CARGO_HOME=/usr/local/cargo PATH=/usr/local/cargo/bin:$PATH
COPY config /.cargo/config
COPY cmake.x86_64-w64-mingw32 cmake.i686-w64-mingw32 meson.x86_64-w64-mingw32 meson.i686-w64-mingw32 /
COPY i686-w64-mingw32-cmake x86_64-w64-mingw32-cmake /usr/bin/

RUN mkdir -p /tmp/build && \
    apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y && \
    apt-get install -y python3 python2 perl bind9-dnsutils netcat-openbsd && \
    apt-get install -y -o Dpkg::Options::="--force-overwrite" -t unstable \
         mingw-w64 build-essential automake autoconf cmake git make bison flex libtool \
         libarchive-tools pkg-config vim wget curl autopoint tmux yasm nasm python3-pip \
         mercurial meson mercurial nodejs npm golang-1.18 unzip openjdk-17-jdk-headless \
         clang musl-tools mingw-w64-tools ripgrep jq strace libx11-dev git-svn && \
    ln -sf /usr/lib/go-1.18/bin/go /usr/bin/go && \
    find /usr/i686-w64-mingw32/ /usr/x86_64-w64-mingw32/ /usr/lib/gcc/i686-w64-mingw32 /usr/lib/gcc/x86_64-w64-mingw32 -name \*.o -o -name \*.a | xargs -n1 objcopy -R '.rdata$zzz' && \
    pip3 install conan mycli awscli && \
    rm -rf /root/.cache /var/lib/apt/lists/* && \
    curl -o /usr/bin/waf https://waf.io/waf-2.0.23 && chmod 755 /usr/bin/waf && \
    curl -o /tmp/build/rustup-init -O https://static.rust-lang.org/rustup/dist/x86_64-unknown-linux-gnu/rustup-init && \
    chmod 755 /tmp/build/rustup-init && /tmp/build/rustup-init -y --no-modify-path --default-toolchain nightly && \
    rustup target add x86_64-pc-windows-gnu i686-pc-windows-gnu x86_64-unknown-linux-musl && \
    ( curl -L `curl -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/rizinorg/rizin/releases/latest | jq -r '.assets[].browser_download_url|select(test("-static-x86_64.tar"))'` | bsdtar xvf - -C /usr ) && \
    ( mkdir -p /usr/lib/zig && curl -L `curl -L https://ziglang.org/download/index.json | jq -r '.master."x86_64-linux".tarball'` | bsdtar xvf - --strip-components 1 -C /usr/lib/zig && ln -sf /usr/lib/zig/zig /usr/bin/zig ) && \
    ( curl -L `curl -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/mattnite/gyro/releases/latest | jq -r '.assets[].browser_download_url|select(test("-linux-x86_64.tar"))'` | bsdtar xvf - --strip-components 1 -C /usr ) && \
    wget -O /usr/bin/zigmod `curl -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/nektro/zigmod/releases/latest | jq -r '.assets[]|select(.name=="zigmod-x86_64-linux")|.browser_download_url'` && chmod 755 /usr/bin/zigmod && \
    ( mkdir -p /usr/lib/powershell && \
      curl -L `curl -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/PowerShell/powershell/releases/latest | jq -r '.assets[].browser_download_url|select(test("-linux-x64.tar"))'` | bsdtar xvf - -C /usr/lib/powershell ) && ln -sf /usr/lib/powershell/pwsh /usr/bin/pwsh && \
    chmod 755 /usr/bin/*-cmake && \
    wget -O - https://www.7-zip.org/a/7z2107-linux-x64.tar.xz | bsdtar xf - -C /usr/bin --include "7zz" && \
    wget -O /tmp/build/mingw-std-threads.zip https://github.com/meganz/mingw-std-threads/archive/refs/heads/master.zip && \
    bsdtar xf /tmp/build/mingw-std-threads.zip -C /usr/lib/gcc/i686-w64-mingw32/10-win32/include/c++ --strip-component 1 --include "*.h" && \
    bsdtar xf /tmp/build/mingw-std-threads.zip -C /usr/lib/gcc/x86_64-w64-mingw32/10-win32/include/c++ --strip-component 1 --include "*.h" && \
    rm -rf /tmp/build
