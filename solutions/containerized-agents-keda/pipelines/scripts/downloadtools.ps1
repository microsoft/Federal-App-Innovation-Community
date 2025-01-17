#------------------------------------------------------------------------------
#
# Copyright © 2024 Microsoft Corporation.  All rights reserved.
#
# THIS CODE AND ANY ASSOCIATED INFORMATION ARE PROVIDED "AS IS" WITHOUT
# WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT
# LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS
# FOR A PARTICULAR PURPOSE. THE ENTIRE RISK OF USE, INABILITY TO USE, OR
# RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.
#
#------------------------------------------------------------------------------
param (
    [Parameter(Mandatory = $true)]
    [string]$ToolsBasePath
)

#Region Determine Host OS
Write-Host "OS is Windows: $IsWindows - OS is Linux: $IsLinux"
#endregion

if ($IsWindows) {
    $toolsDir = "$toolsBasePath$(if(!$toolsBasePath.EndsWith('\')){'\'})tools" 
} else {
    $toolsDir = "$toolsBasePath$(if(!$toolsBasePath.EndsWith('/')){'/'})tools"
}

if (!(Test-Path -Path $toolsDir)) {
    Write-Host "Creating tools directory at $toolsDir"
    New-Item -ItemType Directory -Path $toolsDir | Out-Null
} else {
    Write-Host "Tools directory already exists at $toolsDir"
}

function Download-FileIfNotExists {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Url,

        [Parameter(Mandatory = $true)]
        [string]$Destination
    )

    if (!(Test-Path -Path $Destination)) {
        Write-Host "Downloading from $Url..."
        try {
            Invoke-WebRequest -Uri $Url -OutFile $Destination -UseBasicParsing
            Write-Host "Downloaded to $Destination"
        }
        catch {
            Write-Error "Failed to download $Url. Error: $_"
            exit 1
        }
    }
    else {
        Write-Host "File already exists at $Destination. Skipping download."
    }
}

#Region Download Kubernetes tools
try {
    $kubectlVersionUrl = "https://dl.k8s.io/release/stable.txt"
    $kubectlVersion = Invoke-RestMethod -Uri $kubectlVersionUrl -UseBasicParsing
    Write-Host "Latest kubectl version: $kubectlVersion"
}
catch {
    Write-Error "Failed to retrieve kubectl version. Error: $_"
    exit 1
}

if ($IsWindows) {
    $kubectlDownloadUrl = "https://dl.k8s.io/release/$kubectlVersion/bin/windows/amd64/kubectl.exe"
    $kubectlDestination = Join-Path $toolsDir "kubectl.exe"
} else {
    $kubectlDownloadUrl = "https://dl.k8s.io/release/$kubectlVersion/bin/linux/amd64/kubectl"
    $kubectlDestination = Join-Path $toolsDir "kubectl"
}

Download-FileIfNotExists -Url $kubectlDownloadUrl -Destination $kubectlDestination
if (Test-Path -Path $kubectlDestination) {
    Write-Host "kubectl.exe successfully downloaded."
} else {
    Write-Error "kubectl.exe was not downloaded successfully."
    exit 1
}
#endregion

#Region Download Helm
try {
    $helmLatestReleaseUrl = "https://api.github.com/repos/helm/helm/releases/latest"
    # GitHub API requires a User-Agent header
    $helmRelease = Invoke-RestMethod -Uri $helmLatestReleaseUrl -UseBasicParsing -Headers @{ "User-Agent" = "PowerShell" }
    $helmVersion = $helmRelease.tag_name.TrimStart('v')  # Remove the 'v' prefix if present
    Write-Host "Latest Helm version: $helmVersion"
}
catch {
    Write-Error "Failed to retrieve Helm release information. Error: $_"
    exit 1
}

if ($IsWindows) {
    $helmUrl = "https://get.helm.sh/helm-v$helmVersion-windows-amd64.zip"
    $helmDownloadPath = Join-Path $toolsDir "helm-v$helmVersion-windows-amd64.zip"
} else {
    $helmUrl = "https://get.helm.sh/helm-v$helmVersion-linux-amd64.tar.gz"
    $helmDownloadPath = Join-Path $toolsDir "helm-v$helmVersion-linux-amd64.tar.gz"
}
Download-FileIfNotExists -Url $helmUrl -Destination $helmDownloadPath

if ($IsWindows) {
    $helmExePath = Join-Path $toolsDir "helm.exe"
    if (Test-Path -Path $helmDownloadPath) {
        Write-Host "Extracting helm from $helmDownloadPath..."
        Expand-Archive -Path $helmDownloadPath -DestinationPath $toolsDir -Force
        $extractedExe = Get-ChildItem -Path $toolsDir -Recurse -Filter "helm.exe" | Select-Object -First 1
        Move-Item -Path $extractedExe.FullName -Destination $helmExePath -Force
    }
    else {
        Write-Error "Failed to find helm from $helmDownloadPath."
        exit 1
    }
} else {
    $helmExePath = Join-Path $toolsDir "helm"
    if (Test-Path -Path $helmDownloadPath) {
        Write-Host "Extracting helm from $helmDownloadPath..."
        tar -xzf $helmDownloadPath -C $toolsDir
        $extractedExe = Get-ChildItem -Path $toolsDir -Recurse -Filter "helm" | Select-Object -First 1
        Move-Item -Path $extractedExe.FullName -Destination $helmExePath -Force
    }
    else {
        Write-Error "Failed to find helm from $helmDownloadPath."
        exit 1
    }
}

if (Test-Path -Path $helmExePath) {
    ls $toolsDir
    Write-Host "helm successfully downloaded."
} else {
    Write-Error "helm was not downloaded successfully."
    exit 1
}
#EndRegion
$env:PATH += "$end:PATH;$($toolsDir)"
Write-Host "##vso[task.setvariable variable=ToolPath;]$toolsDir"


