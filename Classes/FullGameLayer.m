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
//  FullGameLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 08/06/09.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "FullGameLayer.h"
#import "GorillasAppDelegate.h"


@implementation FullGameLayer


-(id) init {

    if(!(self = [super init]))
        return self;
    
    NSString *fullGameData = [NSString stringWithContentsOfFile:
                              [[NSBundle mainBundle] pathForResource:@"fullGame"
                                                              ofType:@"txt"]];

    UITextAlignment alignment = UITextAlignmentLeft;
    if ([NSLocalizedString(@"config.direction", "ltr") isEqualToString:@"rtl"]) {
        alignment = UITextAlignmentRight;
    }
    
    Label *pageLabel = [[Label alloc] initWithString:fullGameData
                                       dimensions:CGSizeMake(contentSize.width - padding, contentSize.height - padding)
                                        alignment:alignment
                                         fontName:[[GorillasConfig get] fixedFontName]
                                         fontSize:[[GorillasConfig get] smallFontSize]];
    [pageLabel setPosition:cpv(contentSize.width / 2, contentSize.height / 2)];
    [pageLabel runAction:[FadeIn actionWithDuration:[[GorillasConfig get] transitionDuration]]];
    [self addChild:pageLabel];

    // Back.
    [MenuItemFont setFontSize:[[GorillasConfig get] largeFontSize]];
    MenuItem *back = [MenuItemFont itemFromString:@"   <   "
                                               target:self
                                             selector:@selector(back:)];
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    
    backMenu = [[Menu menuWithItems:back, nil] retain];
    [backMenu setPosition:cpv([[GorillasConfig get] fontSize], [[GorillasConfig get] fontSize])];
    [backMenu alignItemsHorizontally];
    [self addChild:backMenu];

    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    MenuItem *upgrade = [MenuItemFont itemFromString:@"Upgrade"
                                               target:self
                                             selector:@selector(upgrade:)];
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    
    Menu *buyMenu = [[Menu menuWithItems:upgrade, nil] retain];
    [buyMenu setPosition:cpv(contentSize.width - [[GorillasConfig get] fontSize] * 2.5f, [[GorillasConfig get] fontSize])];
    [buyMenu alignItemsHorizontally];
    [self addChild: buyMenu];
    
    
    return self;
}


-(void) back: (id) sender {
    
    [[GorillasAudioController get] clickEffect];
    [[GorillasAppDelegate get] popLayer];
}


-(void) upgrade: (id) sender {
    
    [[GorillasAudioController get] clickEffect];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=302275459&mt=8&s=143441"]];
}


-(void) dealloc {
    
    [backMenu release];
    backMenu = nil;
    
    [super dealloc];
}


@end
