/*
 * This file is part of Gorillas.
 *
 *  Gorillas is open software: you can use or modify it under the
 *  terms of the Java Research License or optionally a more
 *  permissive Commercial License.
 *
 *  Gorillas is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *
 *  You should have received a copy of the Java Research License
 *  along with Gorillas in the file named 'COPYING'.
 *  If not, see <http://stuff.lhunath.com/COPYING>.
 */

//
//  ShadeLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 26/10/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "ShadeLayer.h"
#import "GorillasAppDelegate.h"
#import "Remove.h"


@implementation ShadeLayer


-(id) init {

    if(!(self = [super init]))
        return self;
    
    pushed = NO;
    
    color = ccc([GorillasConfig get].shadeColor);
    
    return self;
}


-(void) onEnter {
    
    [[[GorillasAppDelegate get] gameLayer] setPaused:YES];
    
    CGSize winSize = [Director sharedDirector].winSize;
    [self setPosition:ccp((pushed? -1: 1) * winSize.width, 0)];

    [self stopAllActions];

    [super onEnter];
    
    [self runAction:[Sequence actions:
                     [EaseSineOut actionWithAction:
                      [MoveTo actionWithDuration:[GorillasConfig get].transitionDuration position:CGPointZero]],
                     [CallFunc actionWithTarget:self selector:@selector(ready)],
                     nil]];
}


-(void) ready {
    
    // Override me.
}


-(void) dismissAsPush:(BOOL)_pushed {

    [self stopAllActions];
    
    pushed = _pushed;
    
    CGSize winSize = [Director sharedDirector].winSize;
    [self runAction:[Sequence actions:
                     [EaseSineIn actionWithAction:
                      [MoveTo actionWithDuration:[GorillasConfig get].transitionDuration
                                        position:ccp((pushed? -1: 1) * winSize.width, 0)]],
                     [CallFunc actionWithTarget:self selector:@selector(gone)],
                     [Remove action],
                     nil]];
}


-(void) gone {
    
    // Override me.
}


@end
