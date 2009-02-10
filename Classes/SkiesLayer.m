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
//  SkiesLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 26/10/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "SkiesLayer.h"
#import "SkyLayer.h"
#import "PanAction.h"
#import "Utility.h"


@implementation SkiesLayer


-(id) init {
    
    if (!(self = [super init]))
		return self;
    
    const float w = [[Director sharedDirector] winSize].width;
    
    skies = [[NSMutableArray alloc] init];
    for (int i = 0; i < 3; ++i) {
        const float x = i * w - w;
        
        const SkyLayer *sky =  [SkyLayer node];
        [skies addObject: sky];
        
        [sky setPosition: cpv(x, 0)];
        [self add: sky z:1];
    }
    
    [self do: [PanAction actionWithSubNodes:skies duration: [[GorillasConfig get] starSpeed] padding:0]];
    
    return self;
}


-(void) reset {

    for(SkyLayer *sky in skies)
        [sky reset];
}


-(void) draw {
    
    const long color = [[GorillasConfig get] skyColor];
    const GLubyte *colorBytes = (GLubyte *)&color;
    const long toColor = ((int) (colorBytes[3] * 0.3f) << 24) |
                         ((int) (colorBytes[2] * 0.3f) << 16) |
                         ((int) (colorBytes[1] * 0.3f) << 8) |
                         colorBytes[0];
    
    CGSize winSize = [[Director sharedDirector] winSize];
    drawBoxFrom(cpv(-position.x, -position.y), cpv(winSize.width - position.x, winSize.height - position.y), color, toColor);
    /*glClearColor(colorBytes[3] / (float)0xff, colorBytes[2] / (float)0xff, colorBytes[1] / (float)0xff, colorBytes[0] / (float)0xff);
    glClear(GL_COLOR_BUFFER_BIT);*/
}


-(void) dealloc {
    
    [skies release];
    skies = nil;
    
    [super dealloc];
}


@end
