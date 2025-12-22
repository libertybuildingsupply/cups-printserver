PRINTER_NAME="LUKE2690"
PRINTER_IP="192.168.2.154"

sudo lpadmin \
  -p "$PRINTER_NAME" \
  -E \
  -v "ipp://$PRINTER_IP/ipp/print" \
  -m everywhere \
  -o printer-is-shared=true \
  -o sides=two-sided-long-edge \
  -o media=letter \
&& sudo systemctl restart cups \
&& lpstat -p "$PRINTER_NAME" \
&& lpstat -v "$PRINTER_NAME" \
&& lp -d "$PRINTER_NAME" /usr/share/cups/data/testprint
