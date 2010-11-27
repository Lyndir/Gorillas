//
//  GMenuLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 27/11/10.
//  Copyright 2010 lhunath (Maarten Billemont). All rights reserved.
//

#import "GMenuLayer.h"
#import "Remove.h"


@implementation GMenuLayer

- (id)initWithDelegate:(id<NSObject, MenuDelegate>)aDelegate logo:aLogo itemsFromArray:(NSArray *)menuItems {
    
    if (!(self = [super initWithDelegate:aDelegate logo:aLogo itemsFromArray:menuItems]))
        return self;
    
    self.opacity            = 0xaa;
    self.color              = ccc3(0x00, 0x00, 0x00);
    self.colorGradient      = ccc4(0x00, 0x66, 0xcc, 0xcc);
    self.outerPadding       = margin(0, 0, 0, 0);
    self.innerRatio         = 0;

    return self;
}

@end
