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
//  GorillaLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 07/11/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "GorillaLayer.h"
#import "GorillasAppDelegate.h"
#import "ShadeTo.h"
#import "Remove.h"


@interface GorillaLayer (Private)

-(void) dd;
-(void) ud;
-(void) du;
-(void) uu;

@end

static NSUInteger _teamIndex, _globalIndex;

@implementation GorillaLayer

@synthesize human, name, turns, lives, active, zoom, teamIndex, globalIndex;


+(void) prepareCreation {

    _teamIndex      = 0;
    _globalIndex    = 0;
}


-(id) initWithName:(NSString *)_name isHuman:(BOOL)_human {
    
    type    = _human? @"brown": @"silver";
    
    if(!(self = [super initWithFile:[NSString stringWithFormat:@"gorilla-%@-DD.png", type]]))
        return self;
    
    name        = [_name retain];
    teamIndex   = _teamIndex++;
    globalIndex = _globalIndex++;

    zoom    = 1;
    
    dd      = [texture retain];
    ud      = [[[TextureMgr sharedTextureMgr] addImage:[NSString stringWithFormat:@"gorilla-%@-UD.png", type]] retain];
    du      = [[[TextureMgr sharedTextureMgr] addImage:[NSString stringWithFormat:@"gorilla-%@-DU.png", type]] retain];
    uu      = [[[TextureMgr sharedTextureMgr] addImage:[NSString stringWithFormat:@"gorilla-%@-UU.png", type]] retain];
    
    human   = _human;
    bobber  = [[Sprite alloc] initWithFile:@"bobber.png"];
    [bobber setPosition:cpv([self contentSize].width / 2,
                            [self contentSize].height + [bobber contentSize].height / 2 + 15)];
    [bobber runAction:[RepeatForever actionWithAction:[Sequence actions:
                                                       [EaseSineInOut actionWithAction:[MoveBy actionWithDuration:0.7f position:cpv(0, 15)]],
                                                       [EaseSineInOut actionWithAction:[MoveBy actionWithDuration:0.7f position:cpv(0, -15)]],
                                                       nil]]];
    [bobber setVisible:NO];
    [self addChild:bobber];
    [self setScale:[[GorillasConfig get] cityScale]];

    // By default, a gorilla has 1 life, unless features say otherwise.
    initialLives = 1;
    if(human && [[GorillasAppDelegate get].gameLayer isEnabled:GorillasFeatureLivesPl])
        // Human gorillas with lives enabled.
        initialLives = [[GorillasConfig get] lives];
    else if(!human) {
        if ([[GorillasAppDelegate get].gameLayer isEnabled:GorillasFeatureLivesAi])
            // AI gorillas with lives enabled.
            initialLives = [[GorillasConfig get] lives];
        else if([[GorillasAppDelegate get].gameLayer isEnabled:GorillasFeatureLivesPl])
            // AI gorillas without lives enabled get infinite lives when humans have lives enabled.
            initialLives = -1;
    }
    lives = initialLives;
    
    return self;
}


-(BOOL) alive {
    
    // More than (or less than!) zero means gorilla is alive.
    return lives != 0;
}


-(void) cheer {
    
    [self runAction:[Sequence actions:
                     [CallFunc actionWithTarget:self selector:@selector(uu)],
                     [DelayTime actionWithDuration:0.4f],
                     [CallFunc actionWithTarget:self selector:@selector(dd)],
                     [DelayTime actionWithDuration:0.2f],
                     [CallFunc actionWithTarget:self selector:@selector(uu)],
                     [DelayTime actionWithDuration:1],
                     [CallFunc actionWithTarget:self selector:@selector(dd)],
                     nil]];
}


-(void) dance {
    
    [self runAction:[Sequence actions:
                     [Repeat actionWithAction:[Sequence actions:
                                               [CallFunc actionWithTarget:self selector:@selector(ud)],
                                               [DelayTime actionWithDuration:0.2f],
                                               [CallFunc actionWithTarget:self selector:@selector(du)],
                                               [DelayTime actionWithDuration:0.2f],
                                               nil]
                                        times:7],
                     [CallFunc actionWithTarget:self selector:@selector(uu)],
                     [DelayTime actionWithDuration:0.5f],
                     [CallFunc actionWithTarget:self selector:@selector(dd)],
                     nil]];
}


