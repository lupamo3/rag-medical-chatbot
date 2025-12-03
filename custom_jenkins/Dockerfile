FROM jenkins/jenkins:lts

USER root

# Base tools + Docker CLI + unzip (you already have this)
RUN apt-get update -y && \
    apt-get install -y ca-certificates curl gnupg unzip && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg \
      | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
      https://download.docker.com/linux/debian \
      $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable" \
      > /etc/apt/sources.list.d/docker.list && \
    apt-get update -y && \
    apt-get install -y docker-ce-cli && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Enable binfmt/qemu so Docker Buildx can cross-build (multi-arch)
RUN docker run --privileged --rm tonistiigi/binfmt --install all || true

# Install AWS CLI v2 (detect arch: x86_64 vs aarch64/arm64)
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
        AWSCLI_PKG="awscli-exe-linux-x86_64.zip"; \
    else \
        AWSCLI_PKG="awscli-exe-linux-aarch64.zip"; \
    fi && \
    curl -s "https://awscli.amazonaws.com/${AWSCLI_PKG}" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf aws awscliv2.zip

# Install Trivy from tarball (multi-arch)
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
        TRIVY_PKG="trivy_0.62.1_Linux-64bit.tar.gz"; \
    elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then \
        TRIVY_PKG="trivy_0.62.1_Linux-ARM64.tar.gz"; \
    else \
        echo "Unsupported architecture: $ARCH" && exit 1; \
    fi && \
    curl -L -o trivy.tar.gz "https://github.com/aquasecurity/trivy/releases/download/v0.62.1/${TRIVY_PKG}" && \
    tar zxvf trivy.tar.gz trivy && \
    mv trivy /usr/local/bin/trivy && \
    chmod +x /usr/local/bin/trivy && \
    rm trivy.tar.gz

# Docker group for Jenkins
RUN groupadd -f docker && \
    usermod -aG docker jenkins

USER jenkins
