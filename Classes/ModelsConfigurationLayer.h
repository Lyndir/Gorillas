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
//  ModelsConfigurationLayer.h
//  Gorillas
//
//  Created by Maarten Billemont on 31/03/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "ShadeLayer.h"
#import "SwipeLayer.h"
#import "GorillaLayer.h"

@interface ModelsConfigurationLayer : ShadeLayer {

@private
    CCMenuItemFont *modelCurr, *modelNext;
    
    SwipeLayer *swipeLayer;
    
    GorillaLayer *prevModelSprite, *currModelSprite, *nextModelSprite;
    NSMutableArray *modelSprites, *modelTitles;
    NSUInteger model;
}


@end
