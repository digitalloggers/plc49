# plc49

DLI PLC49 firmware source code currently requires a Linux system to
build (patches to make crosstool build work on other UN*X-like systems
welcome).

Notable build dependencies (except those typically found on
development machines) include Lua 5.1 and lua-filesystem.

Running 'make' in this directory should generate a plc49.bin firmware
file. It will contain both the NodeMCU firmware and the SPIFFS
filesystem image which stores the actual (compressed) data and
(compiled) scripts for PLC49.

Running 'make flash' will flash the generated firmware onto the PLC49
(check out flash.sh, it allows configuring port/baud rate from
environment). You will need to press and release the RST button while
holding the PGM button to switch the PLC49 into firmware upload mode
before running 'make flash'. It is not necessary to hold the PGM
button throughout the flashing process.

If you spend much time changing the PLC49 data or scripts, you will
find commands modifying the PLC49 filesystem (without full reflash)
useful. 'make upload' will clear the device's filesystem and re-upload
the whole set of files (it uses the same environment variables as
'make flash' for port and baud rate). 'make upload-update' will do the
same, but try to upload only the changed files (keeping track of what
it expects to be present on the device in a separate directory).
