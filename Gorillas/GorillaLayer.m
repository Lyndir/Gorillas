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
#import "PearlCCRemove.h"


@interface GorillaLayer ()

@property (nonatomic, readwrite, copy) NSString                 *name;
@property (nonatomic, readwrite, assign) NSUInteger             teamIndex;
@property (nonatomic, readwrite, assign) NSUInteger             globalIndex;

@property (nonatomic, readwrite, retain) CCSprite               *bobber;

@property (nonatomic, readwrite, copy) NSString                 *playerID;
@property (nonatomic, readwrite, assign) int                    initialLives;
@property (nonatomic, readwrite, assign) int                    lives;

-(void) dd;
-(void) ud;
-(void) du;
-(void) uu;

-(NSString *) modelFileWithArmsUpLeft:(BOOL)left right:(BOOL)right;

@end

static NSUInteger nextTeamIndex, nextGlobalIndex;

@implementation GorillaLayer

@synthesize name = _name, teamIndex = _teamIndex, globalIndex = _globalIndex;
@synthesize playerID = _playerID, player = _player, connectionState = _connectionState;
@synthesize initialLives = _initialLives, lives = _lives, active = _active, ready = _ready, turns = _turns, zoom = _zoom;
@synthesize bobber = _bobber, model = _model, type = _type;


+(void) prepareCreation {
    
    nextTeamIndex      = 0;
    nextGlobalIndex    = 0;
}


+ (GorillaLayer *)gorillaWithType:(GorillasPlayerType)aType playerID:(NSString *)aPlayerId {
    
    return [[[self alloc] initWithType:aType playerID:aPlayerId] autorelease];
}

