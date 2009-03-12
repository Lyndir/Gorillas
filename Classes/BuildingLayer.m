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
//  BuildingLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 25/10/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "BuildingLayer.h"

@implementation BuildingLayer

@synthesize contentSize;


- (id) init {

	return self = [self initWithWidth:0 heightRatio:0];
}


- (id) initWithWidth:(float)w heightRatio:(float)h {
    
	if (!(self = [super init]))
        return self;

    windowsVertexBuffer     = 0;
    windowsIndicesBuffer    = 0;
    width                   = w;
    heightRatio             = h;
        
    // Configure building properties.
    [self reset];
    
	return self;
}


-(void) reset {
    
    buildingColor  = [[GorillasConfig get] buildingColor];
    GLubyte *bColor = (GLubyte *)&buildingColor;
    backBuildingColor = ((int)(bColor[3] * 0.2f)   << 24) |
                        ((int)(bColor[2] * 0.2f)   << 16) |
                        ((int)(bColor[1] * 0.2f)   << 8) |
                        ((int)(bColor[0])          << 0);
    
    float wPad = [[GorillasConfig get] windowPadding];
    float wWidth = [[GorillasConfig get] windowWidth];
    float wHeight = [[GorillasConfig get] windowHeight];
    ccColorB wColor0 = ccc([[GorillasConfig get] windowColorOff]);
    ccColorB wColor1 = ccc([[GorillasConfig get] windowColorOn]);
    ccColorB wColor10 = { (wColor0.r + wColor1.r) / 2, (wColor0.g + wColor1.g) / 2, (wColor0.b + wColor1.b) / 2, (wColor0.a + wColor1.a) / 2 };

    // Remember the window on and off colors in an array.
    /*memcpy(&wColors, (GLubyte *)&wColor0, sizeof(long));
    memcpy(&wColors + sizeof(long), (GLubyte *)&wColor1, sizeof(long));*/

    // Calculate a random size for this building.
    const CGSize size = [[Director sharedDirector] winSize];
    const float floorHeight = wHeight + wPad;
    const int fixedFloors   = [[GorillasConfig get] fixedFloors];
    const int varFloors     = (size.height * [[GorillasConfig get] buildingMax]
                               - (fixedFloors * floorHeight) - wPad) / floorHeight;
    const int addFloors     = (heightRatio || !varFloors)? varFloors * heightRatio: random() % varFloors;

    contentSize = CGSizeMake(width? width: [[GorillasConfig get] buildingWidth],
                             (fixedFloors + addFloors) * floorHeight + wPad);
    windowCount = (1 + (int) (contentSize.height - wHeight - (int)wPad) / (int) (wPad + wHeight))
                * (1 + (int) (contentSize.width  - wWidth  - (int)wPad) / (int) (wPad + wWidth));
    
    // Add windows.
    Vertex *windowVertices = malloc(sizeof(Vertex) * windowCount * 4);
    GLushort *windowIndices = malloc(sizeof(GLushort) * windowCount * 6);
    
    NSUInteger w = 0;
    for (int y = wPad;
         w < windowCount;
         y += wPad + wHeight) {
        
        for (int x = wPad;
             x < contentSize.width - wWidth && w < windowCount;
             x += wPad + wWidth) {

            NSUInteger i = w * 4, j = w * 6;
            BOOL isOff = random() % 100 < 20;
            
            
            windowVertices[i + 0].c = windowVertices[i + 1].c
                = isOff? wColor0: [GorillasConfig get].visualFx? wColor10: wColor1;
            windowVertices[i + 2].c = windowVertices[i + 3].c
                = isOff? wColor0: wColor1;
            
            windowVertices[i + 0].p = cpv(x         , y);
            windowVertices[i + 1].p = cpv(x + wWidth, y);
            windowVertices[i + 2].p = cpv(x         , y + wHeight);
            windowVertices[i + 3].p = cpv(x + wWidth, y + wHeight);
            
            windowIndices[j + 0] = i + 0;
            windowIndices[j + 1] = i + 1;
            windowIndices[j + 2] = i + 2;
            windowIndices[j + 3] = i + 2;
            windowIndices[j + 4] = i + 3;
            windowIndices[j + 5] = i + 1;
            
            ++w;
        }
    }
    if(w != windowCount)
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"Windows vertix count not the same as window amount." userInfo:nil];
    
    // Push our window data into VBOs.
    glDeleteBuffers(1, &windowsVertexBuffer);
    glDeleteBuffers(1, &windowsIndicesBuffer);
    glGenBuffers(1, &windowsVertexBuffer);
    glGenBuffers(1, &windowsIndicesBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, windowsVertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertex) * windowCount * 4, windowVertices, GL_DYNAMIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, windowsIndicesBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(GLushort) * windowCount * 6, windowIndices, GL_DYNAMIC_DRAW);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    
    // Free the clientside window data.
    free(windowVertices);
    free(windowIndices);
}


-(void) draw {
    
    glEnableClientState(GL_VERTEX_ARRAY);
    
    // == DRAW BUILDING ==
    // Blend with DST_ALPHA (DST_ALPHA of 1 means draw SRC, hide DST; DST_ALPHA of 0 means hide SRC, leave DST).
    glBlendFunc(GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA);
    drawBoxFrom(cpvzero, cpv(contentSize.width, contentSize.height), buildingColor, buildingColor);
    
    // == DRAW WINDOWS ==
    // Bind our VBOs & colors.
    glBindBuffer(GL_ARRAY_BUFFER, windowsVertexBuffer);
    glVertexPointer(2, GL_FLOAT, sizeof(Vertex), 0);
    
    glEnableClientState(GL_COLOR_ARRAY);
    glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(Vertex), (GLvoid *) sizeof(cpVect));
    //glColor4ub(0xFF, 0x00, 0x00, 0xFF);
    
    // == DRAW FRONT WINDOWS ==
    // Blend with DST_ALPHA (DST_ALPHA of 1 means draw SRC, hide DST; DST_ALPHA of 0 means hide SRC, leave DST).
    glBlendFunc(GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, windowsIndicesBuffer);
    glDrawElements(GL_TRIANGLES, windowCount * 6, GL_UNSIGNED_SHORT, 0);
    
    // == DRAW REAR WINDOWS ==
    // Set opacity of DST to 1 where there are windows -> building back won't draw over it.
    glColorMask(GL_FALSE, GL_FALSE, GL_FALSE, GL_TRUE);
    glBlendFunc(GL_ONE, GL_ZERO);
    glDrawElements(GL_TRIANGLES, windowCount * 6, GL_UNSIGNED_SHORT, 0);
    
    glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
    
    // Turn off VBOs.
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glDisableClientState(GL_COLOR_ARRAY);
    
    // == DRAW BUILDING BACK ==
    // Draw back of building where DST opacity is < 1.
    glBlendFunc(GL_ONE_MINUS_DST_ALPHA, GL_DST_ALPHA);
    drawBoxFrom(cpvzero, cpv(contentSize.width, contentSize.height), backBuildingColor, backBuildingColor);
    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glDisableClientState(GL_VERTEX_ARRAY);
}


-(void) dealloc {
    
    glDeleteBuffers(2, &windowsVertexBuffer);
    glDeleteBuffers(2, &windowsIndicesBuffer);
    windowsVertexBuffer = 0;
    windowsIndicesBuffer = 0;

    [super dealloc];
}


@end
