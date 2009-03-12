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


@implementation SkiesLayer


-(id) init {
    
    if (!(self = [super init]))
		return self;
    
    float x = 0;
    
    skyColor = [[GorillasConfig get] skyColor];
    fancySky = [[GorillasConfig get] visualFx];
    
    skies = [[NSMutableArray alloc] init];
    for (int i = 0; i < 2; ++i) {
        
        const SkyLayer *sky =  [SkyLayer node];
        [skies addObject: sky];
        
        [sky setPosition: cpv(x, 0)];
        [self addChild: sky z:1];

        x += [sky contentSize].width;
    }
    
    [self runAction:[PanAction actionWithSubNodes:skies duration:[[GorillasConfig get] starSpeed] padding:0]];
    
    return self;
}


-(void) reset {

    skyColor = [[GorillasConfig get] skyColor];
    fancySky = [[GorillasConfig get] visualFx];
    
    for(SkyLayer *sky in skies)
        [sky reset];
}


-(void) draw {
    
    CGSize winSize = [[Director sharedDirector] winSize];
    cpVect from = cpv(-position.x - winSize.width, 0);
    
    if(fancySky)
        drawBoxFrom(from, cpv(from.x + winSize.width * 3, winSize.height * 1.5f), skyColor, 0x000000ff);
    
    else {
        GLubyte *colorBytes = (GLubyte *) &skyColor;
        glClearColor(colorBytes[3] / (float)0xff, colorBytes[2] / (float)0xff, colorBytes[1] / (float)0xff, colorBytes[0] / (float)0xff);
        glClear(GL_COLOR_BUFFER_BIT);
    }
}


-(void) dealloc {
    
    [skies release];
    skies = nil;
    
    [super dealloc];
}


@end
