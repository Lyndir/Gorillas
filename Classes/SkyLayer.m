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
    
    const CGSize size = [[Director sharedDirector] winSize].size;
    starCount = [[GorillasConfig get] starAmount];
    
    free(stars);
    stars = malloc(sizeof(GLfloat) * 2 * starCount);
    
    for (int s = 0; s < starCount; ++s) {
        stars[s * 2 + 0] = random() % (long) size.width;
        stars[s * 2 + 1] = random() % (long) size.height;
    }
}


-(void) draw {
    
    // Sky background.
    //const CGSize size = [[Director sharedDirector] winSize].size;
    //[Utility drawBoxFrom:0 :0 to:size.width :size.height color:0x0000b7ff];
    
    // Stars.
    const GLubyte *c = [Utility colorToBytes:[[GorillasConfig get] starColor]];
    glColor4f(c[0], c[1], c[2], c[3]);
    
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
