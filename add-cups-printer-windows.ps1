# ==========================
# CUPS IPP PRINTER INSTALL
# CHANGE ONLY THESE VALUES:
# ==========================

$PrinterName = "SETH-CANON"           # MUST match your CUPS queue name
$CupsServer  = "192.168.2.6"          # Your CUPS server IP
$CupsPort    = 631                     # Standard IPP port

# ==========================
# DO NOT EDIT BELOW THIS LINE
# ==========================

$IppUrl = "ipp://${CupsServer}:${CupsPort}/printers/${PrinterName}"

Write-Host "`n=== Starting IPP Printer Installation ===" -ForegroundColor Cyan
Write-Host "Printer Name: $PrinterName" -ForegroundColor Yellow
Write-Host "IPP URL: $IppUrl`n" -ForegroundColor Yellow

# 1. Disable WSD services (prevents auto-discovery interference)
Write-Host "[1/7] Disabling WSD services..." -ForegroundColor Green
Stop-Service fdPHost, FDResPub -Force -ErrorAction SilentlyContinue
Set-Service fdPHost, FDResPub -StartupType Disabled -ErrorAction SilentlyContinue

# 2. Restart Print Spooler (clears any stuck jobs/states)
Write-Host "[2/7] Restarting Print Spooler service..." -ForegroundColor Green
Restart-Service Spooler -Force
Write-Host "    Waiting 3 seconds for spooler to stabilize..." -ForegroundColor Yellow
Start-Sleep -Seconds 3

# 3. Remove existing printer if present
Write-Host "[3/7] Checking for existing printer..." -ForegroundColor Green
$existing = Get-Printer -Name $PrinterName -ErrorAction SilentlyContinue
if ($existing) {
    $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
    Write-Host "    Found existing printer, renaming to OLD-$PrinterName-$stamp" -ForegroundColor Yellow
    Rename-Printer -Name $PrinterName -NewName "OLD-$PrinterName-$stamp"
    Start-Sleep -Seconds 2
}

# 4. Kill any stuck PrintUI processes
Write-Host "[4/7] Cleaning up stuck print processes..." -ForegroundColor Green
Get-Process rundll32 -ErrorAction SilentlyContinue |
    Where-Object { $_.CommandLine -like "*printui.dll*" } |
    ForEach-Object { Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue }

# 5. Test IPP endpoint connectivity
Write-Host "[5/7] Testing IPP endpoint connectivity..." -ForegroundColor Green
try {
    $testUrl = "http://${CupsServer}:${CupsPort}/printers/${PrinterName}"
    $response = Invoke-WebRequest -Uri $testUrl -Method GET -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
    Write-Host "    ✓ IPP endpoint is reachable" -ForegroundColor Green
} catch {
    Write-Host "    ✗ WARNING: Cannot reach IPP endpoint - printer may not install correctly" -ForegroundColor Red
    Write-Host "    Error: $($_.Exception.Message)" -ForegroundColor Red
    $continue = Read-Host "`nContinue anyway? (y/n)"
    if ($continue -ne 'y') { exit }
}

# 6. Add printer via IPP
Write-Host "[6/7] Adding IPP printer..." -ForegroundColor Green
try {
    Add-Printer -Name $PrinterName -IppURL $IppUrl -ErrorAction Stop
    Write-Host "    ✓ Printer added successfully" -ForegroundColor Green
} catch {
    Write-Host "    ✗ Failed to add printer via IPP" -ForegroundColor Red
    Write-Host "    Error: $($_.Exception.Message)" -ForegroundColor Red
    
    # Fallback: Try adding manually with IPP Class Driver
    Write-Host "`n    Attempting fallback method..." -ForegroundColor Yellow
    
    $PortName = "IPP_${PrinterName}"
    
    # Create port using Add-PrinterPort (more reliable than prnport.vbs)
    try {
        Add-PrinterPort -Name $PortName -PrinterHostAddress $CupsServer -PortNumber $CupsPort -ErrorAction Stop
        Add-Printer -Name $PrinterName -DriverName "Microsoft IPP Class Driver" -PortName $PortName -ErrorAction Stop
        Write-Host "    ✓ Printer added via fallback method" -ForegroundColor Green
    } catch {
        Write-Host "    ✗ Fallback method also failed: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

# 7. Verify installation
Write-Host "[7/7] Verifying installation..." -ForegroundColor Green
Start-Sleep -Seconds 2

$printer = Get-Printer -Name $PrinterName -ErrorAction SilentlyContinue
if ($printer) {
    Write-Host "`n=== Installation Successful ===" -ForegroundColor Green
    Write-Host "Printer Details:" -ForegroundColor Cyan
    $printer | Format-List Name, DriverName, PortName, PrinterStatus, JobCount
    
    # Show port details
    $port = Get-PrinterPort -Name $printer.PortName -ErrorAction SilentlyContinue
    if ($port) {
        Write-Host "Port Details:" -ForegroundColor Cyan
        $port | Format-List Name, PrinterHostAddress, PortNumber, Description, PortMonitor
    }
} else {
    Write-Host "`n=== Installation Failed ===" -ForegroundColor Red
    Write-Host "Printer '$PrinterName' not found after installation attempt." -ForegroundColor Red
    exit 1
}

Write-Host "`nTo set as default printer, run:" -ForegroundColor Yellow
Write-Host "(Get-CimInstance Win32_Printer -Filter `"Name='$PrinterName'`").SetDefaultPrinter()" -ForegroundColor Gray
