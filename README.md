# 📄 Script Documentation Template

## 🧾 Metadata

| Field           | Value                                                                 |
|----------------|------------------------------------------------------------------------|
| **Script Name** | `<script_name>.ps1`                                                   |
| **Description** | Brief explanation of what the script does                             |
| **Author**      | Yates Enterprise Solutions (YES) – R. Yates                           |
| **Created**     | YYYY-MM-DD                                                            |
| **Last Modified** | YYYY-MM-DD                                                         |
| **Version**     | v1.0.0                                                                |
| **Dependencies** | List of required tools, modules, or packages (e.g., `icacls`, `AD Module`) |
| **Usage**       | Example: `.\<script_name>.ps1 -Path "C:\Data"`                        |
| **Output**      | Description of files or changes the script makes (e.g., CSV reports) |
| **Notes**       | Known limitations, assumptions, or special usage scenarios           |

---

## 🔄 Changelog

| Version | Date       | Author     | Description                                   |
|---------|------------|------------|-----------------------------------------------|
| v1.0.0  | 2025-04-15 | D. Yates   | Initial script creation                        |
| v1.1.0  | YYYY-MM-DD |            | Describe bug fixes, optimizations, etc.        |

---

## 🧩 Functions

> Below are descriptions of any custom functions used in the script:

### `Get-TopFolders`
Scans the specified directory and returns a list of top-level folders.

### `Export-Permissions`
Uses `icacls` to export the folder’s ACLs to CSV format.

---

## 💡 Examples

### Basic Execution
```powershell
.\Get-TopFolderPermissions.ps1 -Path "D:\Shares"
