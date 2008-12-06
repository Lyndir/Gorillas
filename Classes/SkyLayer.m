//
//  SkyLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 26/10/08.
//  Copyright 2008 Lin.k. All rights reserved.
//

#import "SkyLayer.h"
#import "Utility.h"


@implementation SkyLayer

@synthesize contentSize;


-(id) init {
    
	if (!(self = [super init]))
        return self;
    
    starCount = -1;
    [self reset];
    
    return self;
}


-(void) reset {
    
    if (starCount == [[GorillasConfig get] starAmount])
        return;
    
    contentSize = [[Director sharedDirector] winSize].size;
    starCount = [[GorillasConfig get] starAmount];
    
    free(stars);
    stars = malloc(sizeof(GLfloat) * 2 * starCount);
    
    for (int s = 0; s < starCount; ++s) {
        stars[s * 2 + 0] = random() % (long) contentSize.width;
        stars[s * 2 + 1] = random() % (long) contentSize.height;
    }
}


-(void) draw {
    
    // Stars.
    const long color = [[GorillasConfig get] starColor];
    const GLubyte *colorBytes = (GLubyte *)&color;
    glColor4f(colorBytes[3], colorBytes[2], colorBytes[1], colorBytes[0]);
    
    glVertexPointer(2, GL_FLOAT, 0, stars);
    glEnableClientState(GL_VERTEX_ARRAY);

    glDrawArrays(GL_POINTS, 0, starCount);
    
    glDisableClientState(GL_VERTEX_ARRAY);
}


-(void) dealloc {
    
    free(stars);
    
    [super dealloc];
}


@end
