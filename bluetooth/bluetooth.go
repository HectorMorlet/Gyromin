package bluetooth

/*
#cgo CFLAGS: -x objective-c -fobjc-arc
#cgo LDFLAGS: -framework Cocoa -framework Foundation -framework IOBluetooth

#import <Cocoa/Cocoa.h>
#import "QCBluetooth.h"

int HelloWorld(void) {
    NSLog(@"Hello world!");
    return 0;
}
*/
import "C"

func Run() {
	C.HelloWorld()
}
