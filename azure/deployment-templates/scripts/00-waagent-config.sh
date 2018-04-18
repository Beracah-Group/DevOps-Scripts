#!/usr/bin/env bash
set -e

cat <<EOF > /etc/waagent.conf
#
# Microsoft Azure Linux Agent Configuration
#

# Enable instance creation
Provisioning.Enabled=n

# Rely on cloud-init to provision
Provisioning.UseCloudInit=y

# Password authentication for root account will be unavailable.
Provisioning.DeleteRootPassword=y

# Generate fresh host key pair.
Provisioning.RegenerateSshHostKeyPair=n

# Supported values are "rsa", "dsa" and "ecdsa".
Provisioning.SshHostKeyPairType=rsa

# Monitor host name changes and publish changes via DHCP requests.
Provisioning.MonitorHostName=n

# Decode CustomData from Base64.
Provisioning.DecodeCustomData=n

# Execute CustomData after provisioning.
Provisioning.ExecuteCustomData=n

# Algorithm used by crypt when generating password hash.
#Provisioning.PasswordCryptId=6

# Length of random salt used when generating password hash.
#Provisioning.PasswordCryptSaltLength=10

# Allow reset password of sys user
Provisioning.AllowResetSysUser=n

# Format if unformatted. If 'n', resource disk will not be mounted.
ResourceDisk.Format=y

# File system on the resource disk
# Typically ext3 or ext4. FreeBSD images should use 'ufs2' here.
ResourceDisk.Filesystem=ext4

# Mount point for the resource disk
ResourceDisk.MountPoint=/mnt/resource

# Create and use swapfile on resource disk.
ResourceDisk.EnableSwap=y

# Size of the swapfile.
ResourceDisk.SwapSizeMB=8192

# Comma-seperated list of mount options. See man(8) for valid options.
ResourceDisk.MountOptions=None

# Respond to load balancer probes if requested by Microsoft Azure.
LBProbeResponder=y

# Enable verbose logging (y|n)
Logs.Verbose=n

# Is FIPS enabled
OS.EnableFIPS=n

# Root device timeout in seconds.
OS.RootDeviceScsiTimeout=300

# If "None", the system default version is used.
OS.OpensslPath=None

# Set the path to SSH keys and configuration files
OS.SshDir=/etc/ssh

# If set, agent will use proxy server to access internet
#HttpProxy.Host=None
#HttpProxy.Port=None

# Detect Scvmm environment, default is n
# DetectScvmmEnv=n

# Enable RDMA management and set up, should only be used in HPC images
# OS.EnableRDMA=y

# Enable RDMA kernel update, this value is effective on Ubuntu
# OS.UpdateRdmaDriver=y

# Enable or disable goal state processing auto-update, default is enabled
# AutoUpdate.Enabled=y

# Determine the update family, this should not be changed
# AutoUpdate.GAFamily=Prod

# Determine if the overprovisioning feature is enabled. If yes, hold extension
# handling until inVMArtifactsProfile.OnHold is false.
# Default is disabled
# EnableOverProvisioning=n

# Allow fallback to HTTP if HTTPS is unavailable
# Note: Allowing HTTP (vs. HTTPS) may cause security risks
# OS.AllowHTTP=n

# Add firewall rules to protect access to Azure host node services
# Note:
# - The default is false to protect the state of exising VMs
OS.EnableFirewall=y
EOF