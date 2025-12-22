# cups-printserver

Simple scripts to add and deploy printers using **CUPS + IPP (driverless)**.

This repo provides:
- A **Linux/CUPS script** to add and share a printer
- A **Windows PowerShell script** to install that printer on Windows

No vendor drivers required.

---

## Step 1: Add the Printer to CUPS (Linux)

Run this script on the CUPS server to add and share the printer:

➡ **CUPS / Linux script**
https://github.com/libertybuildingsupply/cups-printserver/blob/main/add-cups-printer-lpadmin.sh

This script:
- Adds the printer using IPP Everywhere
- Shares it from CUPS
- Sets basic defaults
- Verifies and prints a test page

---

## Step 2: Install the Printer on Windows

Run this script on the Windows machine **as Administrator**:

➡ **Windows PowerShell script**
https://github.com/libertybuildingsupply/cups-printserver/blob/main/add-cups-printer-windows.ps1

This script:
- Connects to the CUPS printer
- Uses Microsoft IPP Class Driver
- Optionally sets the printer as default
- Verifies and prints a test page

---

## Notes

- Always install the printer in **CUPS first**
- Windows connects to the printer **through CUPS**
- Avoid LPD/LPR and RAW/9100
- Do not install manufacturer drivers on Windows

---

## CUPS Web Interface

CUPS admin page:
