# Define a log function for better debugging
$logFile = "./install_log.txt"
function Log {
    param([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $formattedMessage = "${timestamp}: ${message}"
    Write-Output $formattedMessage
    Add-Content -Path $logFile -Value $formattedMessage
}

# Check if Chocolatey is installed
Log "Checking if Chocolatey is installed..."
if (Get-Command choco -ErrorAction SilentlyContinue) {
    Log "Chocolatey is already installed."
} else {
    Log "Chocolatey is not installed. Installing Chocolatey..."
    # Install Chocolatey if not found
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    try {
        iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    } catch {
        Log "Failed to download Chocolatey installation script. Exiting script."
        exit 2
    }

    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Log "Failed to install Chocolatey. Exiting script."
        exit 2
    }
}

# Install Windows Terminal and Vim using Chocolatey
Log "Installing Windows Terminal, Vim and Git using Chocolatey..."
try {
    choco install microsoft-windows-terminal vim --params "/NoGui" git gh notepadplusplus jq fzf ripgrep 7zip bat openssl.light python -y
    Log "Windows Terminal, Vim and Git installation completed."
} catch {
    Log "Failed to install Windows Terminal or Vim or Git. Exiting script."
    exit 3
}

# Download `.vimrc` from GitHub only if it doesn't already exist
$vimrcUrl = "https://raw.githubusercontent.com/jorgearevalodev/dotfiles/main/.vimrc"
$vimrcDestination = Join-Path $env:USERPROFILE ".vimrc"

if (-not (Test-Path -Path $vimrcDestination)) {
    Log "Downloading .vimrc from GitHub..."
    try {
        Invoke-WebRequest -Uri $vimrcUrl -OutFile $vimrcDestination -ErrorAction Stop
        Log ".vimrc downloaded successfully and saved to $vimrcDestination."
    } catch {
        Log "Failed to download .vimrc from GitHub. Exiting script."
        exit 4
    }
} else {
    Log ".vimrc already exists at $vimrcDestination. Skipping download."
}

# Check if OpenSSH Server is available as a capability and install if not present
$sshCapability = Get-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
if ($sshCapability.State -ne "Installed") {
    Log "Installing OpenSSH Server as a Windows capability..."
    try {
        Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0 -ErrorAction Stop
    } catch {
        Log "Failed to install OpenSSH Server. Exiting script."
        exit 5
    }
} else {
    Log "OpenSSH Server is already installed."
}

# Start and configure the SSH service if installed
if (Get-Service -Name sshd -ErrorAction SilentlyContinue) {
    Log "Starting and configuring SSH Server..."
    Start-Service -Name sshd
    Set-Service -Name sshd -StartupType Automatic
    Log "SSH Server started and set to start automatically."
} else {
    Log "OpenSSH Server installation failed or sshd service not found. Exiting script."
    exit 6
}

Log "Ensuring firewall rule for SSH exists..."
try {
    if (-not (Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue)) {
        New-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -DisplayName "OpenSSH Server (Inbound)" `
            -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
        Log "Firewall rule for SSH added."
    } else {
        Log "Firewall rule for SSH already exists. Skipping."
    }
} catch {
    Log "Failed to add SSH firewall rule. Exiting script."
    exit 12
}



# Define the path for the administrators_authorized_keys file using the PROGRAMDATA environment variable
$adminAuthorizedKeysFile = Join-Path $env:PROGRAMDATA "ssh\administrators_authorized_keys"
$sshDir = Join-Path $env:PROGRAMDATA "ssh"

# Ensure the ProgramData\ssh directory exists
if (!(Test-Path -Path $sshDir)) {
    Log "Creating $sshDir directory..."
    try {
        New-Item -ItemType Directory -Path $sshDir -Force
        Log "$sshDir directory created successfully."
    } catch {
        Log "Failed to create $sshDir directory. Exiting script."
        exit 7
    }
}

# Ensure the administrators_authorized_keys file exists
if (!(Test-Path -Path $adminAuthorizedKeysFile)) {
    Log "Creating administrators_authorized_keys file..."
    try {
        New-Item -ItemType File -Path $adminAuthorizedKeysFile -Force
        Log "administrators_authorized_keys file created successfully."
    } catch {
        Log "Failed to create administrators_authorized_keys file. Exiting script."
        exit 8
    }
}

# Read your SSH public key
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$publicKeyPath = Join-Path $scriptDir "id_rsa.pub"

if (!(Test-Path -Path $publicKeyPath)) {
    Log "Downloading SSH public key from GitHub..."
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/jorgearevalodev/dotfiles/main/id_rsa.pub" -OutFile $publicKeyPath -ErrorAction Stop
    if (!(Test-Path -Path $publicKeyPath)) {
        Log "SSH public key file not found. Please make sure the file exists in the current directory. Exiting script."
        exit 1
    }
}

# Read the content of the public key file
try {
    $yourPublicKey = Get-Content -Path $publicKeyPath -ErrorAction Stop
    Log "Successfully read public key "
} catch {
    Log "Failed to read the SSH public key file. Exiting script."
    exit 9
}

# Add the public key to administrators_authorized_keys
try {
    try {
        $currentKeys = Get-Content -Path $adminAuthorizedKeysFile -Raw -ErrorAction Stop
            if ($null -eq $currentKeys) {
                $currentKeys = ""
                    Log "Note: administrators_authorized_keys was empty."
            }
    } catch {
        Log "Warning: Couldn't read administrators_authorized_keys. Defaulting to empty. Error: $_"
            $currentKeys = ""
    }

    if (-not [string]::IsNullOrWhiteSpace($yourPublicKey) -and -not $currentKeys.Contains($yourPublicKey)) {
        try {
            Add-Content -Path $adminAuthorizedKeysFile -Value "$yourPublicKey"
                Log "SSH public key added to administrators_authorized_keys."
        } catch {
            Log "Failed to add the SSH public key to administrators_authorized_keys. Error: $_"
                exit 10
        }
    } else {
        Log "SSH public key already present or input was empty. Skipping append."
    }
} catch {
    Log "Failed to add the SSH public key to administrators_authorized_keys. Exiting script. Error: $_"
    exit 10
}

# Set permissions on the administrators_authorized_keys file
try {
    icacls $adminAuthorizedKeysFile /inheritance:r
    icacls $adminAuthorizedKeysFile /grant "Administrators:(R)"
    icacls $adminAuthorizedKeysFile /grant "$($env:USERNAME):(R)"
    Log "Permissions set on administrators_authorized_keys file."
} catch {
    Log "Failed to set permissions on administrators_authorized_keys file. Exiting script."
    exit 11
}

$sshdConfigPath = Join-Path $env:ProgramData "ssh\sshd_config"
$adminMatchBlock = @"
Match Group administrators
       AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys
"@

if (-not (Select-String -Path $sshdConfigPath -Pattern "Match Group administrators" -Quiet)) {
    Log "Adding Match Group administrators block to sshd_config..."
    Add-Content -Path $sshdConfigPath -Value "`r`n$adminMatchBlock`r`n"
    Restart-Service sshd
    Log "sshd_config updated and sshd restarted."
}

Log "SSH public key has been added to administrators_authorized_keys for the Administrator account. Installation complete."

# Upgrade pip properly
try {
    Log "Upgrading pip..."
    python -m pip install --upgrade pip
    Log "Pip upgrade completed."
} catch {
    Log "Failed to upgrade pip. Error: $_"
    exit 14
}

# Install ipython
try {
    Log "Installing ipython..."
    python -m pip install ipython
    Log "ipython installation completed."
} catch {
    Log "Failed to install ipython. Error: $_"
    exit 15
}


