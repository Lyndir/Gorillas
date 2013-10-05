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
//  CityLayer.h
//  Gorillas
//
//  Created by Maarten Billemont on 26/10/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "PanAction.h"
#import "GorillaLayer.h"
#import "BananaLayer.h"
#import "PearlResettable.h"
#import "ExplosionsLayer.h"
#import "HolesLayer.h"
#import "PearlCCBarSprite.h"
#import "BuildingsLayer.h"

#define DEBUG_COLLISION 0

@interface CityLayer : CCParallaxNode<PearlResettable>

@property(nonatomic, readonly) BananaLayer *bananaLayer;
@property(nonatomic, readonly) GorillaLayer *hitGorilla;

- (void)beginGame;
- (void)endGame;

- (BOOL)hitsGorilla:(CGPoint)pos;
- (BOOL)hitsBuilding:(CGPoint)pos;
- (void)explodeAt:(CGPoint)point isGorilla:(BOOL)isGorilla;
- (void)throwFrom:(GorillaLayer *)gorilla withVelocity:(CGPoint)v;
- (void)nextGorilla;

- (void)message:(NSString *)msg on:(CCNode *)node;
- (CGPoint)calculateThrowFrom:(CGPoint)r0 to:(CGPoint)rt errorLevel:(CGFloat)l;

- (BuildingsLayer *)buildingsLayer;
- (CGRect)fieldInSpaceOf:(CCNode *)node;

@end
