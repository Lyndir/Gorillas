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
//  TrainingConfiguration.m
//  Gorillas
//
//  Created by Maarten Billemont on 15/02/09.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "TrainingConfigurationLayer.h"
#import "GorillasAppDelegate.h"


@implementation TrainingConfigurationLayer


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
    
    
    // Training Mode.
    [MenuItemFont setFontSize:[[GorillasConfig get] smallFontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fixedFontName]];
    MenuItem *trainingT    = [MenuItemFont itemFromString:@"Training Mode"];
    [trainingT setIsEnabled:false];
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fontName]];
    MenuItem *trainingI    = [MenuItemFont itemFromString:[[GorillasConfig get] training]? @"On": @"Off"
                                                   target:self
                                                 selector:@selector(training:)];
    
    
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
    
    
    menu = [[Menu menuWithItems:trainingT, trainingI, throwHintsT, throwHistoryT, throwHintsI, throwHistoryI, nil] retain];
    [menu alignItemsInColumns:
     [NSNumber numberWithUnsignedInteger:1],
     [NSNumber numberWithUnsignedInteger:1],
     [NSNumber numberWithUnsignedInteger:2],
     [NSNumber numberWithUnsignedInteger:2],
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


-(void) training: (id) sender {
    
    [[GorillasAppDelegate get] clickEffect];
    [[GorillasConfig get] setTraining:![[GorillasConfig get] training]];
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
