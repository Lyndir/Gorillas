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
//  BootCampConfiguration.m
//  Gorillas
//
//  Created by Maarten Billemont on 15/02/09.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "BootCampConfigurationLayer.h"
#import "GorillasAppDelegate.h"


@implementation BootCampConfigurationLayer


-(id) init {
    
    if(!(self = [super init]))
        return self;
    
    return self;
}


-(void) reset {
    
    if(menu) {
        [self removeAndStop:menu];
        [menu release];
        menu = nil;
        
        [self removeAndStop:backMenu];
        [backMenu release];
        backMenu = nil;
    }
    
    
    // Throw Hints.
    [MenuItemFont setFontSize:[[GorillasConfig get] smallFontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fixedFontName]];
    MenuItem *throwHintsT  = [MenuItemFont itemFromString:@"Throw Hints"];
    [throwHintsT setIsEnabled:false];
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fontName]];
    MenuItem *throwHintsI  = [MenuItemFont itemFromString:[[GorillasConfig get] throwHint]? @"On": @"Off"
                                                   target:self
                                                 selector:@selector(throwHint:)];
    
    
    // Throw History.
    [MenuItemFont setFontSize:[[GorillasConfig get] smallFontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fixedFontName]];
    MenuItem *throwHistoryT  = [MenuItemFont itemFromString:@"Throw History"];
    [throwHistoryT setIsEnabled:false];
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fontName]];
    MenuItem *throwHistoryI  = [MenuItemFont itemFromString:[[GorillasConfig get] throwHistory]? @"On": @"Off"
                                                     target:self
                                                   selector:@selector(throwHistory:)];
    
    
    menu = [[Menu menuWithItems:throwHintsT, throwHintsI, throwHistoryT, throwHistoryI, nil] retain];
    [menu alignItemsInRows:
     [NSNumber numberWithUnsignedInteger:4],
     nil];
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


-(void) throwHint: (id) sender {
    
    [[GorillasAppDelegate get] clickEffect];
    [[GorillasConfig get] setThrowHint:![[GorillasConfig get] throwHint]];
}


-(void) throwHistory: (id) sender {
    
    [[GorillasAppDelegate get] clickEffect];
    [[GorillasConfig get] setThrowHistory:![[GorillasConfig get] throwHistory]];
}


-(void) back: (id) sender {
    
    [[GorillasAppDelegate get] clickEffect];
    [[GorillasAppDelegate get] showConfiguration];
}


-(void) dealloc {
    
    [menu release];
    menu = nil;
    
    [backMenu release];
    backMenu = nil;
    
    [super dealloc];
}


@end