- (id)initWithType:(GorillasPlayerType)aType playerID:(NSString *)aPlayerId {
    
    if(!(self = [super init]))
        return self;
    
    self.model              = [[GorillasConfig get].playerModel unsignedIntValue];
    self.type               = aType;
    self.teamIndex          = nextTeamIndex++;
    self.globalIndex        = nextGlobalIndex++;
    self.zoom               = 1;
    self.texture            = [[CCTextureCache sharedTextureCache] addImage:[self modelFileWithArmsUpLeft:NO right:NO]];
    self.textureRect        = CGRectFromOriginWithSize(CGPointZero, self.texture.contentSize);
    self.bobber             = [CCSprite spriteWithFile:@"bobber.png"];
    self.bobber.visible     = NO;
    self.bobber.position = ccp(0, self.contentSize.height);
    [self.bobber runAction:[CCRepeatForever actionWithAction:[CCSequence actions:
                                                              [CCEaseSineInOut actionWithAction:
                                                               [CCMoveBy actionWithDuration:0.7f position:ccp(0, 15)]],
                                                              [CCEaseSineInOut actionWithAction:
                                                               [CCMoveBy actionWithDuration:0.7f position:ccp(0, -15)]],
                                                              nil]]];
    [self addChild:self.bobber];
    
    self.playerID           = aPlayerId;
    self.connectionState    = self.playerID ? GKPlayerStateConnected: GKPlayerStateUnknown;
    self.name = PearlLocalize(@"names.n", self.globalIndex + 1);
    if (!self.playerID)
        self.connectionState = GKPlayerStateConnected;
    else
        if ([self.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
            self.player = [GKLocalPlayer localPlayer];
            self.connectionState = GKPlayerStateConnected;
        }
    
    // By default, a gorilla has 1 life, unless features say otherwise.
    self.initialLives = 1;
    if(self.human && [[GorillasAppDelegate get].gameLayer isEnabled:GorillasFeatureLivesPl])
        // Human gorillas with lives enabled.
        self.initialLives = [[GorillasConfig get].lives intValue];
    else if(!self.human) {
        if ([[GorillasAppDelegate get].gameLayer isEnabled:GorillasFeatureLivesAi])
            // AI gorillas with lives enabled.
            self.initialLives = [[GorillasConfig get].lives intValue];
        else if([[GorillasAppDelegate get].gameLayer isEnabled:GorillasFeatureLivesPl])
            // AI gorillas without lives enabled get infinite lives when humans have lives enabled.
            self.initialLives = -1;
    }
    
    _healthColors    = calloc(4, sizeof(ccColor4B));
    _healthColors[0] = _healthColors[1] = ccc4l(0xFF33CC33L);
    _healthColors[2] = _healthColors[3] = ccc4l(0xFF3333CCL);
    
    return self;
}


- (void)reset {
    
    [self stopAllActions];
    
    self.bobber.position = ccp(self.contentSize.width / 2, self.contentSize.height + self.bobber.contentSize.height / 2);
    self.scale      = GorillasModelScale(2, self.bobber.texture.contentSize.width);
    self.active     = NO;
    self.ready      = NO;
    self.lives      = self.initialLives;
    self.opacity    = 0xff;
    
    [self dd];
}


-(void)setModel:(GorillasPlayerModel)aModel {
    
    _model = aModel;
    [self setTexture:[[CCTextureCache sharedTextureCache] addImage:[self modelFileWithArmsUpLeft:NO right:NO]]];
}


- (NSString *)name {
    
    if (self.player)
        return self.player.alias;
    
    return _name;
}


-(BOOL) alive {
    
    // More than (or less than!) zero means gorilla is alive.
    return self.lives != 0;
}


-(BOOL) human {
    
    return self.type == GorillasPlayerTypeHuman;
}


-(BOOL) local {
    
    return !self.playerID || [self.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID];
}


-(void) danceHit {
    
    [self runAction:[CCSequence actions:
                     [CCCallFunc actionWithTarget:self selector:@selector(dd)],
                     [CCDelayTime actionWithDuration:0.2f],
                     [CCCallFunc actionWithTarget:self selector:@selector(uu)],
                     [CCDelayTime actionWithDuration:0.4f],
                     [CCCallFunc actionWithTarget:self selector:@selector(dd)],
                     [CCDelayTime actionWithDuration:0.2f],
                     [CCCallFunc actionWithTarget:self selector:@selector(uu)],
                     [CCDelayTime actionWithDuration:1],
                     [CCCallFunc actionWithTarget:self selector:@selector(dd)],
                     nil]];
}


-(void) danceKill {
    
    [self runAction:[CCSequence actions:
                     [CCCallFunc actionWithTarget:self selector:@selector(dd)],
                     [CCDelayTime actionWithDuration:0.2f],
                     [CCRepeat actionWithAction:[CCSequence actions:
                                                 [CCCallFunc actionWithTarget:self selector:@selector(ud)],
                                                 [CCDelayTime actionWithDuration:0.2f],
                                                 [CCCallFunc actionWithTarget:self selector:@selector(du)],
                                                 [CCDelayTime actionWithDuration:0.4f],
                                                 nil]
                                          times:6],
                     [CCCallFunc actionWithTarget:self selector:@selector(uu)],
                     [CCDelayTime actionWithDuration:0.5f],
                     [CCCallFunc actionWithTarget:self selector:@selector(dd)],
                     nil]];
}


-(void) danceVictory {
    
    [self runAction:[CCSequence actions:
                     [CCCallFunc actionWithTarget:self selector:@selector(dd)],
                     [CCDelayTime actionWithDuration:0.2f],
                     [CCRepeat actionWithAction:[CCSequence actions:
                                                 [CCCallFunc actionWithTarget:self selector:@selector(du)],
                                                 [CCDelayTime actionWithDuration:0.6f],
                                                 [CCCallFunc actionWithTarget:self selector:@selector(dd)],
                                                 [CCDelayTime actionWithDuration:0.2f],
                                                 nil]
                                          times:2],
                     [CCCallFunc actionWithTarget:self selector:@selector(uu)],
                     [CCDelayTime actionWithDuration:0.4f],
                     [CCRepeat actionWithAction:[CCSequence actions:
                                                 [CCCallFunc actionWithTarget:self selector:@selector(ud)],
                                                 [CCDelayTime actionWithDuration:0.2f],
                                                 [CCCallFunc actionWithTarget:self selector:@selector(du)],
                                                 [CCDelayTime actionWithDuration:0.2f],
                                                 nil]
                                          times:4],
                     [CCRepeat actionWithAction:[CCSequence actions:
                                                 [CCCallFunc actionWithTarget:self selector:@selector(uu)],
                                                 [CCDelayTime actionWithDuration:0.5f],
                                                 [CCCallFunc actionWithTarget:self selector:@selector(dd)],
                                                 [CCDelayTime actionWithDuration:0.2f],
                                                 nil]
                                          times:2],
                     nil]];
}


-(void) threw:(CGPoint)v {
    
    if(v.x > 0)
        [self ud];
    else
        [self du];
    
    [self runAction:[CCSequence actions:
                     [CCDelayTime actionWithDuration:0.5f],
                     [CCCallFunc actionWithTarget:self selector:@selector(dd)],
                     nil]];
}


-(void) dd {
    
    [self setTexture:[[CCTextureCache sharedTextureCache] addImage:[self modelFileWithArmsUpLeft:NO right:NO]]];
}


-(void) ud {
    
    [self setTexture:[[CCTextureCache sharedTextureCache] addImage:[self modelFileWithArmsUpLeft:YES right:NO]]];
}


-(void) du {
    
    [self setTexture:[[CCTextureCache sharedTextureCache] addImage:[self modelFileWithArmsUpLeft:NO right:YES]]];
}


-(void) uu {
    
    [self setTexture:[[CCTextureCache sharedTextureCache] addImage:[self modelFileWithArmsUpLeft:YES right:YES]]];
}


-(NSString *) modelFileWithArmsUpLeft:(BOOL)left right:(BOOL)right {
    
    NSString *modelName, *typeName;
    switch (self.model) {
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
            err(@"Active gorilla model not implemented.");
            return nil;
    }
    switch (self.type) {
        case GorillasPlayerTypeAI:
            typeName = @"ai";
            break;
        case GorillasPlayerTypeHuman:
            typeName = @"human";
            break;
        default:
            err(@"Active gorilla type not implemented.");
            return nil;
    }
    
    return [NSString stringWithFormat:@"%@-%@-%c%c.png", modelName, typeName, left? 'U': 'D', right? 'U': 'D'];
}


-(GorillasProjectileModel) projectileModel {
    
    switch (self.model) {
        case GorillasPlayerModelGorilla:
            return GorillasProjectileModelBanana;
            
        case GorillasPlayerModelEasterBunny:
            return GorillasProjectileModelEasterEgg;
            
        case GorillasPlayerModelBanana:
            return GorillasProjectileModelGorilla;
            
        default:
            err(@"Active gorilla model not implemented.");
            return GorillasProjectileModelGorilla;
    }
}


-(void) kill {
    
    if(self.lives > 0)
        --self.lives;
    
    if(self.lives == 0) {
        [self stopAllActions];
        [self runAction:[CCSequence actions:
                         [CCFadeTo actionWithDuration:0.5f opacity:0x00],
                         [PearlCCRemove action],
                         nil]];
    } else
        [self runAction:[CCSequence actions:
                         [ShadeTo actionWithDuration:0.5f color:ccc4l(0xFF0000FF)],
                         [ShadeTo actionWithDuration:0.5f color:ccc4l(0xFFFFFFFF)],
                         nil]];
}


-(void) killDead {
    
    self.lives = 1;
    
    [self kill];
}


-(void) revive {
    
    self.lives = 1;
    
    [self stopAllActions];
    [self runAction:[CCFadeTo actionWithDuration:0.5f opacity:0xFF]];
}


-(void) setActive:(BOOL)isActive {
    
    if (!_active && isActive)
        [self applyZoom];
    
    _active = isActive;
    
    [self.bobber setVisible:self.active];
}

- (void)setConnectionState:(GKPlayerConnectionState)aConnectionState {
    
    _connectionState = aConnectionState;
    
    switch (_connectionState) {
        case GKPlayerStateUnknown: {
            self.bobber.color       = ccc3l(0xFFFFFF);
            break;
        }
        case GKPlayerStateConnected: {
            if ([self local])
                self.bobber.color       = ccc3l(0x00FF00);
            else
                self.bobber.color       = ccc3l(0xFFFF00);
            
            break;
        }
        case GKPlayerStateDisconnected: {
            self.bobber.color = ccc3l(0xFF0000);
            break;
        }
    }
}


- (void) applyZoom {
    
    [[GorillasAppDelegate get].gameLayer.panningLayer scaleTo:self.zoom];
}


-(BOOL) hitsGorilla: (CGPoint)pos {
    
    if(![self alive])
        return NO;
    
    return ABS(pos.x - self.position.x) <= self.contentSize.width / 4 && ABS(pos.y - self.position.y) <= self.contentSize.height / 4;
}


-(void) draw {

    [super draw];

    if(self.lives <= 0)
        return;
    
    if(self.human && ![[GorillasAppDelegate get].gameLayer isEnabled:GorillasFeatureLivesPl])
        return;
    
    if(!self.human && ![[GorillasAppDelegate get].gameLayer isEnabled:GorillasFeatureLivesAi])
        return;
    
    CC_PROFILER_START_CATEGORY(kCCProfilerCategorySprite, @"GorillaLayer - draw");
       CC_NODE_DRAW_SETUP();
    [[[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionColor] use];
       [[[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionColor] setUniformsForBuiltins];
    
    CGSize size = self.contentSize; //CC_SIZE_POINTS_TO_PIXELS(self.contentSize);
    
    const CGFloat barX = size.width     * -0.2f;
    const CGFloat barY = size.height    * 1.2f;
    const CGFloat barW = size.width     * 1.4f;
    const CGPoint lines[4] = {
        ccp(barX, barY),
        ccp(barX + barW * self.lives / self.initialLives, barY),
        ccp(barX + barW * self.lives / self.initialLives, barY),
        ccp(barX + barW, barY),
    };
    const GLubyte o = self.active? 0xFF: 0x66;
    
        CGPoint from = ccpAdd(lines[0], ccp(0, size.height * -0.1f));
        CGPoint to = ccpAdd(lines[1], ccp(0, size.height * 0.1f));
        Vertex remainingHealthVertices[4] = {
            { .p = { from.x, from.y }, .c = ccc4l(0xCCFFCC00 | o) },
            { .p = { to.x, from.y }, .c = ccc4l(0xCCFFCC00 | o) },
            { .p = { from.x, to.y }, .c = ccc4l(0x33CC3300 | o) },
            { .p = { to.x, to.y }, .c = ccc4l(0x33CC3300 | o) },
        };
        PearlGLDraw(GL_TRIANGLE_STRIP, remainingHealthVertices, 4);

        from = ccpAdd(lines[2], ccp(0, size.height * -0.1f));
        to = ccpAdd(lines[3], ccp(0, size.height * 0.1f));
        Vertex depletedHealthVertices[4] = {
            { .p = { from.x, from.y }, .c = ccc4l(0xFFCCCC00 | o) },
            { .p = { to.x, from.y }, .c = ccc4l(0xFFCCCC00 | o) },
            { .p = { from.x, to.y }, .c = ccc4l(0xCC333300 | o) },
            { .p = { to.x, to.y }, .c = ccc4l(0xCC333300 | o) },
        };
        PearlGLDraw(GL_TRIANGLE_STRIP, depletedHealthVertices, 4);
    
    PearlGLDrawBorderFrom(ccpAdd(lines[0], ccp(0, size.height * -0.1f)),
                   ccpAdd(lines[3], ccp(0, size.height * 0.1f)),
                   ccc4l(0xCCCC3300 | (o - 0x33)));

    CHECK_GL_ERROR_DEBUG();
    CC_INCREMENT_GL_DRAWS(1);
       CC_PROFILER_STOP_CATEGORY(kCCProfilerCategorySprite, @"GorillaLayer - draw");
}


-(void) dealloc {
    
    self.name       = nil;
    self.playerID   = nil;
    self.bobber     = nil;
    
    free(_healthColors);
    _healthColors = nil;
    
    [super dealloc];
}


@end
