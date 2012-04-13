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

#import "StarLayer.h"
#import "GorillasAppDelegate.h"
#import "PearlGLShaders.h"
#define maxStarSize 2


@implementation StarLayer


-(id) initWidthDepth:(float)aDepth {
    
	if (!(self = [super init]))
        return self;
    
    starVertexBuffer    = 0;
    starCount           = -1;
    depth               = aDepth;
    self.shaderProgram  = [PearlGLShaders pointSizeShader];
    
    return self;
}


- (void)onEnter {
    
    [self reset];
    
    [self schedule:@selector(update:)];

    [super onEnter];
}


-(void) reset {
    
    if (starCount == [[GorillasConfig get].starAmount intValue])
        return;

    CGRect fieldPx      = [[GorillasAppDelegate get].gameLayer.cityLayer fieldInSpaceOf:self]; //CC_RECT_POINTS_TO_PIXELS([[GorillasAppDelegate get].gameLayer.cityLayer fieldInSpaceOf:self]);
    starCount           = [[GorillasConfig get].starAmount intValue];
    ccColor4B starColor = ccc4l([[GorillasConfig get].starColor unsignedLongValue]);
    starColor.r         *= depth;
    starColor.g         *= depth;
    starColor.b         *= depth;
    CGFloat starSize    = fmaxf(1.0f, maxStarSize * depth);
    
    free(starVertices);
    starVertices = malloc(sizeof(glPoint) * (unsigned)starCount);
    
    for (NSInteger s = 0; s < starCount; ++s) {
        starVertices[s].p   = ccp(PearlGameRandomFor(GorillasGameRandomStars) % (long) fieldPx.size.width + fieldPx.origin.x,
                                  PearlGameRandomFor(GorillasGameRandomStars) % (long) fieldPx.size.height + fieldPx.origin.y);
        starVertices[s].c   = starColor;
        starVertices[s].s   = starSize;
    }
    
    // Push our window data into the VBO.
    glDeleteBuffers(1, &starVertexBuffer);
    glGenBuffers(1, &starVertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, starVertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, (signed)sizeof(glPoint) * starCount, starVertices, GL_DYNAMIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
}


-(void) update:(ccTime)dt {

    CGRect fieldPx      = [[GorillasAppDelegate get].gameLayer.cityLayer fieldInSpaceOf:self]; //CC_RECT_POINTS_TO_PIXELS([[GorillasAppDelegate get].gameLayer.cityLayer fieldInSpaceOf:self]);
    NSInteger speed     = [[GorillasConfig get].starSpeed integerValue];
    
    for (NSInteger s = 0; s < starCount; ++s)
        if (starVertices[s].p.x < fieldPx.origin.x)
            starVertices[s].p.x = fieldPx.size.width + fieldPx.origin.x
                                - ((int)(10000 * speed * dt) % PearlGameRandomFor(GorillasGameRandomStars)) / 10000.0f;
        else
            starVertices[s].p.x -= dt * speed;

    glBindBuffer(GL_ARRAY_BUFFER, starVertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, (signed)sizeof(glPoint) * starCount, starVertices, GL_DYNAMIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
}


-(void) draw {

    [super draw];

    CC_PROFILER_START_CATEGORY(kCCProfilerCategorySprite, @"StarLayer - draw");
   	CC_NODE_DRAW_SETUP();

//	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
//    //glEnableClientState(GL_COLOR_ARRAY);
//    //glEnableClientState(GL_VERTEX_ARRAY);
//    glEnableClientState(GL_POINT_SIZE_ARRAY_OES);
//    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
//	glDisable(GL_TEXTURE_2D);
    ccGLEnableVertexAttribs(kCCVertexAttribFlag_Position | kCCVertexAttribFlag_Color);
    glEnableVertexAttribArray(kPearlGLVertexAttrib_Size);

    // Stars.
    glBindBuffer(GL_ARRAY_BUFFER, starVertexBuffer);
    glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, sizeof(glPoint), (GLvoid *) offsetof(glPoint, p));
    glVertexAttribPointer(kPearlGLVertexAttrib_Size, 1, GL_FLOAT, GL_FALSE, sizeof(glPoint), (GLvoid *) offsetof(glPoint, s));
    glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_UNSIGNED_BYTE, GL_TRUE, sizeof(glPoint), (GLvoid *) offsetof(glPoint, c));

    glDrawArrays(GL_POINTS, 0, starCount);

    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glDisableVertexAttribArray(kPearlGLVertexAttrib_Size);
//    //glDisableClientState(GL_VERTEX_ARRAY);
//    //glDisableClientState(GL_COLOR_ARRAY);
//    glDisableClientState(GL_POINT_SIZE_ARRAY_OES);
//    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
//    glEnable(GL_TEXTURE_2D);

    CHECK_GL_ERROR_DEBUG();
    CC_INCREMENT_GL_DRAWS(1);
   	CC_PROFILER_STOP_CATEGORY(kCCProfilerCategorySprite, @"StarLayer - draw");
}


-(void) dealloc {

    glDeleteBuffers(1, &starVertexBuffer);
    starVertexBuffer = 0;
    
    free(starVertices);
    starVertices = nil;

    [super dealloc];
}


@end
