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
//  BuildingsLayer.h
//  Gorillas
//
//  Created by Maarten Billemont on 25/10/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//


#import "PearlResettable.h"

typedef struct Building {
    CGFloat x;
    CGSize size;
    NSUInteger windowCount;
    ccColor4B frontColor;
    ccColor4B topColor;
    ccColor4B backColor;
} Building;

typedef struct BuildingVertex {
    Vertex front;
    ccColor4B backColor;
} BuildingVertex;

@interface BuildingsLayer : CCLayer<PearlResettable>

@property(nonatomic, readonly) Building *buildings;
@property(nonatomic, readonly) NSUInteger buildingCount;

- (id)initWithWidthRatio:(CGFloat)w heightRatio:(float)h lightRatio:(float)lightRatio;
- (void)reset;

- (BOOL)hitsBuilding:(CGPoint)pos;

@end
