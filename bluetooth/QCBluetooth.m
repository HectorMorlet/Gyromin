//
//  QCBluetooth.m
//  Quadcopter
//
//  Created by Ben Anderson on 20/09/2014.
//  Copyright (c) 2014 Ben Anderson. All rights reserved.
//

#import "QCBluetooth.h"


#define BLUNO_SERVICE_UUID @"dfb0"
#define BLUNO_CHARACTERISTIC_UUID @"dfb1"


@interface QCBluetooth ()

@property (readwrite) BOOL bluetoothIsSupported;

@property (strong) QCDevice *connectedDevice;
@property CBCentralManager *manager;

@end


@implementation QCBluetooth


- (id)init
{
	self = [super init];
	if (self) {
		self.bluetoothIsSupported = NO;

		self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
		self.connectedDevice = nil;
	}
	return self;
}


- (BOOL)isConnectedToDevice
{
	return self.connectedDevice != nil;
}



#pragma mark - Connection


- (void)beginScanning
{
	if (self.bluetoothIsSupported) {
		[self stopScanning];
		[self.manager scanForPeripheralsWithServices:nil options:nil];

		NSLog(@"Scanning...");
	}
}


- (void)stopScanning
{
	if (self.bluetoothIsSupported) {
		[self.manager stopScan];
	}
}


- (void)connectToDevice:(QCDevice *)device
{
	if (self.bluetoothIsSupported && !self.isConnectedToDevice) {
		NSLog(@"Connecting to device: %@...", device.peripheral.name);

		[self disconnectFromDevice];

		self.connectedDevice = device;
		[self.manager connectPeripheral:device.peripheral options:nil];
	}
}


- (void)disconnectFromDevice
{
	if (self.bluetoothIsSupported && self.isConnectedToDevice) {
		CBCharacteristic *characteristic = nil;

		for (CBService *service in self.connectedDevice.peripheral.services) {
			if ([service.UUID isEqualTo:[CBUUID UUIDWithString:BLUNO_SERVICE_UUID]]) {
				for (CBCharacteristic *c in service.characteristics) {
					if ([c.UUID isEqualTo:[CBUUID UUIDWithString:BLUNO_CHARACTERISTIC_UUID]]) {
						characteristic = c;
						break;
					}
				}

				break;
			}
		}

		NSLog(@"Cancelling peripheral connection...");
		[self.connectedDevice.peripheral setNotifyValue:NO forCharacteristic:characteristic];
		[self.manager cancelPeripheralConnection:self.connectedDevice.peripheral];
		self.connectedDevice = nil;
	}
}



#pragma mark - Communication


- (void)sendMessage:(NSString *)message
{
	if (self.bluetoothIsSupported && self.isConnectedToDevice) {
		CBCharacteristic *characteristic = nil;

		// Find the correct characteristic
		for (CBService *service in self.connectedDevice.peripheral.services) {
//			NSLog(@"Found Service: %@", service.UUID.description);

			if ([service.UUID isEqual:[CBUUID UUIDWithString:BLUNO_SERVICE_UUID]]) {
				for (CBCharacteristic *potential in service.characteristics) {
//					NSLog(@"Found characteristic: %@", potential.UUID.description);

					if ([potential.UUID isEqual:[CBUUID UUIDWithString:BLUNO_CHARACTERISTIC_UUID]]) {
//						NSLog(@"Found characteristic");
						characteristic = potential;
						break;
					}
				}

				break;
			}
		}

		if (characteristic) {
//			NSLog(@"Writing message to characteristic");
			[self.connectedDevice.peripheral writeValue:[message dataUsingEncoding:NSUTF8StringEncoding]
							  forCharacteristic:characteristic
									   type:CBCharacteristicWriteWithResponse];
		}
	}
}



#pragma mark - Central Manager Delegate Methods

// Can assume Bluetooth is supported in these methods


- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
	if (central.state == CBCentralManagerStatePoweredOn) {
		self.bluetoothIsSupported = YES;
	}

	if (self.delegate && [self.delegate respondsToSelector:@selector(bluetoothIsReadyWithSupport:)]) {
		[self.delegate bluetoothIsReadyWithSupport:self.bluetoothIsSupported];
	}
}


- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
			RSSI:(NSNumber *)RSSI
{
	if (peripheral.name && self.delegate && [self.delegate respondsToSelector:@selector(didDiscoverDevice:)]) {
		QCDevice *device = [[QCDevice alloc] init];
		device.peripheral = peripheral;

		[self.delegate didDiscoverDevice:device];
	}
}


- (void)centralManager:(CBCentralManager *)central
  didConnectPeripheral:(CBPeripheral *)peripheral
{
	self.connectedDevice.peripheral.delegate = self;
	[self.connectedDevice.peripheral discoverServices:@[[CBUUID UUIDWithString:BLUNO_SERVICE_UUID]]];

	if (self.delegate && [self.delegate respondsToSelector:@selector(didConnectToDevice:)]) {
		[self.delegate didConnectToDevice:self.connectedDevice];
	}
}


- (void)centralManager:(CBCentralManager *)central
didDisconnectPeripheral:(CBPeripheral *)peripheral
		     error:(NSError *)error
{
	if (self.delegate && [self.delegate respondsToSelector:@selector(didDisconnectFromDevice:)]) {
		[self.delegate didDisconnectFromDevice:self.connectedDevice];
	}

//	self.connectedDevice = nil;
}


- (void)centralManager:(CBCentralManager *)central
didFailToConnectPeripheral:(CBPeripheral *)peripheral
		     error:(NSError *)error
{
	NSLog(@"Failed to connect to peripheral. Error: %@", error.description);
	if (self.delegate && [self.delegate respondsToSelector:@selector(didDisconnectFromDevice:)]) {
		[self.delegate didDisconnectFromDevice:self.connectedDevice];
	}

	self.connectedDevice = nil;
}



#pragma mark - Peripheral Delegate Methods

// Can assume Bluetooth is supported in these methods


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
	NSLog(@"Did discover services.");
	for (CBService *service in peripheral.services) {
		[peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:BLUNO_CHARACTERISTIC_UUID]] forService:service];
	}
}


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service
		 error:(NSError *)error
{
	NSLog(@"Did discover characteristic for service.");
	if ([service.UUID isEqual:[CBUUID UUIDWithString:BLUNO_SERVICE_UUID]]) {
		for (CBCharacteristic *characteristic in service.characteristics) {
//			NSLog(@"Did discover characteristic: %@", characteristic.UUID.description);

			if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLUNO_CHARACTERISTIC_UUID]]) {
				[peripheral setNotifyValue:YES forCharacteristic:characteristic];
				NSLog(@"Discovered Bluno characteristics.");
			}
		}
	}
}


- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
		 error:(NSError *)error
{
	if (self.delegate && [self.delegate respondsToSelector:@selector(didReceiveData:)]) {
		NSString *str = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
		[self.delegate didReceiveData:str];
	}
}


- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic
		 error:(NSError *)error
{
	if (self.delegate && [self.delegate respondsToSelector:@selector(didSendData:)]) {
//		NSString *str = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
//		[self.delegate didSendData:str];
	}
}


@end
