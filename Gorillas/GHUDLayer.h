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
//  GHUDLayer.h
//  Gorillas
//
//  Created by Maarten Billemont on 10/11/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "PearlCCHUDLayer.h"

@interface GHUDLayer : PearlCCHUDLayer

@property(nonatomic, readonly, strong) CCLabelAtlas *skillSprite;
@property(nonatomic, readonly, strong) CCLabelAtlas *skillCount;
@property(nonatomic, readonly, strong) CCLayer *livesLayer;
@property(nonatomic, readonly, strong) CCSprite *infiniteLives;
@property(nonatomic, readwrite, assign) float throwSkill;

@end
