//
//  QCDevice.h
//  Quadcopter
//
//  Created by Ben Anderson on 20/09/2014.
//  Copyright (c) 2014 Ben Anderson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOBluetooth/IOBluetooth.h>


@interface QCDevice : NSObject

@property (strong) CBPeripheral *peripheral;

@end
