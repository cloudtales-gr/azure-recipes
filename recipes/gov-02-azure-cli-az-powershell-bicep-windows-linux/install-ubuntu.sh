#!/usr/bin/env bash
# GOV-02 on Ubuntu 24.04 (also WSL): Azure CLI, Bicep, PowerShell 7 and the Az module.
set -euo pipefail

# Run as your normal user: sudo is used where it is needed. As root, az's Bicep copy and the Az module
# would land in /root and your own account would not see them.
if [[ $EUID -eq 0 ]]; then
  echo "Run this as your normal user, not as root (inside WSL: wsl -d <distro>, then this script)." >&2
  exit 1
fi

echo "== Azure CLI (Microsoft's apt repository)"
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

echo "== PowerShell 7"
# shellcheck source=/dev/null
source /etc/os-release
wget -q "https://packages.microsoft.com/config/ubuntu/${VERSION_ID}/packages-microsoft-prod.deb" -O /tmp/packages-microsoft-prod.deb
sudo dpkg -i /tmp/packages-microsoft-prod.deb && rm /tmp/packages-microsoft-prod.deb
sudo apt-get update -q && sudo apt-get install -y -q powershell

echo "== Bicep CLI on PATH (Az PowerShell needs it; az has its own copy too)"
arch="$(uname -m)"; [[ "$arch" == "aarch64" ]] && file="bicep-linux-arm64" || file="bicep-linux-x64"
curl -sLo /tmp/bicep "https://github.com/Azure/bicep/releases/latest/download/${file}"
sudo install -m 0755 /tmp/bicep /usr/local/bin/bicep && rm /tmp/bicep
az bicep install

echo "== Az PowerShell module (current user, about 80 modules: 5-10 minutes)"
pwsh -NoProfile -Command 'Install-PSResource -Name Az -Repository PSGallery -Scope CurrentUser -TrustRepository'

echo; echo "Done. Next: ./verify.sh"
