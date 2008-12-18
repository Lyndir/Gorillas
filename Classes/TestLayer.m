//
//  TestLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 18/12/08.
//  Copyright 2008 Lin.k. All rights reserved.
//

#import "TestLayer.h"
#import "FancyLayer.h"


@implementation TestLayer


-(id) init {
    
	if (!(self = [super init]))
		return self;

    FancyLayer *fancy = [FancyLayer node];
    [self add:fancy];
    
    return self;
}


@end
