#!/bin/bash
# Set the working directory correctly
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR" || exit

source ../../../.env
SCRIPT_NAME="../../../install-windows-agent.ps1"
SYSMON_CONFIG="https://raw.githubusercontent.com/nziswiler/Defendy/main/config/wazuh-agent/linux/packetbeat.yml"

# Based on: https://gist.githubusercontent.com/taylorwalton/22b3ef3f624edd494ebf640aba56120c/raw/cee2383e91aea2b850bd87c118f20fc010955cf8/sysmon_install.ps1
cat > "$SCRIPT_NAME" <<EOF
# Get the values from the Bash environment
\$SERVER = "$SERVER"
\$WAZUH_AGENT_CONNECTION_PORT = "$WAZUH_AGENT_CONNECTION_PORT"
\$WAZUH_AGENT_ENROLLMENT_PORT = "$WAZUH_AGENT_ENROLLMENT_PORT"

# Rest of your PowerShell script using the variables...
Invoke-WebRequest -Uri https://packages.wazuh.com/4.x/windows/wazuh-agent-4.6.0-1.msi -OutFile \${env:tmp}\wazuh-agent; msiexec.exe /i \${env:tmp}\wazuh-agent /q WAZUH_MANAGER="\$SERVER" WAZUH_REGISTRATION_SERVER="\$SERVER" WAZUH_MANAGER_PORT="\$WAZUH_AGENT_CONNECTION_PORT" WAZUH_REGISTRATION_PORT="\$WAZUH_AGENT_ENROLLMENT_PORT" WAZUH_AGENT_GROUP="Windows" 
NET START WazuhSvc

\$sysinternals_repo = 'download.sysinternals.com'
\$sysinternals_downloadlink = 'https://download.sysinternals.com/files/SysinternalsSuite.zip'
\$sysinternals_folder = 'C:\Program Files\sysinternals'
\$sysinternals_zip = 'SysinternalsSuite.zip'
\$sysmonconfig_downloadlink = '$SYSMON_CONFIG'
\$sysmonconfig_file = 'sysmonconfig-export.xml'

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if (Test-Path -Path \$sysinternals_folder) {
    write-host ('Sysinternals folder already exists')
} else {
    \$OutPath = \$env:TMP
    \$output = \$sysinternals_zip
    New-Item -Path "C:\Program Files" -Name "sysinternals" -ItemType "directory"
    \$X = 0
    do {
        Write-Output "Waiting for network"
        Start-Sleep -s 5
        \$X += 1
    } until((\$connectreult = Test-NetConnection \$sysinternals_repo -Port 443 | ? { $_.TcpTestSucceeded }) -or \$X -eq 3)

    if (\$connectreult.TcpTestSucceeded -eq \$true){
        Try
        {
            write-host ('Downloading and copying Sysinternals Tools to C:\Program Files\sysinternals...')
            Invoke-WebRequest -Uri \$sysinternals_downloadlink -OutFile \$OutPath\$output
            Expand-Archive -path \$OutPath\$output -destinationpath \$sysinternals_folder
            Start-Sleep -s 10
            Invoke-WebRequest -Uri \$sysmonconfig_downloadlink -OutFile \$OutPath\$sysmonconfig_file
            \$serviceName = 'Sysmon64'
            If (Get-Service \$serviceName -ErrorAction SilentlyContinue) {
                write-host ('Sysmon Is Already Installed')
            } else {
                Invoke-Command {reg.exe ADD HKCU\Software\Sysinternals /v EulaAccepted /t REG_DWORD /d 1 /f}
                Invoke-Command {reg.exe ADD HKU\.DEFAULT\Software\Sysinternals /v EulaAccepted /t REG_DWORD /d 1 /f}
                Start-Process -FilePath \$sysinternals_folder\Sysmon64.exe -Argumentlist @("-i", "\$OutPath\$sysmonconfig_file")
            }
        }
        Catch
        {
            \$ErrorMessage = $_.Exception.Message
            \$FailedItem = $_.Exception.ItemName
            Write-Error -Message "\$ErrorMessage \$FailedItem"
            exit 1
        }
        Finally
        {
            Remove-Item -Path \$OutPath\$output
        }
    } else {
        Write-Output "Unable to connect to Sysinternals Repo"
    }
}
EOF

