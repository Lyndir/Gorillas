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
#import "MenuItemTitle.h"


@interface InformationLayer ()

- (void)full:(id)sender;
- (void)guide: (id)sender;
- (void)stats: (id)sender;
- (void)back:(id)selector;

@end


@implementation InformationLayer


-(id) init {

    CCMenuItem *full  = nil;
#ifdef LITE
    full = [CCMenuItemFont itemFromString:NSLocalizedString(@"menu.fullgame", @"Full Game")
                                   target:self selector:@selector(full:)];
#endif
    
    if(!(self = [super initWithDelegate:self logo:nil items:
                 [MenuItemTitle itemFromString:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]],
                 [CCMenuItemFont itemFromString:NSLocalizedString(@"menu.guide", @"Game Guide")
                                         target:self selector:@selector(guide:)],
                 [CCMenuItemFont itemFromString:NSLocalizedString(@"menu.stats", @"Statistics")
                                         target:self selector:@selector(stats:)],
                 [MenuItemSpacer spacerSmall],
                 full,
                 nil]))
        return self;
    
    return self;
}


-(void) guide: (id) sender {
    
    [[GorillasAppDelegate get] showGuide];
}


-(void) stats: (id) sender {

    // TODO: GK top scores.
}


-(void) full: (id) sender {
    
    [[GorillasAppDelegate get] showFullGame];
}


-(void) back: (id) sender {
    
    [[GorillasAppDelegate get] popLayer];
}


-(void) dealloc {
    
    [super dealloc];
}


@end
