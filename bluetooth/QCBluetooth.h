//
//  QCBluetooth.h
//  Quadcopter
//
//  Created by Ben Anderson on 20/09/2014.
//  Copyright (c) 2014 Ben Anderson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOBluetooth/IOBluetooth.h>

#import "QCDevice.h"


@protocol QCBluetoothDelegate <NSObject>

@optional

// Called when Bluetooth support has been detected.
// * `support` - true when Bluetooth is supported on the device.
- (void)bluetoothIsReadyWithSupport:(BOOL)support;

// Called when a Bluetooth device is detected during scanning.
- (void)didDiscoverDevice:(QCDevice *)device;

// Called when a successful connection is established with a device.
- (void)didConnectToDevice:(QCDevice *)device;

// Called when a connection to a device is broken for any reason.
- (void)didDisconnectFromDevice:(QCDevice *)device;

// Called when a string is successfully sent to the connected device.
- (void)didSendData:(NSString *)message;

// Called when a string is received from the connected device.
- (void)didReceiveData:(NSString *)message;

@end


@interface QCBluetooth : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, weak) id <QCBluetoothDelegate> delegate;

// Property stating whether bluetooth is supported on the host device.
// If Bluetooth isn't supported, all methods do nothing.
@property (readonly) BOOL bluetoothIsSupported;

// Returns true if the bluetooth manager is connected to a device.
- (BOOL)isConnectedToDevice;

// Start scanning for devices.
// Calls didDiscoverDevice on the delegate when one is found.
- (void)beginScanning;

// Stop scanning for devices.
- (void)stopScanning;

// Connect to a particular device.
// If this is called when already connected to a device, the current
// device will be disconnected from, calling the didDisconnectFromDevice
// delegate method.
- (void)connectToDevice:(QCDevice *)device;

// Disconnect from the currently connected device.
// If not connected to any device, this method does nothing.
- (void)disconnectFromDevice;

// Send a message to the currently connected device.
// Does nothing if not currently connected to a device.
- (void)sendMessage:(NSString *)message;

@end
