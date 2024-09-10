if (-not (Test-Path Env:AZP_URL)) {
    Write-Error "error: missing AZP_URL environment variable"
    exit 1
  }
  
  if (-not (Test-Path Env:AZP_TOKEN_FILE)) {
    if (-not (Test-Path Env:AZP_TOKEN)) {
      Write-Error "error: missing AZP_TOKEN environment variable"
      exit 1
    }
  
    $Env:AZP_TOKEN_FILE = "\azp\.token"
    $Env:AZP_TOKEN | Out-File -FilePath $Env:AZP_TOKEN_FILE
  }
  
  Remove-Item Env:AZP_TOKEN
  
  if ((Test-Path Env:AZP_WORK) -and -not (Test-Path $Env:AZP_WORK)) {
    New-Item $Env:AZP_WORK -ItemType directory | Out-Null
  }
  
  New-Item "\azp\agent" -ItemType directory | Out-Null
  
  # Let the agent ignore the token env variables
  $Env:VSO_AGENT_IGNORE = "AZP_TOKEN,AZP_TOKEN_FILE"
  
  Set-Location agent
  
  Write-Host "1. Determining matching Azure Pipelines agent..." -ForegroundColor Cyan
  
  $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$(Get-Content ${Env:AZP_TOKEN_FILE})"))
  $package = Invoke-RestMethod -Headers @{Authorization=("Basic $base64AuthInfo")} "$(${Env:AZP_URL})/_apis/distributedtask/packages/agent?platform=win-x64&`$top=1"
  $packageUrl = $package[0].Value.downloadUrl
  
  Write-Host $packageUrl
  
  Write-Host "2. Downloading and installing Azure Pipelines agent..." -ForegroundColor Cyan
  
  $wc = New-Object System.Net.WebClient
  $wc.DownloadFile($packageUrl, "$(Get-Location)\agent.zip")
  
  Expand-Archive -Path "agent.zip" -DestinationPath "\azp\agent"
  
  try
  {
    Write-Host "3. Configuring Azure Pipelines agent..." -ForegroundColor Cyan
  
    .\config.cmd --unattended `
      --agent "$(if (Test-Path Env:AZP_AGENT_NAME) { ${Env:AZP_AGENT_NAME} } else { hostname })" `
      --url "$(${Env:AZP_URL})" `
      --auth PAT `
      --token "$(Get-Content ${Env:AZP_TOKEN_FILE})" `
      --pool "$(if (Test-Path Env:AZP_POOL) { ${Env:AZP_POOL} } else { 'Default' })" `
      --work "$(if (Test-Path Env:AZP_WORK) { ${Env:AZP_WORK} } else { '_work' })" `
      --replace
  
    Write-Host "4. Start Azure Pipelines agent..." -ForegroundColor Cyan
  
        # if you just want to run one job, pass --once flag to the .\run.cmd
    # like .\run.cmd --once, the agent will run one job and then terminate
    # If the agent terminates after --once it will also de-register the agent from the pool.
    if (([string]::IsNullOrEmpty($ENV:RUN_ONCE)) -or ($ENV:RUN_ONCE -eq $False)) {
        Write-Host "Running Azure Pipelines agent..." -ForegroundColor Cyan
        .\run.cmd
    }
    else {
        Write-Host "Running Azure Pipelines agent once..." -ForegroundColor Cyan
        .\run.cmd --once
    }
  }
  finally
  {
    Write-Host "Cleanup. Removing Azure Pipelines agent..." -ForegroundColor Cyan
  
    .\config.cmd remove --unattended `
      --auth PAT `
      --token "$(Get-Content ${Env:AZP_TOKEN_FILE})"
  }