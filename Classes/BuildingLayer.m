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
//  BuildingLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 25/10/08.
//  Copyright 2008, lhunath (Maarten Billemont). All rights reserved.
//

#import "BuildingLayer.h"
#import "Utility.h"


@implementation BuildingLayer

@synthesize contentSize;


- (id) init {
    
	if (!(self = [super init]))
        return self;

    windows = nil;
    colors = nil;
        
    // Configure building properties.
    [self reset];
    
	return self;
}


-(void) reset {
    
    buildingColor  = [[GorillasConfig get] buildingColor];
    float wPad = [[GorillasConfig get] windowPadding];
    float wWidth = [[GorillasConfig get] windowWidth];
    float wHeight = [[GorillasConfig get] windowHeight];
    long wColor0 = [[GorillasConfig get] windowColorOff];
    long wColor1 = [[GorillasConfig get] windowColorOn];
    GLubyte *wColors0 = (GLubyte *)&wColor0;
    GLubyte *wColors1 = (GLubyte *)&wColor1;

    // Calculate a random size for this building.
    const CGSize size = [[Director sharedDirector] winSize].size;
    
    const float floorHeight = wHeight + wPad;
    const long fixedFloors  = [[GorillasConfig get] fixedFloors];
    const long varFloors    = (size.height * [[GorillasConfig get] buildingMax]
                               - (fixedFloors * floorHeight) - wPad) / floorHeight;

    contentSize = CGSizeMake([[GorillasConfig get] buildingWidth],
                             (fixedFloors + (random() % varFloors)) * floorHeight + wPad);
    windowCount = (1 + (int) (contentSize.height - wHeight - (int)wPad) / (int) (wPad + wHeight))
                * (1 + (int) (contentSize.width  - wWidth  - (int)wPad) / (int) (wPad + wWidth));
    
    // Add windows.
    if(windows != nil)
        free(windows);
    if(colors != nil)
        free(colors);
    
    windows = malloc(sizeof(GLfloat *) * windowCount * 6 * 2);
    colors  = malloc(sizeof(GLubyte *) * windowCount * 6 * 4);
    
    int w = 0;
    for (int y = wPad;
         y < contentSize.height - wHeight;
         y += wPad + wHeight) {
        
        for (int x = wPad;
             x < contentSize.width - wWidth;
             x += wPad + wWidth) {
            
            GLubyte r, g, b, a;
            if(random() % 100 > 80) {
                r = wColors0[3]; g = wColors0[2]; b = wColors0[1]; a = wColors0[0];
            } else {
                r = wColors1[3]; g = wColors1[2]; b = wColors1[1]; a = wColors1[0];
            }
            
            colors[w * 24 + 0] = colors[w * 24 + 4] = colors[w * 24 + 8]  = colors[w * 24 + 12] = colors[w * 24 + 16] = colors[w * 24 + 20] = r;
            colors[w * 24 + 1] = colors[w * 24 + 5] = colors[w * 24 + 9]  = colors[w * 24 + 13] = colors[w * 24 + 17] = colors[w * 24 + 21] = g;
            colors[w * 24 + 2] = colors[w * 24 + 6] = colors[w * 24 + 10] = colors[w * 24 + 14] = colors[w * 24 + 18] = colors[w * 24 + 22] = b;
            colors[w * 24 + 3] = colors[w * 24 + 7] = colors[w * 24 + 11] = colors[w * 24 + 15] = colors[w * 24 + 19] = colors[w * 24 + 23] = a;
            
            windows[w * 12 + 0] = x;
            windows[w * 12 + 1] = y;
            windows[w * 12 + 2] = x + wWidth;
            windows[w * 12 + 3] = y;
            windows[w * 12 + 4] = x;
            windows[w * 12 + 5] = y + wHeight;
            windows[w * 12 + 6] = x;
            windows[w * 12 + 7] = y + wHeight;
            windows[w * 12 + 8] = x + wWidth;
            windows[w * 12 + 9] = y + wHeight;
            windows[w * 12 + 10] = x + wWidth;
            windows[w * 12 + 11] = y;
            
            w++;
        }
    }
}


-(void) draw {
    
    // Blend with DST_ALPHA (DST_ALPHA of 1 means draw SRC, hide DST; DST_ALPHA of 0 means hide SRC, leave DST).
    glBlendFunc(GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA);
    [Utility drawBoxFrom:cpv(0, 0) size:cpv(contentSize.width, contentSize.height) color:buildingColor];

    // Tell OpenGL about our data.
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);
    glVertexPointer(2, GL_FLOAT, 0, windows);
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, colors);
	
    // Draw our windows.
    glDrawArrays(GL_TRIANGLES, 0, 6 * windowCount);
    
    // Reset blend & data source.
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_COLOR_ARRAY);
}


-(void) dealloc {
 
    [super dealloc];
    
    if(windows != nil || colors != nil) {
        free(windows);
        free(colors);
    }
}


@end
