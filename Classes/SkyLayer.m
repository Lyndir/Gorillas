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
#define maxStarSize 4


@implementation SkyLayer

@synthesize contentSize;


-(id) initWidthDepth:(float)aDepth {
    
	if (!(self = [super init]))
        return self;
    
    starVertexBuffer    = 0;
    starCount           = -1;
    depth               = aDepth;
    
    [self reset];
    
    return self;
}


-(void) reset {
    
    if (starCount == [[GorillasConfig get] starAmount])
        return;
    
    CGSize winSize = [[Director sharedDirector] winSize];
    contentSize = CGSizeMake(winSize.width * 2, winSize.height * 2);
    starCount = [[GorillasConfig get] starAmount];
    
    glPoint *starVertices = malloc(sizeof(glPoint) * starCount * 4);
    
    for (NSUInteger s = 0; s < starCount * 4; ++s) {
        starVertices[s].p   = ccp(random() % (long) contentSize.width,
                                  random() % (long) contentSize.height);
        starVertices[s].c   = ccc([GorillasConfig get].starColor);
        //starVertices[s].c.a *= depth;
        starVertices[s].s   = fmaxf(1.0f, roundf(maxStarSize * powf(depth, 3)));
    }
    
    // Push our window data into the VBO.
    glDeleteBuffers(1, &starVertexBuffer);
    glGenBuffers(1, &starVertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, starVertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(glPoint) * starCount * 4, starVertices, GL_DYNAMIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);

    free(starVertices);
}


-(void) draw {

    glEnable(GL_POINT_SMOOTH);
    glEnableClientState(GL_COLOR_ARRAY);
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_POINT_SIZE_ARRAY_OES);
    
    // Stars.
    glBindBuffer(GL_ARRAY_BUFFER, starVertexBuffer);
    glVertexPointer(2, GL_FLOAT, sizeof(glPoint), 0);
    glPointSizePointerOES(GL_FLOAT, sizeof(glPoint), (GLvoid *) sizeof(CGPoint));
    glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(glPoint), (GLvoid *) (sizeof(CGPoint) + sizeof(GLfloat)));
    
    glDrawArrays(GL_POINTS, 0, starCount * 4);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glDisableClientState(GL_POINT_SIZE_ARRAY_OES);
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_COLOR_ARRAY);
    glDisable(GL_POINT_SMOOTH);
}


-(void) dealloc {

    glDeleteBuffers(1, &starVertexBuffer);
    starVertexBuffer = 0;
    
    [super dealloc];
}


@end
