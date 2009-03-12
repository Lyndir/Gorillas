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
//  BananaLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 08/11/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "BananaLayer.h"
#import "GorillasAppDelegate.h"


@implementation BananaLayer

@synthesize clearedGorilla, banana, throwAction;


-(id) init {
    
    if(!(self = [super init]))
        return self;
    
    banana = [[Sprite alloc] initWithFile:@"banana.png"];
    [banana setScale:[[GorillasConfig get] cityScale]];
    [banana setVisible:NO];
    [banana setTag:GorillasTagBananaNotFlying];
    
    throwAction = nil;

    return self;
}


-(void) throwFrom: (cpVect)r0 withVelocity: (cpVect)v {
    
    [self setClearedGorilla:NO];

    [throwAction release];
    [banana setPosition:r0];
    [banana runAction:[throwAction = [Throw actionWithVelocity:v startPos:r0] retain]];
}


-(void) onEnter {
    
    [super onEnter];
    
    [self addChild:banana];
}


-(void) onExit {
    
    [super onExit];
    
    [throwAction release];
    throwAction = nil;
    
    [self removeChild:banana cleanup:YES];
}


-(BOOL) throwing {
    
    return [banana tag] == GorillasTagBananaFlying;
}


-(void) dealloc {
    
    [banana release];
    banana = nil;
    
    [throwAction release];
    throwAction = nil;
    
    [super dealloc];
}


@end
