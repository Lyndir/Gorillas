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
#import "PearlGLUtils.h"


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

    self.shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionColor];

    return self;
}


- (void)onEnter {

    [self reset];

    [super onEnter];
}


-(void) reset {

    skyColor = ccc4l([[GorillasConfig get].skyColor unsignedLongValue]);

    self.contentSize = [CCDirector sharedDirector].winSize;
    for(StarLayer *starLayer in stars)
        [starLayer reset];
}


-(void) draw {

    [super draw];

    CC_PROFILER_START_CATEGORY(kCCProfilerCategorySprite, @"SkyLayer - draw");
    CC_NODE_DRAW_SETUP();

    Vertex vertices[4] = {
            { .p = { 0,                         0 },                        .c = skyColor },
            { .p = { self.contentSize.width,    0 },                        .c = skyColor },
            { .p = { 0,                         self.contentSize.height },  .c = ccc4(0x00, 0x00, 0x00, 0xff) },
            { .p = { self.contentSize.width,    self.contentSize.height },  .c = ccc4(0x00, 0x00, 0x00, 0xff) },
    };
    PearlGLDraw(GL_TRIANGLE_STRIP, vertices, 4);

    CHECK_GL_ERROR_DEBUG();
    CC_INCREMENT_GL_DRAWS(1);
    CC_PROFILER_STOP_CATEGORY(kCCProfilerCategorySprite, @"SkyLayer - draw");
}


-(void) dealloc {

    [stars release];
    stars = nil;

    [super dealloc];
}


@end
