# Usage with Vitis IDE:
# In Vitis IDE create a Single Application Debug launch configuration,
# change the debug type to 'Attach to running target' and provide this 
# tcl script in 'Execute Script' option.
# Path of this script: C:\Users\C28Asher.Speicher\Documents\ece383_code\vitisWorkspace\lab3test_system\_ide\scripts\debugger_lab3test-default.tcl
# 
# 
# Usage with xsct:
# To debug using xsct, launch xsct and run below command
# source C:\Users\C28Asher.Speicher\Documents\ece383_code\vitisWorkspace\lab3test_system\_ide\scripts\debugger_lab3test-default.tcl
# 
connect -url tcp:127.0.0.1:3121
targets -set -filter {jtag_cable_name =~ "Digilent Nexys Video 210276689268B" && level==0 && jtag_device_ctx=="jsn-Nexys Video-210276689268B-13636093-0"}
fpga -file C:/Users/C28Asher.Speicher/Documents/ece383_code/vitisWorkspace/lab3test/_ide/bitstream/lab3wrapper.bit
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
loadhw -hw C:/Users/C28Asher.Speicher/Documents/ece383_code/vitisWorkspace/lab3wrapper/export/lab3wrapper/hw/lab3wrapper.xsa -regs
configparams mdm-detect-bscan-mask 2
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
rst -system
after 3000
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
dow C:/Users/C28Asher.Speicher/Documents/ece383_code/vitisWorkspace/lab3test/Debug/lab3test.elf
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
con
