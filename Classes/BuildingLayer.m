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
#import "Utility.h"


@implementation BuildingLayer

@synthesize contentSize;


- (id) init {

	return self = [self initWithWidth:0 heightRatio:0];
}


- (id) initWithWidth:(float)w heightRatio:(float)h {
    
	if (!(self = [super init]))
        return self;

    windowsVertexBuffer     = malloc(sizeof(GLuint *) * 2);
    windowsVertexBuffer[0]  = 0;
    windowsVertexBuffer[1]  = 0;
    windowsIndicesBuffer    = malloc(sizeof(GLuint *) * 2);
    windowsIndicesBuffer[0] = 0;
    windowsIndicesBuffer[1] = 0;
    wColors                 = nil;
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
    long wColor0 = [[GorillasConfig get] windowColorOff];
    long wColor1 = [[GorillasConfig get] windowColorOn];
    GLubyte *wColors0 = (GLubyte *)&wColor0;
    GLubyte *wColors1 = (GLubyte *)&wColor1;

    // Remember the window on and off colors in an array.
    free(wColors);
    wColors = malloc(sizeof(GLubyte) * 4 * 2);
    wColors[0] = wColors0[0];
    wColors[1] = wColors0[1];
    wColors[2] = wColors0[2];
    wColors[3] = wColors0[3];
    wColors[4] = wColors1[0];
    wColors[5] = wColors1[1];
    wColors[6] = wColors1[2];
    wColors[7] = wColors1[3];
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
    windowOffCount = 0;
    windowOnCount = 0;
    
    // Add windows.
    GLfloat *windowVertices = malloc(sizeof(GLfloat *) * windowCount * 8 * 2);
    GLushort *windowIndices = malloc(sizeof(GLushort *) * windowCount * 6 * 2);
    
    int w = 0;
    for (int y = wPad;
         w < windowCount;
         y += wPad + wHeight) {
        
        for (int x = wPad;
             x < contentSize.width - wWidth && w < windowCount;
             x += wPad + wWidth) {

            BOOL isOff = random() % 100 < 20;
            int wCurrentCount;
            if(isOff)
                wCurrentCount = windowOffCount++;
            else
                wCurrentCount = windowOnCount++;
            
            int wvOffset = (isOff? 0: windowCount * 8) + wCurrentCount * 8;
            windowVertices[wvOffset + 0] = x; // 0
            windowVertices[wvOffset + 1] = y;
            
            windowVertices[wvOffset + 2] = x + wWidth; // 1
            windowVertices[wvOffset + 3] = y;
            
            windowVertices[wvOffset + 4] = x; // 2
            windowVertices[wvOffset + 5] = y + wHeight;
            
            windowVertices[wvOffset + 6] = x + wWidth; // 3
            windowVertices[wvOffset + 7] = y + wHeight;
            
            int wiOffset = (isOff? 0: windowCount * 6) + wCurrentCount * 6;
            windowIndices[wiOffset + 0] = wCurrentCount * 4 + 0;
            windowIndices[wiOffset + 1] = wCurrentCount * 4 + 1;
            windowIndices[wiOffset + 2] = wCurrentCount * 4 + 2;
            windowIndices[wiOffset + 3] = wCurrentCount * 4 + 2;
            windowIndices[wiOffset + 4] = wCurrentCount * 4 + 3;
            windowIndices[wiOffset + 5] = wCurrentCount * 4 + 1;
            
            ++w;
        }
    }
    
    // Push our window data into VBOs.
    glDeleteBuffers(2, windowsVertexBuffer);
    glDeleteBuffers(2, windowsIndicesBuffer);
    glGenBuffers(2, windowsVertexBuffer);
    glGenBuffers(2, windowsIndicesBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, windowsVertexBuffer[0]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat *) * windowOffCount * 8, windowVertices, GL_STATIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ARRAY_BUFFER, windowsVertexBuffer[1]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat *) * windowOnCount * 8, windowVertices + (windowCount * 8), GL_STATIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, windowsIndicesBuffer[0]);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(GLushort *) * windowOffCount * 6, windowIndices, GL_STATIC_DRAW);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, windowsIndicesBuffer[1]);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(GLushort *) * windowOnCount * 6, windowIndices + (windowCount * 6), GL_STATIC_DRAW);
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
    for(BOOL isOn = NO; isOn < 2; ++isOn) {
        
        // Bind our VBOs & colors.
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, windowsIndicesBuffer[isOn]);
        glBindBuffer(GL_ARRAY_BUFFER, windowsVertexBuffer[isOn]);
        glVertexPointer(2, GL_FLOAT, 0, 0);
        glColor4ub(wColors[isOn * 4 + 3],
                   wColors[isOn * 4 + 2],
                   wColors[isOn * 4 + 1],
                   wColors[isOn * 4 + 0]);
        
        // == DRAW FRONT WINDOWS ==
        // Blend with DST_ALPHA (DST_ALPHA of 1 means draw SRC, hide DST; DST_ALPHA of 0 means hide SRC, leave DST).
        glBlendFunc(GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA);
        glDrawElements(GL_TRIANGLES, (isOn? windowOnCount: windowOffCount) * 6, GL_UNSIGNED_SHORT, 0);
        
        // == DRAW REAR WINDOWS ==
        // Set opacity of DST to 1 where there are windows -> building back won't draw over it.
        glColorMask(GL_FALSE, GL_FALSE, GL_FALSE, GL_TRUE);
        glBlendFunc(GL_ONE, GL_ZERO);
        glDrawElements(GL_TRIANGLES, (isOn? windowOnCount: windowOffCount) * 6, GL_UNSIGNED_SHORT, 0);

        glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
    }
    
    // Turn off VBOs.
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    
    // == DRAW BUILDING BACK ==
    // Draw back of building where DST opacity is < 1.
    glBlendFunc(GL_ONE_MINUS_DST_ALPHA, GL_DST_ALPHA);
    drawBoxFrom(cpvzero, cpv(contentSize.width, contentSize.height), backBuildingColor, backBuildingColor);

    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glDisableClientState(GL_VERTEX_ARRAY);
}


-(void) dealloc {
    
    glDeleteBuffers(2, windowsVertexBuffer);
    glDeleteBuffers(2, windowsIndicesBuffer);
    windowsVertexBuffer = nil;
    windowsIndicesBuffer = nil;
    
    free(wColors);
    wColors = nil;

    [super dealloc];
}


@end
