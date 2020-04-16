#!/usr/bin/env python3
import dbus, time
bus = dbus.SystemBus()
media = dbus.Interface(bus.get_object("org.bluez", "/org/bluez/hci0"), 'org.bluez.Media1')
path = dbus.ObjectPath('/dummy_player')
media.RegisterPlayer(path, {})
while True: time.sleep(10000)

