$processes = Get-Process WhatsApp
$procID = $processes[0].Id
$cmdline = (Get-WMIObject Win32_Process -Filter "Handle=$procID").CommandLine
$processes[0].Kill()
$processes[0].WaitForExit()
Start-Process -FilePath $cmdline