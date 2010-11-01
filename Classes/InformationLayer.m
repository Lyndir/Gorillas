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


@interface InformationLayer ()

- (void)full:(id)sender;
- (void)guide: (id)sender;
- (void)stats: (id)sender;
- (void)back:(id)selector;

@end


@implementation InformationLayer


-(id) init {

    if(!(self = [super init]))
        return self;

    // Version string.
    [CCMenuItemFont setFontSize:[[GorillasConfig get].smallFontSize intValue]];
    [CCMenuItemFont setFontName:[GorillasConfig get].fixedFontName];
    CCMenuItem *ver   = [CCMenuItemFont itemFromString:[[NSBundle mainBundle]
                                                    objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    [ver setIsEnabled:NO];
    
    // Information menus.
    [CCMenuItemFont setFontSize:[[GorillasConfig get].fontSize intValue]];
    [CCMenuItemFont setFontName:[GorillasConfig get].fontName];
    CCMenuItem *guide = [CCMenuItemFont itemFromString:NSLocalizedString(@"entries.guide", @"Game Guide")
                                            target:self selector:@selector(guide:)];
    CCMenuItem *stats = [CCMenuItemFont itemFromString:NSLocalizedString(@"entries.stats", @"Statistics")
                                            target:self selector:@selector(stats:)];
    CCMenuItem *full  = nil;
#ifdef LITE
    full = [CCMenuItemFont itemFromString:NSLocalizedString(@"entries.fullgame", @"Full Game")
                                 target:self selector:@selector(full:)];
#endif
    
    CCMenu *menu = [CCMenu menuWithItems:ver, guide, stats, [MenuItemSpacer spacerSmall], full, nil];
    [menu alignItemsVertically];
    [self addChild:menu];

    
    // Back.
    [CCMenuItemFont setFontSize:[[GorillasConfig get].largeFontSize intValue]];
    CCMenuItem *back     = [CCMenuItemFont itemFromString:@"   <   "
                                               target: self
                                             selector: @selector(back:)];
    [CCMenuItemFont setFontSize:[[GorillasConfig get].fontSize intValue]];
    
    CCMenu *backMenu = [CCMenu menuWithItems:back, nil];
    [backMenu setPosition:ccp([[GorillasConfig get].fontSize intValue], [[GorillasConfig get].fontSize intValue])];
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
    
    [super dealloc];
}


@end
