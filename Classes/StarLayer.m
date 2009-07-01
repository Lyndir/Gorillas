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
#define maxStarSize 4


@implementation StarLayer

@synthesize contentSize;


-(id) initWidthDepth:(float)aDepth {
    
	if (!(self = [super init]))
        return self;
    
    starVertexBuffer    = 0;
    starCount           = -1;
    depth               = aDepth;
    
    [self reset];
    
    [self schedule:@selector(update:)];
    
    return self;
}


-(void) reset {
    
    if (starCount == [[GorillasConfig get] starAmount])
        return;
    
    CGSize winSize = [[Director sharedDirector] winSize];
    contentSize = CGSizeMake(winSize.width * 2, winSize.height * 2);
    CGFloat startX = winSize.width / 2 - contentSize.width / 2;
    starCount = [[GorillasConfig get] starAmount];
    
    free(starVertices);
    starVertices = malloc(sizeof(glPoint) * starCount);
    
    for (NSUInteger s = 0; s < starCount; ++s) {
        starVertices[s].p   = ccp(random() % (long) contentSize.width + startX,
                                  random() % (long) contentSize.height);
        starVertices[s].c   = ccc([GorillasConfig get].starColor);
        //starVertices[s].c.a *= depth;
        starVertices[s].s   = fmaxf(1.0f, roundf(maxStarSize * powf(depth, 3)));
    }
    
    // Push our window data into the VBO.
    glDeleteBuffers(1, &starVertexBuffer);
    glGenBuffers(1, &starVertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, starVertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(glPoint) * starCount, starVertices, GL_DYNAMIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
}


-(void) update:(ccTime)dt {

    CGSize winSize = [[Director sharedDirector] winSize];
    CGFloat startX = winSize.width / 2 - contentSize.width / 2;
    int speed = [GorillasConfig get].starSpeed;
    
    for (NSUInteger s = 0; s < starCount; ++s)
        if (starVertices[s].p.x < startX)
            starVertices[s].p.x = contentSize.width + startX
                                - ((int)(10000 * speed * dt) % random()) / 10000.0f;
        else
            starVertices[s].p.x -= dt * speed;

    glBindBuffer(GL_ARRAY_BUFFER, starVertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(glPoint) * starCount, starVertices, GL_DYNAMIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
}


-(void) draw {

    glEnableClientState(GL_COLOR_ARRAY);
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_POINT_SIZE_ARRAY_OES);
    
    // Stars.
    glBindBuffer(GL_ARRAY_BUFFER, starVertexBuffer);
    glVertexPointer(2, GL_FLOAT, sizeof(glPoint), 0);
    glPointSizePointerOES(GL_FLOAT, sizeof(glPoint), (GLvoid *) sizeof(CGPoint));
    glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(glPoint), (GLvoid *) (sizeof(CGPoint) + sizeof(GLfloat)));
    
    glDrawArrays(GL_POINTS, 0, starCount);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glDisableClientState(GL_POINT_SIZE_ARRAY_OES);
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_COLOR_ARRAY);
}


-(void) dealloc {

    glDeleteBuffers(1, &starVertexBuffer);
    starVertexBuffer = 0;
    
    free(starVertices);
    starVertices = nil;

    [super dealloc];
}


@end
