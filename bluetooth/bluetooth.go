package bluetooth

/*
#cgo CFLAGS: -x objective-c -fobjc-arc -g
#cgo LDFLAGS: -framework Cocoa -framework Foundation -framework IOBluetooth

#import <Cocoa/Cocoa.h>

extern void Connect();
*/
import "C"

func RunBluetooth() {
	C.Connect()
}

var DataSubscription (chan string) = make(chan string)

//export HasConnected
func HasConnected() {
	println("Go: Connected!")
}

//export ReceivedData
func ReceivedData(message *C.char) {
	println("Received: " + C.GoString(message))
	go func() {
		DataSubscription <- C.GoString(message)
	}()
}
