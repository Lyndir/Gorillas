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
#import "ShadeTo.h"

@interface GHUDLayer ()

@property (readwrite, retain) CCSprite                 *skillSprite;
@property (readwrite, retain) CCLabelAtlas             *skillCount;
@property (readwrite, retain) CCLayer                  *livesLayer;
@property (readwrite, retain) CCSprite                 *infiniteLives;

@end


@implementation GHUDLayer

@synthesize skillSprite     = _skillSprite;
@synthesize skillCount      = _skillCount;
@synthesize livesLayer      = _livesLayer;
@synthesize infiniteLives   = _infiniteLives;


-(id) init {
    
    if(!(self = [super init]))
        return self;

    // Score.
    self.skillSprite = [CCSprite spriteWithFile:@"skill.png"];
    self.skillCount = [CCLabelAtlas labelWithString:@""
                                        charMapFile:@"bonk.png" itemWidth:13 itemHeight:26 startCharMap:' '];
    [self.skillSprite setPosition:ccp(self.contentSize.width / 2, self.contentSize.height / 2)];
    [self.skillCount setPosition:ccp(230, 0)];
    [self addChild:self.skillSprite];
    [self addChild:self.skillCount];
    
    // Lives.
    self.livesLayer = [CCLayer node];
    [self.livesLayer setVisible:NO];
    self.infiniteLives = [CCSprite spriteWithFile:@"infinite-shape.png"];
    [self.infiniteLives setPosition:ccp([self.infiniteLives contentSize].width / 2, self.contentSize.height / 2)];
    [self.infiniteLives setVisible:NO];
    [self.livesLayer setPosition:ccp(20, 0)];
    [self addChild:self.livesLayer];
    [self.livesLayer addChild:self.infiniteLives];
    
    return self;
}


-(void) updateHudWithNewScore:(int)newScore skill:(float)throwSkill wasGood:(BOOL)wasGood {
    
    int lives = [GorillasAppDelegate get].gameLayer.activeGorilla.lives;
    
    // Make sure there are enough life sprites on the livesLayer.
    NSUInteger l = [[self.livesLayer children] count] - 1;
    while((int)[[self.livesLayer children] count] - 1 < lives) {
        CCSprite *life = [CCSprite spriteWithFile:@"gorilla-shape.png"];
        [life setPosition:ccp(l++ * [life contentSize].width + [life contentSize].width / 2, self.contentSize.height / 2)];
        
        [self.livesLayer addChild:life];
    }
    
    // Toggle the visibility of the lives depending on how many are left.
    for(int l = 1; l < (int)[[self.livesLayer children] count]; ++l)
        [[[self.livesLayer children] objectAtIndex:l] setVisible:l - 1 < lives];
    [self.infiniteLives setVisible:lives < 0];

    // Put score on HUD.
    if ([[GorillasAppDelegate get].gameLayer isEnabled:GorillasFeatureScore])
        [self updateHudWithNewScore:[[GorillasConfig get].score intValue] wasGood:YES];
    else {
        [self.scoreCount setVisible:NO];
        [self.scoreSprite setVisible:NO];
    }

    // Put skill on HUD.
    if ([[GorillasAppDelegate get].gameLayer isEnabled:GorillasFeatureSkill]) {
        float skill = [[GorillasConfig get].skill floatValue];
        if(throwSkill)
            skill = skill / 2 + throwSkill;
        
        NSString *prefix = @"", *suffix = @"%";
        if ([NSLocalizedString(@"config.direction", "ltr") isEqualToString:@"rtl"]) {
            prefix = @"%";
            suffix = @"";
        }
        [self.skillCount setString:[NSString stringWithFormat:@"%@%02d%@", prefix, (int) (fminf(0.99f, skill) * 100), suffix]];
        [self.skillCount setVisible:YES];
        [self.skillSprite setVisible:YES];
    } else {
        [self.skillCount setVisible:NO];
        [self.skillSprite setVisible:NO];
    }
    
    // Put lives on HUD.
    if ([[GorillasAppDelegate get].gameLayer isEnabled:GorillasFeatureLivesPl]
        && [GorillasAppDelegate get].gameLayer.activeGorilla.lives
        && [[GorillasAppDelegate get].gameLayer checkGameStillOn]) {
        [self.livesLayer setVisible:YES];
    } else
        [self.livesLayer setVisible:NO];
}

-(void) updateHudWithNewScore:(int)newScore wasGood:(BOOL)wasGood {
    
    [self.scoreCount setString:[NSString stringWithFormat:@"%02d", newScore]];
    [self updateHudWasGood:wasGood];
}

-(void) dealloc {
    
    self.skillSprite    = nil;
    self.skillCount     = nil;
    self.livesLayer     = nil;
    self.infiniteLives  = nil;
    
    [super dealloc];
}


@end
