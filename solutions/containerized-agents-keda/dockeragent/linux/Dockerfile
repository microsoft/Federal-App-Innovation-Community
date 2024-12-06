FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
#RUN DEBIAN_FRONTEND=noninteractive apt-get update
#RUN DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

RUN (apt-get update && \
    apt-get install -y --no-install-recommends apt-utils && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        curl \
        git \
        iputils-ping \
        jq \
        lsb-release \
        software-properties-common && \
    rm -rf /var/lib/apt/lists/*) 2>&1

# Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Install PowerShell
RUN (curl -sSL https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl -sSL https://packages.microsoft.com/config/ubuntu/20.04/prod.list | tee /etc/apt/sources.list.d/microsoft.list \
    && apt-get update \
    && apt-get install -y -qq --no-install-recommends \
    powershell) 2>&1

# Install the Azure PowerShell module
RUN pwsh -Command "Install-Module -Name Az -AllowClobber -Force -Scope AllUsers"

# Can be 'linux-x64', 'linux-arm64', 'linux-arm', 'rhel.6-x64'.
ENV TARGETARCH=linux-x64

WORKDIR /azp

COPY ./start.sh .
RUN chmod +x start.sh

ENTRYPOINT [ "./start.sh" ]