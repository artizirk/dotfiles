define bmconnect
	if $argc < 1 || $argc > 2
		help bmconnect
	else
		target extended-remote $arg0
		if $argc == 2
			monitor $arg1 enable
		end
			monitor swdp_scan
		attach 1
	end
end

document bmconnect
  Attach to the Black Magic Probe at the given serial port/device.
    bmconnect PORT [tpwr]
  Specify PORT as COMx in Microsoft Windows or as /dev/ttyACMx in Linux.
  If the second parameter is set as "tpwr", the power-sense pin is driven to
  3.3V
end

# Load .gdbinit files from current dir
set auto-load local-gdbinit
set auto-load safe-path ~
add-auto-load-safe-path /usr/lib/go/src/runtime/runtime-gdb.py
add-auto-load-safe-path /usr/share/gdb/auto-load/usr/lib

# save command history
set history save on
set history size 10000
set history remove-duplicates unlimited
set history filename ~/.gdb_history

# give me pretty structures
set print pretty on

# Allow memory access outside of server provided memory map
set mem inaccessible-by-default off


# Clion is stupid
# define target remote
# bmconnect /dev/ttyBmpGdb
# end

# upgrade remote commands
#define target remote
#  target extended-remote $arg0
#end


define xxd
  if $argc < 2
    set $size = sizeof(*$arg0)
  else
    set $size = $arg1
  end
  dump binary memory dump.bin $arg0 ((void *)$arg0)+$size
  eval "shell xxd -o %d dump.bin; rm dump.bin", ((void *)$arg0)
end
document xxd
  Dump memory with xxd command (keep the address as offset)

  xxd addr [size]
    addr -- expression resolvable as an address
    size -- size (in byte) of memory to dump
            sizeof(*addr) is used by default
end
