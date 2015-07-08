package bluetooth

/*
#cgo CFLAGS: -x objective-c -arch x86_64 -fmessage-length=0 -fdiagnostics-show-note-include-stack -fmacro-backtrace-limit=0 -std=gnu99 -fobjc-arc
#cgo LDFLAGS: -framework Cocoa -v
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
