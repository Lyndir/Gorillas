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
//  SkyLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 26/10/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "SkyLayer.h"
#import "StarLayer.h"
#import "PanAction.h"
#import "GorillasAppDelegate.h"


@implementation SkyLayer


-(id) init {
    
    if (!(self = [super init]))
		return self;
    
    stars = [[NSMutableArray alloc] init];
    
    for (NSUInteger j = 0; j < 3; ++j) {
        float depth = j / 9.0f + 0.3f;
        
        StarLayer *starLayer =  [[StarLayer alloc] initWidthDepth:j / 4.0f + 0.5f];
        [stars addObject: starLayer];

        [self addChild:starLayer z:1 parallaxRatio:ccp(depth, depth) positionOffset:ccp(self.contentSize.width / 2,
                                                                                        self.contentSize.height / 2)];
        
        [starLayer release];
    }
    
    return self;
}


- (void)onEnter {
    
    [self reset];
    
    [super onEnter];
}


-(void) reset {

    skyColor = ccc4l([[GorillasConfig get].skyColor longValue]);
    fancySky = [[GorillasConfig get].visualFx boolValue];

    CGRect field = [[GorillasAppDelegate get].gameLayer.cityLayer fieldInSpaceOf:self];
    from    = ccp(field.origin.x, field.origin.y);
    to      = ccp(field.origin.x + field.size.width, field.origin.y + field.size.height);
    
    for(StarLayer *starLayer in stars)
        [starLayer reset];
}


-(void) draw {
    
    if(fancySky)
        DrawBoxFrom(from, to, skyColor, ccc4l(0x000000ff));
    
    else {
        glClearColor(skyColor.r / (float)0xff, skyColor.g / (float)0xff, skyColor.b / (float)0xff, skyColor.a / (float)0xff);
        glClear(GL_COLOR_BUFFER_BIT);
    }
}


-(void) dealloc {
    
    [stars release];
    stars = nil;
    
    [super dealloc];
}


@end
