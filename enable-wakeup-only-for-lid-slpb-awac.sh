#!/bin/bash

# --- Ubuntu 24.04 Wakeup Installer ---
# Enable LID, SLPB, AWAC; disable all other wakeup devices
# Show final status with descriptions

set -e

WAKEUP_SCRIPT="/usr/local/bin/disable-wakeup-lid-slpb-awac.sh"
DISABLED_LIST="/usr/local/bin/disabled-wakeup-devices.txt"
SERVICE_FILE="/etc/systemd/system/disable-wakeup-lid-slpb-awac.service"

echo "Creating wakeup-disable script..."

sudo tee "$WAKEUP_SCRIPT" > /dev/null << 'EOF'
#!/bin/sh

DISABLED_LIST="/usr/local/bin/disabled-wakeup-devices.txt"

# Function to get description for each device
desc() {
    case $1 in
        LID)   echo "Lid switch" ;;
        SLPB)  echo "Sleep Button" ;;
        AWAC)  echo "Wake Alarm / RTC" ;;
        XDCI)  echo "USB controller / xHCI" ;;
        GLAN)  echo "Gigabit LAN" ;;
        XHCI)  echo "USB 3.0 controller" ;;
        HDAS)  echo "Audio / Intel HD Audio" ;;
        I3C0)  echo "I3C Bus controller" ;;
        CNVW)  echo "PCI device (vendor-specific)" ;;
        RP*)   echo "PCI Root Port" ;;
        PXSX)  echo "PCI Express Switch" ;;
        TXHC)  echo "Thunderbolt / USB controller" ;;
        TDM*)  echo "Audio / Intel HD Audio" ;;
        TRP*)  echo "Thunderbolt Root Port" ;;
        SLPB)  echo "Sleep Button" ;;
        *)     echo "Unknown device" ;;
    esac
}

# Enable LID, SLPB, AWAC if disabled
for dev in LID SLPB AWAC; do
    status=$(awk -v d="$dev" '$1==d {print $3}' /proc/acpi/wakeup)
    if [ "$status" = "*disabled" ]; then
        echo $dev > /proc/acpi/wakeup
        echo "Enabled wakeup for $dev"
    fi
done

# Clear previous list of disabled devices
echo "" > "$DISABLED_LIST"

# Disable all other enabled devices
awk 'NR>1 { if ($3=="*enabled") print $1 }' /proc/acpi/wakeup | while read dev; do
    if [ "$dev" != "LID" ] && [ "$dev" != "SLPB" ] && [ "$dev" != "AWAC" ]; then
        echo $dev > /proc/acpi/wakeup
        echo $dev >> "$DISABLED_LIST"
        echo "Disabled wakeup for $dev"
    fi
done

# Display final status
echo
printf "%-6s %-10s %-30s\n" "Device" "Status" "Description"
awk 'NR>1 {print $1, $3}' /proc/acpi/wakeup | while read dev status; do
    printf "%-6s %-10s %-30s\n" "$dev" "$status" "$(desc $dev)"
done
EOF

sudo chmod +x "$WAKEUP_SCRIPT"
echo "Script created: $WAKEUP_SCRIPT"

echo "Creating systemd service..."

sudo tee "$SERVICE_FILE" > /dev/null << EOF
[Unit]
Description=Enable LID, SLPB, AWAC; disable all other wakeup devices
After=multi-user.target

[Service]
Type=oneshot
ExecStart=$WAKEUP_SCRIPT

[Install]
WantedBy=multi-user.target
EOF

echo "Enabling and starting the service..."
sudo systemctl daemon-reload
sudo systemctl enable disable-wakeup-lid-slpb-awac.service
sudo systemctl start disable-wakeup-lid-slpb-awac.service

echo "Done! Only LID, SLPB, and AWAC remain enabled for wakeup."
echo "Disabled devices list saved to: $DISABLED_LIST"
