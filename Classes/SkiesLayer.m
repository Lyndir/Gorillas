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
//  SkiesLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 26/10/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "SkiesLayer.h"
#import "StarLayer.h"
#import "PanAction.h"


@implementation SkiesLayer


-(id) init {
    
    if (!(self = [super init]))
		return self;
    
    skyColor = [[GorillasConfig get] skyColor];
    fancySky = [[GorillasConfig get] visualFx];
    
    skies = [[NSMutableArray alloc] init];
    for (int j = 0; j < 2; ++j) {
        float depth = j / 4.0f + 0.5f;
        
        const StarLayer *sky =  [[StarLayer alloc] initWidthDepth:depth];
        [skies addObject: sky];
        
        [sky setPosition: CGPointZero];
        //float px = 1 + powf(depth, 22);
        [self addChild:sky z:1 /*parallaxRatio:ccp(px, 1) positionOffset:CGPointZero*/];
        
        [sky release];
    }
    
    return self;
}


-(void) reset {

    skyColor = [[GorillasConfig get] skyColor];
    fancySky = [[GorillasConfig get] visualFx];
    
    for(StarLayer *sky in skies)
        [sky reset];
}


-(void) draw {
    
    CGSize winSize = [[Director sharedDirector] winSize];
    CGPoint from = ccp(-self.position.x - winSize.width, 0);
    
    if(fancySky)
        drawBoxFrom(from, ccp(from.x + winSize.width * 3, winSize.height * 1.5f), skyColor, 0x000000ff);
    
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
