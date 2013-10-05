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
//  HUDLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 10/11/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "GHUDLayer.h"
#import "GorillasAppDelegate.h"

@interface GHUDLayer()

@property(nonatomic, readwrite, strong) CCLabelAtlas *skillSprite;
@property(nonatomic, readwrite, strong) CCLabelAtlas *skillCount;
@property(nonatomic, readwrite, strong) CCLayer *livesLayer;
@property(nonatomic, readwrite, strong) CCSprite *infiniteLives;

@end

@implementation GHUDLayer

- (id)init {

    if (!(self = [super init]))
        return self;

    // Score.
    self.skillSprite = [CCLabelTTF labelWithString:@"Skill:" fontName:@"Bonk" fontSize:[[PearlConfig get].smallFontSize floatValue]];
    self.skillCount = [CCLabelTTF labelWithString:@"00%" fontName:@"Bonk" fontSize:[[PearlConfig get].smallFontSize floatValue]];
    [self.skillSprite setPosition:ccp(
            5 + self.scoreSprite.contentSize.width + 5 + self.scoreCount.contentSize.width + 15 + self.skillSprite.contentSize.width / 2,
            self.contentSize.height / 2 )];
    [self.skillCount setPosition:ccp(
            5 + self.scoreSprite.contentSize.width + 5 + self.scoreCount.contentSize.width + 15 + self.skillSprite.contentSize.width + 5 + self.skillCount.contentSize.width / 2,
            self.contentSize.height / 2 )];
    [self addChild:self.skillSprite];
    [self addChild:self.skillCount];

    // Lives.
    self.livesLayer = [CCLayer node];
    [self.livesLayer setVisible:NO];
    self.infiniteLives = [CCSprite spriteWithFile:@"infinite-shape.png"];
    [self.infiniteLives setPosition:ccp( [self.infiniteLives contentSize].width / 2, self.contentSize.height / 2 )];
    [self.infiniteLives setVisible:NO];
    [self.livesLayer setPosition:ccp( 20, 0 )];
    [self addChild:self.livesLayer];
    [self.livesLayer addChild:self.infiniteLives];

    return self;
}

- (void)reset {

    [super reset];

    int lives = [GorillasAppDelegate get].gameLayer.activeGorilla.lives;

    // Make sure there are enough life sprites on the livesLayer.
    NSUInteger l = [[self.livesLayer children] count] - 1;
    while ((int)[[self.livesLayer children] count] - 1 < lives) {
        CCSprite *life = [CCSprite spriteWithFile:@"gorilla-shape.png"];
        [life setPosition:ccp( l++ * [life contentSize].width + [life contentSize].width / 2, self.contentSize.height / 2 )];

        [self.livesLayer addChild:life];
    }

    // Toggle the visibility of the lives depending on how many are left.
    for (NSUInteger l = 1; l < [[self.livesLayer children] count]; ++l)
        [[[self.livesLayer children] objectAtIndex:l] setVisible:(int)l - 1 < lives];
    [self.infiniteLives setVisible:lives < 0];

    // Put score on HUD.
    if ([[GorillasAppDelegate get].gameLayer isEnabled:GorillasFeatureScore]) {
        [self.scoreCount setVisible:YES];
        [self.scoreSprite setVisible:YES];
    }
    else {
        [self.scoreCount setVisible:NO];
        [self.scoreSprite setVisible:NO];
    }

    // Put skill on HUD.
    if ([[GorillasAppDelegate get].gameLayer isEnabled:GorillasFeatureSkill]) {
        float skill = [[GorillasConfig get].skill floatValue];
        if (self.throwSkill)
            skill = skill / 2 + self.throwSkill;

        NSString *prefix = @"", *suffix = @"%";
        if ([PearlLocalize( @"menu.config.direction" ) isEqualToString:@"rtl"]) {
            prefix = @"%";
            suffix = @"";
        }
        [self.skillCount setString:[NSString stringWithFormat:@"%@%02d%@", prefix, (int)(fminf( 0.99f, skill ) * 100), suffix]];
        [self.skillCount setVisible:YES];
        [self.skillSprite setVisible:YES];
    }
    else {
        [self.skillCount setVisible:NO];
        [self.skillSprite setVisible:NO];
    }

    // Put lives on HUD.
    if ([[GorillasAppDelegate get].gameLayer isEnabled:GorillasFeatureLivesPl]
        && [GorillasAppDelegate get].gameLayer.activeGorilla.lives
        && [[GorillasAppDelegate get].gameLayer checkGameStillOn]) {
        [self.livesLayer setVisible:YES];
    }
    else
        [self.livesLayer setVisible:NO];
}

- (int64_t)score {

    return [[GorillasConfig get] scoreForMode:[GorillasAppDelegate get].gameLayer.mode];
}

- (void)setThrowSkill:(float)throwSkill {

    _throwSkill = throwSkill;
    [self reset];
}

@end
