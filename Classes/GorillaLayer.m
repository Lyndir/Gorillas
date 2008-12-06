//
//  GorillaLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 07/11/08.
//  Copyright 2008 Lin.k. All rights reserved.
//

#import "GorillaLayer.h"
#import "Utility.h"


@implementation GorillaLayer

@synthesize human, alive, name;


-(id) init {
    
    if(!(self = [super initWithFile:@"gorilla.png"]))
        return self;
    
    return self;
}


-(BOOL) hitsGorilla: (cpVect)pos {
    
    return  pos.x >= position.x - [self contentSize].width  / 2 &&
            pos.y >= position.y - [self contentSize].height / 2 &&
            pos.x <= position.x + [self contentSize].width  / 2 &&
            pos.y <= position.y + [self contentSize].height / 2;
}


-(float) width {
    
    return [self contentSize].width;
}


-(float) height {
    
    return [self contentSize].height;
}


-(void) dealloc {
    
    [super dealloc];
    
    [name release];
}


@end
