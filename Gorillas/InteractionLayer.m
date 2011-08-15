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
//  CityLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 26/10/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "InteractionLayer.h"
#import "GorillasAppDelegate.h"


@interface InteractionLayer (Private)

- (void)addInfo:(ccTime)dt;
- (void)zoomOut;
- (void)showAim;
- (void)endGameCallback;

@end


@implementation InteractionLayer

@synthesize aim;


-(id) init {
    
    if (!(self = [super init]))
		return self;
    
    self.isTouchEnabled = YES;
    
    self.aim        = CGPointZero;
    
    aimSprite       = [[BarSprite alloc] initWithHead:@"aim.head.png" body:@"aim.body.%d.png" withFrames:16 tail:@"aim.tail.png" animatedTargetting:YES];
    aimSprite.textureSize = CGSizeMake(aimSprite.textureSize.width / 2, aimSprite.textureSize.height / 2);
    [self addChild:aimSprite z:2];
    
    angleLabel      = [[CCLabelTTF alloc] initWithString:@"0" dimensions:CGSizeMake(100, 100) alignment:UITextAlignmentLeft
                                                fontName:[GorillasConfig get].fixedFontName fontSize:[[GorillasConfig get].smallFontSize intValue]];
    strengthLabel   = [[CCLabelTTF alloc] initWithString:@"0" dimensions:CGSizeMake(100, 100) alignment:UITextAlignmentLeft
                                                fontName:[GorillasConfig get].fixedFontName fontSize:[[GorillasConfig get].smallFontSize intValue]];
    infoLabel       = [[CCLabelTTF alloc] initWithString:@"∡\n⊿" dimensions:CGSizeMake(100, 100) alignment:UITextAlignmentLeft
                                                fontName:[GorillasConfig get].symbolicFontName fontSize:[[GorillasConfig get].smallFontSize intValue]];
    [infoLabel addChild:angleLabel];
    [infoLabel addChild:strengthLabel];
    
    CGSize winSize  = [CCDirector sharedDirector].winSize;
    angleLabel.position     = ccp(45, 72);
    strengthLabel.position  = ccp(45, 52);
    angleLabel.scale        = 0.5f;
    strengthLabel.scale     = 0.5f;
    infoLabel.position      = ccp(5 + infoLabel.contentSize.width / 2,
                                  winSize.height - infoLabel.contentSize.height / 2 - 5);
    infoLabel.visible = NO;
    [self schedule:@selector(addInfo:)];
    
    return self;
}


-(void) addInfo:(ccTime)dt {
    
    if (!infoLabel.parent)
        [[GorillasAppDelegate get].uiLayer addChild:infoLabel z:9];
    [self unschedule:@selector(addInfo:)];
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    if([[event allTouches] count] != 1)
        // Ignore: multiple fingers on the screen.
        return;
    
    if(![self mayThrow])
        // State doesn't allow throwing right now.
        return;
    
    CGPoint p = [self convertTouchToNodeSpace:[[event allTouches] anyObject]];
    
    if([[[GorillasAppDelegate get] hudLayer] hitsHud:p])
        // Ignore when moving/clicking over/on HUD.
        return;
    
    if(!CGPointEqualToPoint(aim, CGPointZero))
        // Has already began.
        return;
    
    self.aim = ccpSub(p, self.position);
    
    return;
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {

    if([[event allTouches] count] != 1) {
        // Cancel when: multiple fingers hit the screen.
        self.aim = CGPointZero;
        return;
    }
    
    if(![self mayThrow])
        // State doesn't allow throwing right now.
        return;

    CGPoint p = [self convertTouchToNodeSpace:[[event allTouches] anyObject]];
    if([[[GorillasAppDelegate get] hudLayer] hitsHud:p]) {
        // Ignore when moving/clicking over/on HUD.
        return;
    }
    
    CGPoint wp = [[GorillasAppDelegate get].gameLayer convertTouchToNodeSpace:[[event allTouches] anyObject]];
    if (fabsf(wp.y - [CCDirector sharedDirector].winSize.height) < 20)
        [self performSelector:@selector(zoomOut) withObject:nil afterDelay:3];
    else
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(zoomOut) object:nil];
    
    self.aim = ccpSub(p, [self position]);
}

