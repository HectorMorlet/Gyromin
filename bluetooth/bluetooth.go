package bluetooth

/*
#cgo CFLAGS: -x objective-c -fobjc-arc
#cgo LDFLAGS: -framework Cocoa -framework Foundation -framework IOBluetooth

#import <Cocoa/Cocoa.h>
#import "QCBluetooth.h"

@interface Binding : NSObject <QCBluetoothDelegate>

- (void)BlehWorld;

@end

@implementation Binding

- (void)BlehWorld {
	NSLog(@"Hello world!");
}

@end

Binding *myTest = NULL;

int HelloWorld(void) {
	myTest = [[Binding alloc] init];
    [myTest BlehWorld];
    return 0;
}
*/
import "C"

func Run() {
	C.HelloWorld()
}
