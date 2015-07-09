
#include "_cgo_export.h"
#import "Binding.h"

@interface Binding ()

@property DFBlunoManager *bluetoothDevice;
- (void)Connect;

@end

@implementation Binding

- (void)Connect {
	self.bluetoothDevice = [DFBlunoManager sharedInstance];
	self.bluetoothDevice.delegate = self;
	NSLog(@"Wanting to connect...");
	dispatch_main();
	NSLog(@"Exiting...");
}

- (void)didDiscoverDevice:(DFBlunoDevice *)dev {
	NSLog(@"I found: %@", dev.name);
	NSLog(@"Trying to connect");
	[self.bluetoothDevice connectToDevice:dev];
}

- (void)didDisconnectDevice:(DFBlunoDevice *)dev {
    NSLog(@"Disconnected from device :(");
}

- (void)readyToCommunicate:(DFBlunoDevice *)dev {
	NSLog(@"Device ready to communicate");
}

- (void)didWriteData:(DFBlunoDevice *)dev {
	NSLog(@"Data written to device");
}

- (void)didReceiveData:(NSData *)data Device:(DFBlunoDevice *)dev {
	NSString* receivedData = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	NSLog(@"Received data: %@", receivedData);
	const char *c = [receivedData UTF8String];
	char *cpy = calloc([receivedData length]+1, 1);
	strncpy(cpy, c, [receivedData length]);
	ReceivedData(cpy);
}

- (void)bleDidUpdateState:(BOOL)bleSupported {
	if (bleSupported) {
		NSLog(@"BLE support is okay! Scanning...");
		[self.bluetoothDevice scan];
	} else {
		NSLog(@"BLE support not okay :(");
	}
}

@end

Binding *binding = NULL;

void Connect(void) {
	binding = [[Binding alloc] init];
	[binding Connect];
}
