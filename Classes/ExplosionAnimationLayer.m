//
//  ExplosionAnimationLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 30/11/08.
//  Copyright 2008 Lin.k. All rights reserved.
//

#import "ExplosionAnimationLayer.h"


@implementation ExplosionAnimationLayer


-(id) init {
    
    if(!(self = [super init]))
        return self;
    
    explosion = [[Animation animationWithName:@"Explosion" delay:0.03f images:@"explosion0.png", @"explosion1.png", @"explosion2.png", @"explosion3.png", @"explosion4.png", nil] retain];
    
    return self;
}


-(void) onEnter {
    
    [super onEnter];
    
    [self do:[Sequence actions:
              [Animate actionWithAnimation:explosion restoreOriginalFrame:false],
              [CallFunc actionWithTarget:self selector:@selector(done:)], nil]];
}


-(void) done: (id) sender {
    
    [[self parent] remove:self];
}


-(void) dealloc {
    
    [super dealloc];
    
    [explosion release];
}


+(ExplosionAnimationLayer *) get {
    
    static ExplosionAnimationLayer *instance;
    if(instance && [instance numberOfRunningActions]) {
        [instance release];
        instance = nil;
    }
    
    if(!instance)
        instance = [[ExplosionAnimationLayer node] retain];
    
    return instance;
}


@end
