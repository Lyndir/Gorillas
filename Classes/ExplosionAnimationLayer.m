/*
 * This file is part of Gorillas.
 *
 *  Gorillas is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  Gorillas is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Gorillas in the file named 'COPYING'.
 *  If not, see <http://www.gnu.org/licenses/>.
 */

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
