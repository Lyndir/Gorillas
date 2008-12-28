/*
 * This file is part of Gorillas.
 *
 *  Gorillas is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
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
//  WindLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 25/10/08.
//  Copyright 2008, lhunath (Maarten Billemont). All rights reserved.
//

#import "WindLayer.h"
#import "Utility.h"
#import "GorillasConfig.h"


@implementation WindLayer

@synthesize color, wind;


- (id) init {
    
	if (!(self = [super init]))
        return self;
    
    [self reset];
    
	return self;
}


-(void) reset {

    wind = (random() % 100) / 100.0f - 0.5f;
}


-(void) draw {

    float windRange = (5 * [[GorillasConfig get] windModifier]);
    CGSize winSize = [[Director sharedDirector] winSize].size;
    
    const cpVect by[] = {
        cpv(windRange * wind,           0     ),
        cpv((wind < 0? 1: -1) * 3,      +3    ),
        cpv(0,                          -3 * 2),
        cpv((wind < 0? -1: 1) * 3,      +3    ),
    };
    [Utility drawLinesFrom:cpv(winSize.width / 2, winSize.height - [[GorillasConfig get] smallFontSize])
                        by:by
                     count:4
                     color:color
                     width:1];
}


-(GLubyte) opacity {
    
    const GLubyte *colorBytes = (GLubyte *)&color;
    return colorBytes[0];
}


-(void) setOpacity:(GLubyte)opacity {
    
    color = (color & 0xffffff00) | opacity;
}


@end
