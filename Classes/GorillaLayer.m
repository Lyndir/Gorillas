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

-(NSString *) modelFileWithArmsUpLeft:(BOOL)left right:(BOOL)right;

@end

static NSUInteger _teamIndex, _globalIndex;

@implementation GorillaLayer

@synthesize human, name, turns, lives, active, zoom, teamIndex, globalIndex, model, type;


+(void) prepareCreation {

    _teamIndex      = 0;
    _globalIndex    = 0;
}


-(id) initWithName:(NSString *)_name type:(GorillasPlayerType)_type {
    
    model   = [GorillasConfig get].playerModel;
    type    = _type;
    
    if(!(self = [super initWithFile:[self modelFileWithArmsUpLeft:NO right:NO]]))
        return self;
    
    name        = [_name retain];
    teamIndex   = _teamIndex++;
    globalIndex = _globalIndex++;

    zoom    = 1;

    bobber  = [[Sprite alloc] initWithFile:@"bobber.png"];
    [bobber setPosition:ccp([self contentSize].width / 2,
                            [self contentSize].height + [bobber contentSize].height / 2 + 15)];
    [bobber runAction:[RepeatForever actionWithAction:[Sequence actions:
                                                       [EaseSineInOut actionWithAction:[MoveBy actionWithDuration:0.7f position:ccp(0, 15)]],
                                                       [EaseSineInOut actionWithAction:[MoveBy actionWithDuration:0.7f position:ccp(0, -15)]],
                                                       nil]]];
    [bobber setVisible:NO];
    [self addChild:bobber];
    [self setScale:[[GorillasConfig get] cityScale]];

    // By default, a gorilla has 1 life, unless features say otherwise.
    initialLives = 1;
    if(self.human && [[GorillasAppDelegate get].gameLayer isEnabled:GorillasFeatureLivesPl])
        // Human gorillas with lives enabled.
        initialLives = [[GorillasConfig get] lives];
    else if(!self.human) {
        if ([[GorillasAppDelegate get].gameLayer isEnabled:GorillasFeatureLivesAi])
            // AI gorillas with lives enabled.
            initialLives = [[GorillasConfig get] lives];
        else if([[GorillasAppDelegate get].gameLayer isEnabled:GorillasFeatureLivesPl])
            // AI gorillas without lives enabled get infinite lives when humans have lives enabled.
            initialLives = -1;
    }
    lives = initialLives;
    
    healthColors    = malloc(sizeof(ccColor4B) * 4);
    healthColors[0] = healthColors[1] = ccc(0xFF33CC33);
    healthColors[2] = healthColors[3] = ccc(0xFF3333CC);
    
    return self;
}


-(void)setModel:(GorillasPlayerModel)_model {
    
    model = _model;
    [self setTexture:[[TextureMgr sharedTextureMgr] addImage:[self modelFileWithArmsUpLeft:NO right:NO]]];
}


-(BOOL) alive {
    
    // More than (or less than!) zero means gorilla is alive.
    return lives != 0;
}


-(BOOL) human {
    
    return type == GorillasPlayerTypeHuman;
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
                                        times:8],
                     [CallFunc actionWithTarget:self selector:@selector(uu)],
                     [DelayTime actionWithDuration:0.5f],
                     [CallFunc actionWithTarget:self selector:@selector(dd)],
                     nil]];
}


-(void) threw:(CGPoint)aim {

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
    
    [self setTexture:[[TextureMgr sharedTextureMgr] addImage:[self modelFileWithArmsUpLeft:NO right:NO]]];
}


-(void) ud {
    
    [self setTexture:[[TextureMgr sharedTextureMgr] addImage:[self modelFileWithArmsUpLeft:YES right:NO]]];
}


-(void) du {
    
    [self setTexture:[[TextureMgr sharedTextureMgr] addImage:[self modelFileWithArmsUpLeft:NO right:YES]]];
}


-(void) uu {
    
    [self setTexture:[[TextureMgr sharedTextureMgr] addImage:[self modelFileWithArmsUpLeft:YES right:YES]]];
}


