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

@interface StarLayer()

@property(nonatomic) BOOL dirty;
@end

@implementation StarLayer { GLuint starVertexObject; }

-(id) initWidthDepth:(float)aDepth {

    if (!(self = [super init]))
        return self;
    
    starVertexObject    = 0;
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

    starCount           = [[GorillasConfig get].starAmount intValue];
    ccColor4B starColor = ccc4l([[GorillasConfig get].starColor unsignedLongValue]);
    starColor.r         *= depth;
    starColor.g         *= depth;
    starColor.b         *= depth;
    CGFloat starSize    = fmaxf(1.0f, maxStarSize * depth);
    
    free(starVertices);
    starVertices = calloc((unsigned)starCount, sizeof(glPoint));
    
    CGSize winSize      = [CCDirector sharedDirector].winSize;
    for (NSInteger s = 0; s < starCount; ++s) {
        starVertices[s].p   = ccp(PearlGameRandomFor(GorillasGameRandomStars) % (int)winSize.width,
                                  PearlGameRandomFor(GorillasGameRandomStars) % (int)winSize.height);
        starVertices[s].c   = starColor;
        starVertices[s].s   = starSize;
    }

    glDeleteVertexArrays( 1, &starVertexObject );
    glGenVertexArrays( 1, &starVertexObject );
    ccGLBindVAO( starVertexObject );
    glDeleteBuffers(1, &starVertexBuffer);
    glGenBuffers(1, &starVertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, starVertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, (signed)sizeof(glPoint) * starCount, starVertices, GL_DYNAMIC_DRAW);
    glEnableVertexAttribArray( kCCVertexAttrib_Position );
    glVertexAttribPointer( kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, sizeof(glPoint), (GLvoid *)offsetof(glPoint, p));
    glEnableVertexAttribArray( kPearlGLVertexAttrib_Size );
    glVertexAttribPointer( kPearlGLVertexAttrib_Size, 1, GL_FLOAT, GL_FALSE, sizeof(glPoint), (GLvoid *)offsetof(glPoint, s));
    glEnableVertexAttribArray( kCCVertexAttrib_Color );
    glVertexAttribPointer( kCCVertexAttrib_Color, 4, GL_UNSIGNED_BYTE, GL_TRUE, sizeof(glPoint), (GLvoid *)offsetof(glPoint, c));
    ccGLBindVAO( 0 );
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glDisableVertexAttribArray( kPearlGLVertexAttrib_Size );
    CHECK_GL_ERROR_DEBUG();
}


-(void) update:(ccTime)dt {

    CGSize winSize      = [CCDirector sharedDirector].winSize;
    NSInteger speed     = [[GorillasConfig get].starSpeed integerValue];
    
    for (NSInteger s = 0; s < starCount; ++s) {
        starVertices[s].p.x -= dt * speed;
        
        if (starVertices[s].p.x < 0)
            starVertices[s].p.x = winSize.width + PearlGameRandomFor(GorillasGameRandomStars) % (int)winSize.width / 7;
    }
    
    self.dirty = YES;
}


-(void) draw {

    [super draw];

    CC_PROFILER_START_CATEGORY(kCCProfilerCategorySprite, @"StarLayer - draw");
    if (self.dirty) {
        glBindBuffer( GL_ARRAY_BUFFER, starVertexBuffer );
        glBufferData( GL_ARRAY_BUFFER, (signed)sizeof(glPoint) * starCount, starVertices, GL_DYNAMIC_DRAW );
        glBindBuffer( GL_ARRAY_BUFFER, 0 );
        self.dirty = NO;
    }

    CC_NODE_DRAW_SETUP();
    ccGLBindVAO( starVertexObject );
    glDrawArrays(GL_POINTS, 0, starCount);

    CHECK_GL_ERROR_DEBUG();
    CC_INCREMENT_GL_DRAWS(1);
    CC_PROFILER_STOP_CATEGORY(kCCProfilerCategorySprite, @"StarLayer - draw");
}


-(void) dealloc {

    glDeleteVertexArrays( 1, &starVertexObject );
    glDeleteBuffers(1, &starVertexBuffer);
    starVertexBuffer = 0;
    CHECK_GL_ERROR_DEBUG();
    
    free(starVertices);
    starVertices = nil;

    [super dealloc];
}


@end
