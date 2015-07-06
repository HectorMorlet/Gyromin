package main

import (
	"github.com/paypal/gatt"
	"log"
)

var done = make(chan struct{})

func onStateChange(d gatt.Device, s gatt.State) {
	log.Println("State:", s)

	if s == gatt.StatePoweredOn {
		log.Println("Scanning...")
		d.Scan([]gatt.UUID{}, false)
		return
	} else {
		d.StopScanning()
		log.Println("Bluetooth unavailable, " +
			"please make sure bluetooth is turned on.")
	}
}

func onDiscover(p gatt.Peripheral, a *gatt.Advertisement, rssi int) {
	if p.ID() == "8b0013d3ca6c40cbba1af378ed51e81d" {
		log.Println("Found Bluno, connecting...")
		p.Device().Connect(p)
	}
}

func onConnect(p gatt.Peripheral, err error) {
	log.Println("Connected to Bluno!")
	defer p.Device().CancelConnection(p)

	services, err := p.DiscoverServices(nil)
	if err != nil {
		log.Println("Failed to discover services:", err)
		return
	}

	for _, service := range services {
		msg := "Service: " + service.UUID().String()
		if len(service.Name()) > 0 {
			msg += " (" + service.Name() + ")"
		}

		log.Println(msg)

		cs, err := p.DiscoverCharacteristics(nil, service)
		if err != nil {
			log.Println("Failed to discover characteristics:", err)
			continue
		}

		for _, c := range cs {
			msg := "  Characteristic: " + c.UUID().String()
			if len(c.Name()) > 0 {
				msg += " (" + c.Name() + ")"
			}

			msg += "\n  properties    " + c.Properties().String()
			log.Println(msg)

			if (c.Properties() & gatt.CharRead) != 0 {
				log.Println("  Reading data...")
				b, err := p.ReadCharacteristic(c)
				if err != nil {
					log.Println("  Failed to read characteristic:", err)
					continue
				}
				log.Println("  Value    %x | %q\n", b, b)
			} else {
				log.Println("  Data cannot be read!")
			}
		}
	}
}

func onDisconnect(p gatt.Peripheral, err error) {
	log.Println("Disconnected, exiting...")
	close(done)
}

func main() {
	defaultClient := []gatt.Option{
		gatt.MacDeviceRole(gatt.CentralManager),
	}

	device, err := gatt.NewDevice(defaultClient...)
	if err != nil {
		log.Fatal("Failed to create device:", err)
	}

	device.Handle(
		gatt.PeripheralDiscovered(onDiscover),
		gatt.PeripheralConnected(onConnect),
		gatt.PeripheralDisconnected(onDisconnect),
	)

	device.Init(onStateChange)
	<-done
	log.Println("Program exit")
}
