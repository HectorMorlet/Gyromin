//
//  QCDevice.m
//  Quadcopter
//
//  Created by Ben Anderson on 20/09/2014.
//  Copyright (c) 2014 Ben Anderson. All rights reserved.
//

#import "QCDevice.h"


@implementation QCDevice


- (id)init
{
	self = [super init];
	if (self) {
		self.peripheral = nil;
	}
	return self;
}


- (BOOL)isEqual:(QCDevice *)object
{
	return object.peripheral.name == self.peripheral.name;
}


@end

