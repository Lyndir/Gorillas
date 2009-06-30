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
//  InformationLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 26/10/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "InformationLayer.h"
#import "GorillasAppDelegate.h"
#import "MenuItemSpacer.h"


@implementation InformationLayer


-(id) init {

    if(!(self = [super init]))
        return self;

    // Version string.
    [MenuItemFont setFontSize:[[GorillasConfig get] smallFontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fixedFontName]];
    MenuItem *ver   = [MenuItemFont itemFromString:[[NSBundle mainBundle]
                                                    objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    [ver setIsEnabled:NO];
    
    // Information menus.
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fontName]];
    MenuItem *guide = [MenuItemFont itemFromString:NSLocalizedString(@"entries.guide", @"Game Guide")
                                            target:self selector:@selector(guide:)];
    MenuItem *stats = [MenuItemFont itemFromString:NSLocalizedString(@"entries.stats", @"Statistics")
                                            target:self selector:@selector(stats:)];
    MenuItem *full  = nil;
#ifdef LITE
    full = [MenuItemFont itemFromString:NSLocalizedString(@"entries.fullgame", @"Full Game")
                                 target:self selector:@selector(full:)];
#endif
    
    menu = [[Menu menuWithItems:ver, guide, stats, [MenuItemSpacer small], full, nil] retain];
    [menu alignItemsVertically];
    [self addChild:menu];

    
    // Back.
    [MenuItemFont setFontSize:[[GorillasConfig get] largeFontSize]];
    MenuItem *back     = [MenuItemFont itemFromString:@"   <   "
                                               target: self
                                             selector: @selector(back:)];
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    
    backMenu = [[Menu menuWithItems:back, nil] retain];
    [backMenu setPosition:ccp([[GorillasConfig get] fontSize], [[GorillasConfig get] fontSize])];
    [backMenu alignItemsHorizontally];
    [self addChild:backMenu];

    
    return self;
}


-(void) guide: (id) sender {
    
    [[GorillasAudioController get] clickEffect];
    [[GorillasAppDelegate get] showGuide];
}


-(void) stats: (id) sender {
    
    [[GorillasAudioController get] clickEffect];
    [[GorillasAppDelegate get] showStatistics];
}


-(void) full: (id) sender {
    
    [[GorillasAudioController get] clickEffect];
    [[GorillasAppDelegate get] showFullGame];
}


-(void) back: (id) sender {
    
    [[GorillasAudioController get] clickEffect];
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
