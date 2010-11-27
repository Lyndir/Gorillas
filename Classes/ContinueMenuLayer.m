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

    if(!(self = [super initWithDelegate:self logo:nil items:
                 [CCMenuItemFont itemFromString:NSLocalizedString(@"menu.continue.nextmatch", @"Continue")
                                         target:self selector:@selector(continueGame:)],
                 [CCMenuItemFont itemFromString:NSLocalizedString(@"menu.stop", @"Main CCMenu")
                                         target:self selector:@selector(stopGame:)],
                 nil]))
        return self;
    
    return self;
}


-(void) continueGame: (id)sender {
    
    [[[GorillasAppDelegate get] gameLayer] startGame];
}


-(void) stopGame: (id)sender {
    
    [[GorillasAppDelegate get] showMainMenu];
}


-(void) dealloc {
    
    [super dealloc];
}


@end
