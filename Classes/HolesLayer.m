/*
 * This file is part of Gorillas.
 *
 *  Gorillas is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 2 of the License, or
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
//  HolesLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 04/01/09.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "HolesLayer.h"


@implementation HolesLayer


-(id) init {
    
    if(!(self = [super init]))
        return self;
    
	texture     = [[[TextureMgr sharedTextureMgr] addImage: @"hole.pvr"] retain];
    holes       = nil;
    holeCount   = 0;
    
    glGenBuffers(1, &holeVertexBuffer);
    
    return self;
}


-(BOOL) hitsHole: (cpVect)pos {
    
    for(NSUInteger h = 0; h < holeCount; ++h)
        if(((holes[h].x - pos.x) * (holes[h].x - pos.x) +
            (holes[h].y - pos.y) * (holes[h].y - pos.y) ) < powf(texture.pixelsWide, 2) / 9)
            return YES;
    
    return NO;
}


-(void) addHoleAt:(cpVect)pos {
    
    holes = realloc(holes, sizeof(cpVect) * ++holeCount);
    holes[holeCount - 1] = pos;
    
	glBindBuffer(GL_ARRAY_BUFFER, holeVertexBuffer);
	glBufferData(GL_ARRAY_BUFFER, sizeof(cpVect) * holeCount, holes, GL_DYNAMIC_DRAW);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
}


-(void) draw {
    
    // Blend our transarent white with DST.  If SRC, make DST transparent, hide original DST.
    glColorMask(GL_FALSE, GL_FALSE, GL_FALSE, GL_TRUE);
    glBlendFunc(GL_ZERO, GL_SRC_ALPHA);
    
	glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, texture.name);
	
	glEnable(GL_POINT_SPRITE_OES);
	glTexEnvi(GL_POINT_SPRITE_OES, GL_COORD_REPLACE_OES, GL_TRUE);
	
	glEnableClientState(GL_VERTEX_ARRAY);
	glBindBuffer(GL_ARRAY_BUFFER, holeVertexBuffer);
	glVertexPointer(2, GL_FLOAT, sizeof(cpVect), 0);
	
    GLfloat width = texture.pixelsWide;
    for(CocosNode *node = self; [node parent]; node = [node parent])
        width *= node.scale;
    
    glPointSize(width);
	
	glDrawArrays(GL_POINTS, 0, holeCount);
	
	// unbind VBO buffer
	glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    // Reset blend & data source.
    glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glPointSize(1);
	
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisable(GL_TEXTURE_2D);
	glDisable(GL_POINT_SPRITE_OES);
}


-(void) dealloc {
    
    glDeleteBuffers(1, &holeVertexBuffer);
    
    [super dealloc];
}


@end
