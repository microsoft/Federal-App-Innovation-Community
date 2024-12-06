# Use the .NET 8 SDK image with Windows Server Core
FROM mcr.microsoft.com/dotnet/sdk:8.0.403-windowsservercore-ltsc2022

ARG POWERSHELL_VERSION=7.4.6
ARG GIT_VERSION=2.34.1

# Setup for the installation of PowerShell Core
ENV POWERSHELL_INSTALL_DIR "C:\\Program Files\\PowerShell\\7"
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; "]

#Set Strong Cryptography
RUN Set-ItemProperty -Path 'HKLM:\\SOFTWARE\\Microsoft\\.NETFramework\\v4.0.30319' \
    -Name 'SchUseStrongCrypto' -Value 1 -Type DWord; \
    Set-ItemProperty -Path 'HKLM:\\SOFTWARE\\Wow6432Node\\Microsoft\\.NETFramework\\v4.0.30319' \
    -Name 'SchUseStrongCrypto' -Value 1 -Type DWord

# Download and Install PowerShell Core
RUN New-Item -Path C:\Temp -ItemType Directory -ErrorAction SilentlyContinue; \
    Invoke-WebRequest -Uri "https://github.com/PowerShell/PowerShell/releases/download/v$env:POWERSHELL_VERSION/PowerShell-$env:POWERSHELL_VERSION-win-x64.msi" -OutFile "C:\\Temp\\powershell.msi";
RUN msiexec.exe /i C:\\Temp\\powershell.msi /quiet /norestart ADD_PATH=1

# Test the installation
RUN pwsh -Command "Write-Output 'PowerShell version: $PSVersionTable.PSVersion'"

# Sets the PowerShell Core as the default shell
SHELL ["pwsh", "-Command", "$ErrorActionPreference = 'Stop'; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;"]

# Install Git with dynamic versioning
#RUN New-Item -Path C:\Temp -ItemType Directory -ErrorAction SilentlyContinue; \
#    Invoke-WebRequest -Uri "https://github.com/git-for-windows/git/releases/download/v$env:GIT_VERSION.windows.1/Git-$env:GIT_VERSION-64-bit.exe" -OutFile 'C:\\Temp\\git.exe'
#RUN C:\Temp\git.exe /VERYSILENT /NORESTART /NOCANCEL /SP-
#ENV PATH="C:\\Program Files\\Git\\cmd;$env:PATH"
#RUN git --version

# Install AZ PowerShell modules
RUN Install-Module -Name Az -Force -AllowClobber -Repository PSGallery -Confirm:$false;

RUN Get-Module Az -ListAvailable | Select -First 1;

# Install AZ CLI
RUN New-Item -Path C:\Temp -ItemType Directory -ErrorAction SilentlyContinue; \
    Invoke-WebRequest -Uri "https://aka.ms/installazurecliwindows" -OutFile 'C:\\Temp\\azcli.msi';
RUN msiexec.exe /i C:\\Temp\\azcli.msi /quiet /norestart

RUN az --version

RUN Remove-Item -Recurse -Force C:\\Temp -ErrorAction SilentlyContinue;

WORKDIR /azp
COPY start.ps1 .
CMD ["powershell", ".\\start.ps1"]
