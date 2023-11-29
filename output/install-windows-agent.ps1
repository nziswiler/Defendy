Invoke-WebRequest -Uri https://packages.wazuh.com/4.x/windows/wazuh-agent-4.6.0-1.msi -OutFile ${env:tmp}\wazuh-agent; msiexec.exe /i ${env:tmp}\wazuh-agent /q WAZUH_MANAGER="172.162.243.188" WAZUH_REGISTRATION_SERVER="172.162.243.188" WAZUH_MANAGER_PORT="30006" WAZUH_REGISTRATION_PORT="30007" WAZUH_AGENT_GROUP="Windows" 
NET START WazuhSvc

$sysmonZip = "Sysmon.zip"
$sysmonUrl = "https://download.sysinternals.com/files/Sysmon.zip"
$sysmonExe = "Sysmon.exe"
$sysmonConfigUrl = "https://raw.githubusercontent.com/nziswiler/Defendy/main/config/wazuh_agent/windows/sysmonconfig.xml"
$sysmonConfig = "sysmonconfig.xml"

function Download-Sysmon {
    Write-Host "Downloading Sysmon..."
    Invoke-WebRequest -Uri $sysmonUrl -OutFile $sysmonZip
    Expand-Archive -Path $sysmonZip -DestinationPath . -Force
    Remove-Item $sysmonZip
}

function Download-SysmonConfig {
    Write-Host "Downloading Sysmon configuration..."
    Invoke-WebRequest -Uri $sysmonConfigUrl -OutFile $sysmonConfig
}

function Install-Sysmon {
    Write-Host "Installing Sysmon..."
    Start-Process -FilePath $sysmonExe -ArgumentList "-accepteula -i $sysmonConfig" -Wait
}

if (-not (Test-Path $sysmonExe)) {
    Download-Sysmon
}

Download-SysmonConfig

if (-not (Test-Path $sysmonConfig)) {
    Write-Host "Custom sysmonconfig.xml not found!"
    exit 1
}

Install-Sysmon

Write-Host "Sysmon installation completed."