-(NSString *) modelFileWithArmsUpLeft:(BOOL)left right:(BOOL)right {
    
    NSString *modelName, *typeName;
    switch (model) {
        case GorillasPlayerModelGorilla:
            modelName = @"gorilla";
            break;
        case GorillasPlayerModelEasterBunny:
            modelName = @"bunny";
            break;
        case GorillasPlayerModelBanana:
            modelName = @"banana";
            break;
        default:
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:@"Active gorilla model not implemented." userInfo:nil];
    }
    switch (type) {
        case GorillasPlayerTypeAI:
            typeName = @"ai";
            break;
        case GorillasPlayerTypeHuman:
            typeName = @"human";
            break;
        default:
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:@"Active gorilla type not implemented." userInfo:nil];
    }
    
    return [NSString stringWithFormat:@"%@-%@-%c%c.png", modelName, typeName, left? 'U': 'D', right? 'U': 'D'];
}


-(GorillasProjectileModel) projectileModel {

    switch (model) {
        case GorillasPlayerModelGorilla:
            return GorillasProjectileModelBanana;

        case GorillasPlayerModelEasterBunny:
            return GorillasProjectileModelEasterEgg;

        case GorillasPlayerModelBanana:
            return GorillasProjectileModelGorilla;
            
        default:
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:@"Active gorilla model not implemented." userInfo:nil];
    }
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
    
    if (!active && _active)
        [self applyZoom];
    
    active = _active;
    
    [bobber setVisible:active];
    [[GorillasAppDelegate get].hudLayer updateHudWithScore:0 skill:0];
}


- (void) applyZoom {

    [[GorillasAppDelegate get].gameLayer.panningLayer scaleTo:self.zoom limited:YES];
}


-(BOOL) hitsGorilla: (CGPoint)pos {
    
    if(![self alive])
        return NO;
    
    return  pos.x >= self.position.x - self.contentSize.width  / 2 &&
            pos.y >= self.position.y - self.contentSize.height / 2 &&
            pos.x <= self.position.x + self.contentSize.width  / 2 &&
            pos.y <= self.position.y + self.contentSize.height / 2;
}


-(CGSize) contentSize {
    
    return CGSizeMake([super contentSize].width * [self scale], [super contentSize].height * [self scale]);
}


-(void) draw {

    [super draw];
    
    if(lives <= 0)
        return;
    
    if(self.human && ![[GorillasAppDelegate get].gameLayer isEnabled:GorillasFeatureLivesPl])
       return;

    if(!self.human && ![[GorillasAppDelegate get].gameLayer isEnabled:GorillasFeatureLivesAi])
       return;
    
    CGFloat barX = self.contentSize.width / self.scale / 2;
    CGFloat barY = self.contentSize.height / self.scale + 10;
    CGFloat barW = 40;
    CGPoint lines[4] = {
        ccp(barX - barW / 2, barY),
        ccp(barX - barW / 2 + barW * lives / initialLives, barY),
        ccp(barX - barW / 2 + barW * lives / initialLives, barY),
        ccp(barX - barW / 2 + barW, barY),
    };
    
    GLubyte o = active? 0xFF: 0x33;
    
    if ([GorillasConfig get].visualFx) {
        DrawBoxFrom(ccpAdd(lines[0], ccp(0, -3)), ccpAdd(lines[1], ccp(0, 3)), ccc(0xCCFFCC00 | o), ccc(0x33CC3300 | o));
        DrawBoxFrom(ccpAdd(lines[2], ccp(0, -3)), ccpAdd(lines[3], ccp(0, 3)), ccc(0xFFCCCC00 | o), ccc(0xCC333300 | o));
    }
    else
        DrawLines(lines, healthColors, 4, 6);
    
    DrawBorderFrom(ccpAdd(lines[0], ccp(0, -3)), ccpAdd(lines[3], ccp(0, 3)), ccc(0xCCCC3300 | (o - 0x33)), 1);
}


-(void) dealloc {
    
    [name release];
    name = nil;
    
    free(healthColors);
    healthColors = nil;
    
    [super dealloc];
}


@end
