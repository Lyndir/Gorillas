//
//  BananaLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 08/11/08.
//  Copyright 2008 Lin.k. All rights reserved.
//

#import "BananaLayer.h"


@implementation BananaLayer

@synthesize clearedGorilla;


-(id) init {
    
    if(!(self = [super initWithFile:@"banana.png"]))
        return self;
    
    return self;
}


-(float) width {
    
    return [self contentSize].width;
}


-(float) height {
    
    return [self contentSize].height;
}


@end
