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
//  ContinueMenuLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 26/10/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "ContinueMenuLayer.h"
#import "GorillasAppDelegate.h"
#import "MenuItemSpacer.h"


@interface ContinueMenuLayer ()

-(void) continueGame: (id)sender;
-(void) stopGame: (id)sender;

@end


@implementation ContinueMenuLayer


-(id) init {

    if(!(self = [super init]))
        return self;
    
    CCMenuItem *continueGame      = [CCMenuItemFont itemFromString:NSLocalizedString(@"entries.continue.nextmatch", @"Continue")
                                                        target:self selector:@selector(continueGame:)];
    CCMenuItem *stopGame          = [CCMenuItemFont itemFromString:NSLocalizedString(@"entries.stop", @"Main CCMenu")
                                                        target:self selector:@selector(stopGame:)];
    
    CCMenu *menu                  = [CCMenu menuWithItems:
                                   continueGame, [MenuItemSpacer small],
                                   stopGame,
                                   nil];
    [menu alignItemsVertically];
    [self addChild:menu];

    return self;
}


-(void) continueGame: (id)sender {
    
    [[GorillasAudioController get] clickEffect];
    [[[GorillasAppDelegate get] gameLayer] startGame];
}


-(void) stopGame: (id)sender {
    
    [[GorillasAudioController get] clickEffect];
    [[GorillasAppDelegate get] showMainMenu];
}


-(void) dealloc {
    
    [super dealloc];
}


@end
