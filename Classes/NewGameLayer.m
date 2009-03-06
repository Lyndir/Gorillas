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
//  NewGameLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 28/02/09.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "NewGameLayer.h"
#import "GorillasAppDelegate.h"
#import "MenuItemSpacer.h"


@implementation NewGameLayer


-(void) reset {
    
    if(menu) {
        [self removeAndStop:menu];
        [menu release];
        menu = nil;
        
        [self removeAndStop:backMenu];
        [backMenu release];
        backMenu = nil;
    }
    
    
    // Game Configuration.
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fontName]];
    MenuItem *configurationI    = [MenuItemFont itemFromString:[[GorillasConfig get] gameConfiguration].name
                                                   target:self
                                                 selector:@selector(gameConfiguration:)];
    [MenuItemFont setFontSize:[[GorillasConfig get] smallFontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fixedFontName]];
    MenuItem *descriptionT    = [MenuItemFont itemFromString:[[GorillasConfig get] gameConfiguration].description];
    [descriptionT setIsEnabled:NO];
    
    
    // Type (Single / Multi).
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fontName]];
    MenuItem *singlePlayerI    = [MenuItemFont itemFromString:@"Single Player"
                                                    target:self
                                                  selector:@selector(startSingle:)];
    [singlePlayerI setIsEnabled:[[GorillasConfig get] gameConfiguration].sHumans + [[GorillasConfig get] gameConfiguration].sAis > 0];
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fontName]];
    MenuItem *multiPlayerI    = [MenuItemFont itemFromString:@"Multi Player"
                                                       target:self
                                                     selector:@selector(startMulti:)];
    [multiPlayerI setIsEnabled:[[GorillasConfig get] gameConfiguration].mHumans + [[GorillasConfig get] gameConfiguration].mAis > 0];
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fontName]];
    MenuItem *customI    = [MenuItemFont itemFromString:@"Custom Game..."
                                                      target:self
                                                    selector:@selector(custom:)];
    
    
    menu = [[Menu menuWithItems:
             configurationI, descriptionT, [MenuItemSpacer small],
             singlePlayerI, multiPlayerI, [MenuItemSpacer small],
             customI,
             nil] retain];
    [menu alignItemsVertically];
    [self add:menu];
    
    
    // Back.
    [MenuItemFont setFontSize:[[GorillasConfig get] largeFontSize]];
    MenuItem *back     = [MenuItemFont itemFromString:@"   <   "
                                               target: self
                                             selector: @selector(back:)];
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    
    backMenu = [[Menu menuWithItems:back, nil] retain];
    [backMenu setPosition:cpv([[GorillasConfig get] fontSize], [[GorillasConfig get] fontSize])];
    [backMenu alignItemsHorizontally];
    [self add:backMenu];
}


-(void) onEnter {
    
    [self reset];
    
    [super onEnter];
}


-(void) gameConfiguration:(id) sender {
    
    [[GorillasAppDelegate get] clickEffect];

    ++[GorillasConfig get].activeGameConfigurationIndex;
}


-(void) startSingle: (id) sender {
    
    [[GorillasAppDelegate get] clickEffect];
    
    [[[GorillasAppDelegate get] gameLayer] configureGameWithMode:[GorillasConfig get].gameConfiguration.mode
                                                          humans:[GorillasConfig get].gameConfiguration.sHumans
                                                             ais:[GorillasConfig get].gameConfiguration.sAis];
    [[[GorillasAppDelegate get] gameLayer] startGame];
}


-(void) startMulti: (id) sender {
    
    [[GorillasAppDelegate get] clickEffect];
    
    [[[GorillasAppDelegate get] gameLayer] configureGameWithMode:[GorillasConfig get].gameConfiguration.mode
                                                          humans:[GorillasConfig get].gameConfiguration.mHumans
                                                             ais:[GorillasConfig get].gameConfiguration.mAis];
    [[[GorillasAppDelegate get] gameLayer] startGame];
}


-(void) custom: (id) sender {
    
    [[GorillasAppDelegate get] clickEffect];
    [[GorillasAppDelegate get] showCustomGame];
}


-(void) back: (id) sender {
    
    [[GorillasAppDelegate get] clickEffect];
    [[GorillasAppDelegate get] popLayer];
}


-(void) dealloc {
    
    [menu release];
    menu = nil;
    
    [backMenu release];
    backMenu = nil;
    
    [super dealloc];
}


@end
