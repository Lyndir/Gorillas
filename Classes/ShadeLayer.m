/*
 * This file is part of Gorillas.
 *
 *  Gorillas is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 2 of the License, or
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
    
    [self setColor:[[GorillasConfig get] shadeColor]];
    
    return self;
}


-(void) onEnter {
    
    [[[GorillasAppDelegate get] gameLayer] setPaused:YES];
    
    CGSize winSize = [Director sharedDirector].winSize;
    [self setPosition:cpv((pushed? -1: 1) * winSize.width, 0)];

    [self stopAllActions];

    [super onEnter];
    
    [self runAction:[Sequence actions:
                     [EaseSineOut actionWithAction:
                      [MoveTo actionWithDuration:[GorillasConfig get].transitionDuration position:cpvzero]],
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
                                        position:cpv((pushed? -1: 1) * winSize.width, 0)]],
                     [CallFunc actionWithTarget:self selector:@selector(gone)],
                     [Remove action],
                     nil]];
}


-(void) gone {
    
    // Override me.
}


@end
