## ✅ Updated README (with cups-browsed disable section)

````md
# cups-printserver

Simple scripts to add and deploy printers using **CUPS + IPP (driverless)**.

This repo provides:
- A **Linux/CUPS script** to add and share a printer
- A **Windows PowerShell script** to install that printer on Windows

No vendor drivers required.

---

## IMPORTANT: Disable Auto-Adding Printers (cups-browsed)

If you delete printers and they keep coming back, the `cups-browsed` service is auto-discovering printers
on the network and automatically re-adding them.

✅ **Do this now (turn it OFF completely)**

Run:

```bash
sudo systemctl disable --now cups-browsed
````

Then restart CUPS just to be clean:

```bash
sudo systemctl restart cups
```

✅ **Confirm it’s dead**

```bash
systemctl status cups-browsed
```

You want to see: **disabled** and **inactive (dead)**.

---

## Step 1: Add the Printer to CUPS (Linux)

Run this script on the CUPS server to add and share the printer:

➡ **CUPS / Linux script**
[https://github.com/libertybuildingsupply/cups-printserver/blob/main/add-cups-printer-lpadmin.sh](https://github.com/libertybuildingsupply/cups-printserver/blob/main/add-cups-printer-lpadmin.sh)

This script:

* Adds the printer using IPP Everywhere
* Shares it from CUPS
* Sets basic defaults
* Verifies and prints a test page

---

## Step 2: Install the Printer on Windows

Run this script on the Windows machine **as Administrator**:

➡ **Windows PowerShell script**
[https://github.com/libertybuildingsupply/cups-printserver/blob/main/add-cups-printer-windows.ps1](https://github.com/libertybuildingsupply/cups-printserver/blob/main/add-cups-printer-windows.ps1)

This script:

* Connects to the CUPS printer
* Uses Microsoft IPP Class Driver
* Optionally sets the printer as default
* Verifies and prints a test page

---

## Notes

* Always install the printer in **CUPS first**
* Windows connects to the printer **through CUPS**
* Avoid LPD/LPR and RAW/9100
* Do not install manufacturer drivers on Windows


