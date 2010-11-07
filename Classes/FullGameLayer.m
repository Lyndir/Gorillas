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
- (void)back:(id)selector;

@end

@implementation FullGameLayer


-(id) init {

    if(!(self = [super init]))
        return self;
    
    NSString *fullGameData = [NSString stringWithContentsOfFile:
                              [[NSBundle mainBundle] pathForResource:@"fullGame"
                                                              ofType:@"txt"]
                                                       encoding:NSUTF8StringEncoding
                                                          error:nil];

    UITextAlignment alignment = UITextAlignmentLeft;
    if ([NSLocalizedString(@"menu.config.direction", "ltr") isEqualToString:@"rtl"]) {
        alignment = UITextAlignmentRight;
    }
    
    CCLabelTTF *pageLabel = [[CCLabelTTF alloc] initWithString:fullGameData
                                          dimensions:CGSizeMake(self.contentSize.width - self.padding.left,
                                                                self.contentSize.height - self.padding.top)
                                           alignment:alignment
                                            fontName:[GorillasConfig get].fixedFontName
                                            fontSize:[[GorillasConfig get].smallFontSize intValue]];
    [pageLabel setPosition:ccp(self.contentSize.width / 2, self.contentSize.height / 2)];
    [pageLabel runAction:[CCFadeIn actionWithDuration:[[GorillasConfig get].transitionDuration floatValue]]];
    [self addChild:pageLabel];
    [pageLabel release];

    // Back.
    [CCMenuItemFont setFontSize:[[GorillasConfig get].fontSize intValue]];
    CCMenuItem *upgrade = [CCMenuItemFont itemFromString:@"Upgrade"
                                               target:self
                                             selector:@selector(upgrade:)];
    [CCMenuItemFont setFontSize:[[GorillasConfig get].fontSize intValue]];
    
    CCMenu *buyMenu = [CCMenu menuWithItems:upgrade, nil];
    [buyMenu setPosition:ccp(self.contentSize.width - [[GorillasConfig get].fontSize intValue] * 2.5f,
                             [[GorillasConfig get].fontSize intValue])];
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
