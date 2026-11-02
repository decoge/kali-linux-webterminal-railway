FROM kalilinux/kali-rolling

ENV PORT=7681
ENV DEBIAN_FRONTEND=noninteractive

# Install required Linux packages
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
     ca-certificates \
     wget \
     curl \
     git \
     python3 \
     python3-pip \
     xz-utils \
     ffmpeg \
     yt-dlp \
     tini \
     fastfetch \
  && rm -rf /var/lib/apt/lists/*

# Install Node.js 24.21.0
RUN set -eux; \
    arch="$(uname -m)"; \
    case "$arch" in \
      x86_64) node_arch="x64" ;; \
      aarch64) node_arch="arm64" ;; \
      *) echo "Unsupported architecture: $arch" >&2; exit 1 ;; \
    esac; \
    curl -fsSL "https://nodejs.org/dist/v24.21.0/node-v24.21.0-linux-${node_arch}.tar.xz" \
      | tar -xJ --strip-components=1 -C /usr/local; \
    node -v; \
    npm -v

# Verify installed tools
RUN python3 --version \
  && yt-dlp --version \
  && ffmpeg -version

# Install latest ttyd
RUN set -eux; \
    arch="$(uname -m)"; \
    case "$arch" in \
      x86_64|amd64) ttyd_asset="ttyd.x86_64" ;; \
      aarch64|arm64) ttyd_asset="ttyd.aarch64" ;; \
      *) echo "Unsupported arch: $arch" >&2; exit 1 ;; \
    esac; \
    wget -qO /usr/local/bin/ttyd \
      "https://github.com/tsl0922/ttyd/releases/latest/download/${ttyd_asset}"; \
    chmod +x /usr/local/bin/ttyd

RUN mkdir -p /usr/local/bin

RUN echo "fastfetch || true" >> /root/.bashrc

EXPOSE 7681

ENTRYPOINT ["/usr/bin/tini", "--"]

CMD ["/bin/bash", "-lc", "/usr/local/bin/ttyd --writable -i 0.0.0.0 -p ${PORT} -c ${USERNAME}:${PASSWORD} /bin/bash"]
