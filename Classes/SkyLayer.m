/*
 * This file is part of Gorillas.
 *
 *  Gorillas is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
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
//  SkyLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 26/10/08.
//  Copyright 2008, lhunath (Maarten Billemont). All rights reserved.
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
    
    for (NSUInteger s = 0; s < starCount; ++s) {
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
    stars = nil;
    
    [super dealloc];
}


@end
