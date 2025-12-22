$PrinterName = "NEW-PRINTER-NAME"

Add-Printer `
  -Name $PrinterName `
  -IppURL "ipp://192.168.2.6:631/printers/$PrinterName"

# OPTIONAL – set as default printer
# (Uncomment if desired)
(Get-CimInstance Win32_Printer -Filter "Name='$PrinterName'").SetDefaultPrinter() | Out-Null

# VERIFY – confirm printer, driver, and port
Get-Printer `
  -Name $PrinterName `
| Format-List Name,DriverName,PortName

# TEST – print Windows test page
rundll32 printui.dll,PrintUIEntry `
  /k `
  /n $PrinterName
