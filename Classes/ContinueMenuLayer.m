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


@implementation ContinueMenuLayer


-(id) init {

    if(!(self = [super init]))
        return self;
    
    continueGame    = [[MenuItemFont itemFromString:NSLocalizedString(@"entries.continue.nextmatch", @"Continue")
                                             target:self selector:@selector(continueGame:)] retain];
    stopGame        = [[MenuItemFont itemFromString:NSLocalizedString(@"entries.stop", @"Main Menu")
                                             target:self selector:@selector(stopGame:)] retain];
    
    menu            = [[Menu menuWithItems:
                        continueGame, [MenuItemSpacer small],
                        stopGame,
                        nil] retain];
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
    
    [menu release];
    menu = nil;
    
    [continueGame release];
    continueGame = nil;
    
    [stopGame release];
    stopGame = nil;
    
    [super dealloc];
}


@end
