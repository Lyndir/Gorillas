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
//  HUDLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 10/11/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "HUDLayer.h"
#import "GorillasAppDelegate.h"
#import "ShadeTo.h"

@interface HUDLayer (Private)

-(void) setInfoString: (NSString *)string;

@end

@implementation HUDLayer


-(id) init {
    
    if(!(self = [super initWithColorFrom:0x000000FF to:0x666666FF position:cpvzero]))
        return self;

    [super setButtonString:@"Menu"
                  callback:self :@selector(menuButton:)];
    messageBar          = [[BarLayer alloc] initWithColorFrom:0x666666FF to:0x000000FF position:cpv(0, height)];
    
    // Score.
    infoLabel = [[LabelAtlas alloc] initWithString:@""
                                       charMapFile:@"bonk.png" itemWidth:13 itemHeight:26 startCharMap:' '];
    [infoLabel setPosition:cpvzero];
    [self addChild:infoLabel];
    
    // Lives.
    livesLayer = [[Layer alloc] init];
    [livesLayer setVisible:NO];
    infiniteLives = [Sprite spriteWithFile:@"infinite-shape.png"];
    [infiniteLives setPosition:cpv([infiniteLives contentSize].width / 2, height / 2)];
    [infiniteLives setVisible:NO];
    [self addChild:livesLayer];
    [livesLayer addChild:infiniteLives];
    
    return self;
}


-(void) updateHudWithScore:(int)score skill: (float)throwSkill {
    
    int lives = [GorillasAppDelegate get].gameLayer.activeGorilla.lives;
    NSMutableString *infoString = [[NSMutableString alloc] initWithCapacity:20];
    
    // Make sure there are enough life sprites on the livesLayer.
    NSUInteger l = [[livesLayer children] count] - 1;
    while((int)[[livesLayer children] count] - 1 < lives) {
        Sprite *life = [Sprite spriteWithFile:@"gorilla-shape.png"];
        [life setPosition:cpv(l++ * [life contentSize].width + [life contentSize].width / 2, height / 2)];
        
        [livesLayer addChild:life];
    }
    
    // Toggle the visibility of the lives depending on how many are left.
    for(int l = 1; l < (int)[[livesLayer children] count]; ++l)
        [[[livesLayer children] objectAtIndex:l] setVisible:l - 1 < lives];
    [infiniteLives setVisible:lives < 0];

    // Boot Camp message.
    if ([[GorillasAppDelegate get].gameLayer isEnabled:GorillasFeatureCheat]) {
        if([infoString length])
            [infoString appendString:@"  "];
        
        [infoString appendString:@"Boot Camp"];
        [infoLabel setRGB:0xff :0xff :0x99];
    }
    
    // Put score on HUD.
    if ([[GorillasAppDelegate get].gameLayer isEnabled:GorillasFeatureScore]) {
        if([infoString length])
            [infoString appendString:@"  "];
        
        [infoString appendFormat:@"Score:%03d", [[GorillasConfig get] score]];
    }

    // Put skill on HUD.
    if ([[GorillasAppDelegate get].gameLayer isEnabled:GorillasFeatureSkill]) {
        if([infoString length])
            [infoString appendString:@"  "];
    
        float skill = [[GorillasConfig get] skill];
        if(throwSkill)
            skill = [[GorillasConfig get] skill] / 2 + throwSkill;
        
        [infoString appendFormat:@"Skill:%02d%%", (int) (fminf(0.99f, skill) * 100)];
    }
    
    // Put name and lives on HUD.
    if([GorillasAppDelegate get].gameLayer.activeGorilla.name) {
        if([infoString length])
            [infoString appendString:@"  "];
    
        [infoString appendString:[GorillasAppDelegate get].gameLayer.activeGorilla.name];
    }
    if ([[GorillasAppDelegate get].gameLayer isEnabled:GorillasFeatureLivesPl]
        && [GorillasAppDelegate get].gameLayer.activeGorilla.lives
        && [[GorillasAppDelegate get].gameLayer checkGameStillOn]) {
        if([infoString length])
            [infoString appendString:@":"];
        [livesLayer setVisible:YES];
    } else
        [livesLayer setVisible:NO];

    [self setInfoString:infoString];
    [infoString release];

    if(score) {
        long scoreColor;
        if(score > 0)
            scoreColor = 0x99FF99ff;
        else if(score < 0)
            scoreColor = 0xFF9999ff;
        
        [infoLabel runAction:[Sequence actions:
                              [ShadeTo actionWithDuration:0.5f color:scoreColor],
                              [ShadeTo actionWithDuration:0.5f color:0xFFFFFFff],
                              nil]];
    }
}


-(void) setInfoString: (NSString *)string {
    
    [infoLabel setString:[NSString stringWithFormat:@" %@", string]];
    [livesLayer setPosition:cpv([infoLabel position].x + 13 * ([string length] + 1), [infoLabel position].y)];
}


-(void) message:(NSString *)msg duration:(ccTime)_duration isImportant:(BOOL)important {
    // Proxy to messageBar
    
    if([messageBar parent] && [messageBar dismissed])
        [self removeChild:messageBar cleanup:YES];

    if(![messageBar parent])
        [self addChild:messageBar z:-1];
    
    [messageBar message:msg duration:0 isImportant:important];
    
    if(_duration)
        [self runAction:[Sequence actions:
                         [DelayTime actionWithDuration:_duration],
                         [CallFunc actionWithTarget:self selector:@selector(dismissMessage)],
                         nil]];
}


-(void) dismissMessage {
    // Proxy to messageBar

    [messageBar dismiss];
    [messageBar setButtonString:nil callback:nil :nil];
    
    if(![menuMenu parent])
        [self addChild:menuMenu];
}


-(void) setButtonString:(NSString *)_string callback:(id)target :(SEL)selector {
    // Proxy to messageBar

    [messageBar setButtonString:_string callback:target :selector];
    [self removeChild:menuMenu cleanup:NO];
}


-(void) onEnter {

    [super onEnter];
    
    if([messageBar parent])
        [self removeChild:messageBar cleanup:YES];
    
    [self updateHudWithScore:0 skill:0];
}

-(void) onExit {
    
    [super onExit];
}

-(void) dismiss {
    
    [super dismiss];
}


-(void) menuButton: (id) caller {
    
    [[GorillasAudioController get] clickEffect];
    [[GorillasAppDelegate get] showMainMenu];
}


-(BOOL) hitsHud: (cpVect)pos {
    
    return  pos.x >= position.x         &&
            pos.y >= position.y         &&
            pos.x <= position.x + width &&
            pos.y <= position.y + height;
}


-(void) dealloc {
    
    [infoLabel release];
    infoLabel = nil;
    
    [super dealloc];
}


@end
