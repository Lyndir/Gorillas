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
-(void) moreGames: (id)sender;
-(void) stopGame: (id)sender;

@end


@implementation ContinueMenuLayer


-(id) init {

    if(!(self = [super initWithDelegate:self logo:nil items:
                 [CCMenuItemFont itemFromString:l(@"menu.continue.nextmatch")
                                         target:self selector:@selector(continueGame:)],
                 [CCMenuItemFont itemFromString:l(@"menu.moreGames")
                                         target:self selector:@selector(moreGames:)],
                 [CCMenuItemFont itemFromString:l(@"menu.stop")
                                         target:self selector:@selector(stopGame:)],
                 nil]))
        return self;
    
    [self setBackButtonTarget:nil selector:nil];
    
    return self;
}


-(void) continueGame: (id)sender {
    
    [[[GorillasAppDelegate get] gameLayer] startGame];
}


-(void) stopGame: (id)sender {
    
    [[GorillasAppDelegate get] showMainMenu];
}


-(void) moreGames: (id)sender {
    
    [[GorillasAppDelegate get] moreGames];
}


-(void) dealloc {
    
    [super dealloc];
}


@end