- (void)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(zoomOut) object:nil];
    
    self.aim = CGPointZero;
}


- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(zoomOut) object:nil];

    if([[event allTouches] count] != 1) {
        // Cancel when: multiple fingers hit the screen.
        self.aim = CGPointZero;
        return;
    }

    CGPoint p = [self convertTouchToNodeSpace:[[event allTouches] anyObject]];

    if([[[GorillasAppDelegate get] hudLayer] hitsHud:p]
       || CGPointEqualToPoint(aim, CGPointZero)
       || ![self mayThrow]) {
        // Cancel when: released over HUD, no aim vector, state doesn't allow throwing.
        self.aim = CGPointZero;
        return;
    }

    GorillaLayer *activeGorilla = [GorillasAppDelegate get].gameLayer.activeGorilla;
    CGSize winSize = [CCDirector sharedDirector].winSize;
    CGPoint r0 = activeGorilla.position;
    CGPoint v = ccpSub(aim, r0); // Velocity = Vector from origin to aim point.
    v = ccp(v.x / winSize.width, v.y / winSize.height); // Normalize velocity so it's resolution-independant.
    self.aim = CGPointZero;

    // Notify the network controller.
    [[GorillasAppDelegate get].netController sendThrowWithNormalizedVelocity:v];

    [[ThrowController get] throwFrom:activeGorilla normalizedVelocity:v];
}


- (void)setAim:(CGPoint)anAim {
    
    aim = aimSprite.target  = anAim;
    
    if (CGPointEqualToPoint(aim, CGPointZero)) {
        infoLabel.visible   = NO;
        return;
    }
    
    CGPoint gorillaPosition = aimSprite.position = [self convertToNodeSpace:
                                                    [[GorillasAppDelegate get].gameLayer.cityLayer.buildingLayer convertToWorldSpace:
                                                     [GorillasAppDelegate get].gameLayer.activeGorilla.position]];
    CGPoint relAim = ccpSub(aim, gorillaPosition);
    CGPoint worldAim = [self convertToWorldSpace:relAim];
    
    [angleLabel setString:[NSString stringWithFormat:@"%0.0f", CC_RADIANS_TO_DEGREES(ccpToAngle(worldAim))]];
    [strengthLabel setString:[NSString stringWithFormat:@"%0.0f", ccpLength(worldAim)]];
    infoLabel.visible = YES;
}


-(void) zoomOut {
    
    PanningLayer *panningLayer = [GorillasAppDelegate get].gameLayer.panningLayer;
    [panningLayer scaleTo:panningLayer.scale * 0.9f];
}


-(BOOL) mayThrow {
    
    dbg(@"mayThrow? !throwing(%d) && active(%d) && alive(%d) && human(%d) && local(%d) && !paused(%d)",
        [[GorillasAppDelegate get].gameLayer.cityLayer.bananaLayer throwing], [[GorillasAppDelegate get].gameLayer.activeGorilla active], [[GorillasAppDelegate get].gameLayer.activeGorilla alive], [[GorillasAppDelegate get].gameLayer.activeGorilla human], [[GorillasAppDelegate get].gameLayer.activeGorilla local], [GorillasAppDelegate get].gameLayer.paused);
    return ![[GorillasAppDelegate get].gameLayer.cityLayer.bananaLayer throwing] &&
    [[GorillasAppDelegate get].gameLayer.activeGorilla active] &&
    [[GorillasAppDelegate get].gameLayer.activeGorilla alive] &&
    [[GorillasAppDelegate get].gameLayer.activeGorilla human] &&
    [[GorillasAppDelegate get].gameLayer.activeGorilla local] &&
    ![GorillasAppDelegate get].gameLayer.paused;
}

@end