-(void) threw:(cpVect)aim {

    if(aim.x > 0)
        [self ud];
    else
        [self du];
    
    [self runAction:[Sequence actions:
                     [DelayTime actionWithDuration:0.5f],
                     [CallFunc actionWithTarget:self selector:@selector(dd)],
                     nil]];
}


-(void) dd {
    
    [self setTexture:dd];
}


-(void) ud {
    
    [self setTexture:ud];
}


-(void) du {
    
    [self setTexture:du];
}


-(void) uu {
    
    [self setTexture:uu];
}


-(void) kill {
    
    if(lives > 0)
        --lives;

    if(lives == 0) {
        [self stopAllActions];
        [self runAction:[Sequence actions:
                         [FadeTo actionWithDuration:0.5f opacity:0x00],
                         [Remove action],
                         nil]];
    } else
        [self runAction:[Sequence actions:
                         [ShadeTo actionWithDuration:0.5f color:0xFF0000FF],
                         [ShadeTo actionWithDuration:0.5f color:0xFFFFFFFF],
                         nil]];

    [[GorillasAppDelegate get].hudLayer updateHudWithScore:0 skill:0];
}


-(void) killDead {
    
    lives = 1;
    
    [self kill];
}


-(void) revive {
    
    lives = 1;
    
    [self stopAllActions];
    [self runAction:[FadeTo actionWithDuration:0.5f opacity:0xFF]];
}


-(void) setActive:(BOOL)_active {
    
    active = _active;
    
    [bobber setVisible:active];
    [[GorillasAppDelegate get].hudLayer updateHudWithScore:0 skill:0];
}


-(BOOL) hitsGorilla: (cpVect)pos {
    
    if(![self alive])
        return NO;
    
    return  pos.x >= position.x - [self contentSize].width  / 2 &&
            pos.y >= position.y - [self contentSize].height / 2 &&
            pos.x <= position.x + [self contentSize].width  / 2 &&
            pos.y <= position.y + [self contentSize].height / 2;
}


-(CGSize) contentSize {
    
    return CGSizeMake([super contentSize].width * [self scale], [super contentSize].height * [self scale]);
}


-(void) draw {

    [super draw];
    
    if(lives <= 0)
        return;
    
    if(human && ![[GorillasAppDelegate get].gameLayer isEnabled:GorillasFeatureLivesPl])
       return;

    if(!human && ![[GorillasAppDelegate get].gameLayer isEnabled:GorillasFeatureLivesAi])
       return;
    
    cpFloat barX = [self contentSize].width / 2;
    cpFloat barY = [self contentSize].height + 10;
    cpFloat barW = 40;
    cpVect lines[4] = {
        cpv(barX - barW / 2, barY),
        cpv(barX - barW / 2 + barW * lives / initialLives, barY),
        cpv(barX - barW / 2 + barW * lives / initialLives, barY),
        cpv(barX - barW / 2 + barW, barY),
    };
    long colors[4] = {
        0xFF33CC33,
        0xFF33CC33,
        0xFF3333CC,
        0xFF3333CC,
    };
    
    GLubyte o = active? 0xFF: 0x33;
    
    if ([[GorillasConfig get] visualFx]) {
        drawBoxFrom(cpvadd(lines[0], cpv(0, -3)), cpvadd(lines[1], cpv(0, 3)), 0xCCFFCC00 | o, 0x33CC3300 | o);
        drawBoxFrom(cpvadd(lines[2], cpv(0, -3)), cpvadd(lines[3], cpv(0, 3)), 0xFFCCCC00 | o, 0xCC333300 | o);
    }
    else
        drawLines(lines, colors, 4, 6);
    
    drawBorderFrom(cpvadd(lines[0], cpv(0, -3)), cpvadd(lines[3], cpv(0, 3)), 0xCCCC3300 | (o - 0x33), 1);
}


-(void) dealloc {
    
    [name release];
    name = nil;
    
    [super dealloc];
}


@end
