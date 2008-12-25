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
//  InformationLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 26/10/08.
//  Copyright 2008, lhunath (Maarten Billemont). All rights reserved.
//

#import "InformationLayer.h"
#import "GorillasConfig.h"
#import "GorillasAppDelegate.h"


@implementation InformationLayer


-(id) init {

    if(!(self = [super init]))
        return self;
    
    MenuItem *ver   = [MenuItemFont itemFromString:[[NSBundle mainBundle]
                                                    objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    [ver setIsEnabled:false];
    MenuItem *guide = [MenuItemFont itemFromString:@"Game Guide"
                                            target:self
                                          selector:@selector(guide:)];
    MenuItem *stats = [MenuItemFont itemFromString:@"Statistics"
                                            target:self
                                          selector:@selector(stats:)];
    MenuItem *back  = [MenuItemFont itemFromString:@"Back"
                                            target:self
                                          selector:@selector(mainMenu:)];
    
    menu = [[Menu menuWithItems:ver, guide, stats, back, nil] retain];
    [menu alignItemsVertically];

    return self;
}


-(void) reveal {
    
    [super reveal];
    
    [menu do:[FadeIn actionWithDuration:[[GorillasConfig get] transitionDuration]]];
    [self add:menu];
}


-(void) guide: (id) sender {
    
    [[GorillasAppDelegate get] showGuide];
}


-(void) stats: (id) sender {
    
    [[GorillasAppDelegate get] showStatistics];
}


-(void) mainMenu: (id) sender {
    
    [[GorillasAppDelegate get] showMainMenu];
}


-(void) dealloc {
    
    [menu release];
    
    [super dealloc];
}


@end
