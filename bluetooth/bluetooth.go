package bluetooth

/*
#cgo CFLAGS: -x objective-c -fobjc-arc
#cgo LDFLAGS: -framework Cocoa -framework Foundation -framework IOBluetooth

#import <Cocoa/Cocoa.h>

extern void Connect();
*/
import "C"

func Run() {
	C.Connect()
}

//export HasConnected
func HasConnected() {
	println("Go: Connected!")
}

//export ReceivedData
func ReceivedData(message *C.char) {
	println("Received: " + C.GoString(message))
}
