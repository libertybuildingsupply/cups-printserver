#!/bin/bash
set -e
echo "=== NinjaOne CUPS IPP Printer Install ==="
# -------------------------------------------------
# Read NinjaOne Script Variables (ShellScript style)
# NinjaOne exposes these as lowercase environment vars
# -------------------------------------------------
PRINTER_NAME="$printerName"
PRINTER_IP="$printerIpAddress"
PRINTER_LOCATION="$printerLocation"
SEND_TEST_PAGE="$sendTestPage"
# -------------------------------------------------
# Validate variables
# -------------------------------------------------
if [[ -z "$PRINTER_NAME" || -z "$PRINTER_IP" ]]; then
  echo "ERROR: printername and printerip variables must be set in NinjaOne"
  exit 1
fi
echo "Printer Name: $PRINTER_NAME"
echo "Printer IP:   $PRINTER_IP"
echo "Printer Location: $PRINTER_LOCATION"
echo "Send Test Page: $SEND_TEST_PAGE"
# -------------------------------------------------
# Ensure CUPS is running
# -------------------------------------------------
echo "Ensuring CUPS service is running..."
systemctl start cups
systemctl enable cups >/dev/null 2>&1 || true
# -------------------------------------------------
# Install ipp-usb and driverless printing support if needed
# -------------------------------------------------
echo "Ensuring driverless printing packages are installed..."
if command -v apt-get &> /dev/null; then
  apt-get install -y ipp-usb cups-ipp-utils 2>/dev/null || true
elif command -v yum &> /dev/null; then
  yum install -y cups-ipp-utils 2>/dev/null || true
fi
# -------------------------------------------------
# Remove existing printer if it already exists
# -------------------------------------------------
if lpstat -p "$PRINTER_NAME" >/dev/null 2>&1; then
  echo "Printer already exists. Removing existing printer..."
  lpadmin -x "$PRINTER_NAME"
fi
# -------------------------------------------------
# Add printer using IPP Everywhere (driverless)
# -------------------------------------------------
echo "Adding printer via IPP Everywhere..."
if [[ -n "$PRINTER_LOCATION" ]]; then
  lpadmin \
    -p "$PRINTER_NAME" \
    -v "ipp://${PRINTER_IP}/ipp/print" \
    -m everywhere \
    -L "$PRINTER_LOCATION" \
    -o printer-is-shared=true \
    -o sides=two-sided-long-edge \
    -o media=letter \
    -E
else
  lpadmin \
    -p "$PRINTER_NAME" \
    -v "ipp://${PRINTER_IP}/ipp/print" \
    -m everywhere \
    -o printer-is-shared=true \
    -o sides=two-sided-long-edge \
    -o media=letter \
    -E
fi
# -------------------------------------------------
# Restart CUPS to ensure clean state
# -------------------------------------------------
echo "Restarting CUPS..."
systemctl restart cups
sleep 2
# -------------------------------------------------
# Verify printer installation
# -------------------------------------------------
echo "Verifying printer..."
lpstat -p "$PRINTER_NAME"
lpstat -v "$PRINTER_NAME"
# -------------------------------------------------
# Send test page (optional, based on parameter)
# -------------------------------------------------
if [[ "$SEND_TEST_PAGE" == "true" ]]; then
  echo "Sending test page..."
  lp -d "$PRINTER_NAME" /usr/share/cups/data/testprint || echo "WARNING: Test print failed"
else
  echo "Skipping test page (not requested)"
fi
echo "=== Printer install completed successfully ==="
exit 0
