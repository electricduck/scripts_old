@echo off
C:
cd \
attrib +h "AMD"
attrib +h "inetpub"
attrib +h "Intel"
attrib +h "NVIDIA"
attrib +h "Program Files"
attrib +h "Program Files (x86)"
attrib +h "ProgramData"
mkdir C:\Misc
mklink /D C:\Apps64 "C:\Program Files"
mklink /D C:\Apps32 "C:\Program Files (x86)"
mklink /D C:\AppsRT "C:\Program Files\WindowsApps"
mklink /D C:\Data C:\ProgramData
mklink /D C:\Temp C:\Windows\Temp
mklink /D C:\WWW C:\inetpub
mklink /D C:\Misc\AMD C:\Misc\AMD
mklink /D C:\Misc\Intel C:\Misc\Intel
mklink /D C:\Misc\NVIDIA C:\Misc\NVIDIA
