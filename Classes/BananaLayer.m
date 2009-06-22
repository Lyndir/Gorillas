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


@interface BananaLayer (Private)

-(NSString *) modelFile;

@end

@implementation BananaLayer

@synthesize clearedGorilla, banana, throwAction, model, focussed;


-(id) init {
    
    if(!(self = [super init]))
        return self;
    
    model           = GorillasProjectileModelBanana;
    
    banana          = [[Sprite alloc] initWithFile:[self modelFile]];
    [banana setScale:[[GorillasConfig get] cityScale]];
    [banana setVisible:NO];
    [banana setTag:GorillasTagBananaNotFlying];
    
    throwAction     = nil;
    focussed        = NO;

    return self;
}


-(void) setModel:(GorillasProjectileModel)aModel type:(GorillasPlayerType)aType {
    
    model = aModel;
    type = aType;
    [banana setTexture:[[TextureMgr sharedTextureMgr] addImage:[self modelFile]]];
}


-(void) throwFrom: (cpVect)r0 withVelocity: (cpVect)v {
    
    [self setClearedGorilla:NO];

    [throwAction release];
    [banana setPosition:r0];
    [banana runAction:[throwAction = [Throw actionWithVelocity:v startPos:r0] retain]];
    //[throwAction setFocussed:focussed];
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


-(NSString *) modelFile {

    NSString *modelName, *typeName;
    switch (model) {
        case GorillasProjectileModelBanana:
            modelName = @"banana";
            break;
        case GorillasProjectileModelEasterEgg:
            modelName = @"egg";
            break;
        case GorillasProjectileModelGorilla:
            modelName = @"gorilla";
            break;
        default:
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:@"Active banana model not implemented." userInfo:nil];
    }
    switch (type) {
        case GorillasPlayerTypeAI:
            typeName = @"ai";
            break;
        case GorillasPlayerTypeHuman:
            typeName = @"human";
            break;
        default:
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:@"Active gorilla type not implemented." userInfo:nil];
    }
    
    return [NSString stringWithFormat:@"%@-%@.png", modelName, typeName];
}


-(void) dealloc {
    
    [banana release];
    banana = nil;
    
    [throwAction release];
    throwAction = nil;
    
    [super dealloc];
}


@end
