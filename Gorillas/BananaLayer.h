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
//  BananaLayer.h
//  Gorillas
//
//  Created by Maarten Billemont on 08/11/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "ThrowAction.h"
#import "GorillaLayer.h"

@interface BananaLayer : CCLayer

@property(nonatomic, assign) BOOL clearedGorilla;
@property(nonatomic, assign) GorillasProjectileModel model;
@property(nonatomic, assign) GorillasPlayerType type;
@property(nonatomic, strong) CCSprite *banana;

- (CCSprite *)bananaForThrowFrom:(GorillaLayer *)gorilla;
- (BOOL)throwing;

- (void)setModel:(GorillasProjectileModel)aModel type:(GorillasPlayerType)aType;

@end
