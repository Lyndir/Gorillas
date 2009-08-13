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
//  FullGameLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 08/06/09.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "FullGameLayer.h"
#import "GorillasAppDelegate.h"


@interface FullGameLayer ()

- (void)upgrade:(id)sender;

@end

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
                                            fontName:[GorillasConfig get].fixedFontName
                                            fontSize:[[GorillasConfig get].smallFontSize intValue]];
    [pageLabel setPosition:ccp(contentSize.width / 2, contentSize.height / 2)];
    [pageLabel runAction:[FadeIn actionWithDuration:[[GorillasConfig get].transitionDuration floatValue]]];
    [self addChild:pageLabel];
    [pageLabel release];

    // Back.
    [MenuItemFont setFontSize:[[GorillasConfig get].largeFontSize intValue]];
    MenuItem *back = [MenuItemFont itemFromString:@"   <   "
                                               target:self
                                             selector:@selector(back:)];
    [MenuItemFont setFontSize:[[GorillasConfig get].fontSize intValue]];
    
    Menu *backMenu = [Menu menuWithItems:back, nil];
    [backMenu setPosition:ccp([[GorillasConfig get].fontSize intValue], [[GorillasConfig get].fontSize intValue])];
    [backMenu alignItemsHorizontally];
    [self addChild:backMenu];

    [MenuItemFont setFontSize:[[GorillasConfig get].fontSize intValue]];
    MenuItem *upgrade = [MenuItemFont itemFromString:@"Upgrade"
                                               target:self
                                             selector:@selector(upgrade:)];
    [MenuItemFont setFontSize:[[GorillasConfig get].fontSize intValue]];
    
    Menu *buyMenu = [Menu menuWithItems:upgrade, nil];
    [buyMenu setPosition:ccp(contentSize.width - [[GorillasConfig get].fontSize intValue] * 2.5f, [[GorillasConfig get].fontSize intValue])];
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
    
    [super dealloc];
}


@end
