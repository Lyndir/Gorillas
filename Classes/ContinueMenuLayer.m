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
//  ContinueMenuLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 26/10/08.
//  Copyright 2008, lhunath (Maarten Billemont). All rights reserved.
//

#import "ContinueMenuLayer.h"
#import "GorillasConfig.h"
#import "GorillasAppDelegate.h"


@implementation ContinueMenuLayer


-(id) init {

    if(!(self = [super init]))
        return self;
    
    continueGame    = [[MenuItemFont itemFromString:@"Continue"     target:self selector:@selector(continueGame:)] retain];
    stopGame        = [[MenuItemFont itemFromString:@"Main Menu"    target:self selector:@selector(stopGame:)] retain];
    
    menu            = [[Menu menuWithItems:continueGame, stopGame, nil] retain];
    [menu alignItemsVertically];
    [self add:menu];

    return self;
}


-(void) continueGame: (id)sender {
    
    [[[GorillasAppDelegate get] gameLayer] startSinglePlayer];
}


-(void) stopGame: (id)sender {
    
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
