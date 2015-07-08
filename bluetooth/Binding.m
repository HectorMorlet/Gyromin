
#include "_cgo_export.h"
#import "Binding.h"

@interface Binding ()

@property (strong) QCBluetooth *bluetooth;
- (void)Connect;

@end

@implementation Binding

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
	NSLog(@"Launch");
}

- (void)Connect {
	self.bluetooth = [[QCBluetooth alloc] init];
	self.bluetooth.delegate = self;
	NSLog(@"Wanting to connect...");
	dispatch_main();
	NSLog(@"Exiting...");
}

- (void)bluetoothIsReadyWithSupport:(BOOL)support {
	NSLog(@"Bluetooth ready. Supported: %i", support);
	[self.bluetooth beginScanning];
}


- (void)didDiscoverDevice:(QCDevice *)device {
	NSLog(@"Discovered device: %@", device.peripheral.name);

	if (!self.bluetooth.isConnectedToDevice && [device.peripheral.name isEqualToString:@"BlunoV1.8"]) {
		[self.bluetooth connectToDevice:device];
	}
}


- (void)didConnectToDevice:(QCDevice *)device {
	NSLog(@"Connected to device: %@", device.peripheral.name);
	HasConnected();
}


- (void)didDisconnectFromDevice:(QCDevice *)device {
	NSLog(@"Disconnected from device: %@", device.peripheral.name);
}


- (void)didSendData:(NSString *)message {
	NSLog(@"Sent: %@", message);
}


- (void)didReceiveData:(NSString *)message {
	NSLog(@"Received: %@", message);
	const char *c = [message UTF8String];
	char *cpy = calloc([message length]+1, 1);
	strncpy(cpy, c, [message length]);
	ReceivedData(cpy);
	free(cpy);
}

@end

Binding *binding = NULL;

void Connect(void) {
	binding = [[Binding alloc] init];
    [binding Connect];
}
