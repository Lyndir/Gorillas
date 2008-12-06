//
//  BuildingLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 25/10/08.
//  Copyright 2008 Lin.k. All rights reserved.
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

    // Calculate a random size for this building.
    const CGSize size = [[Director sharedDirector] winSize].size;
    
    const float floorHeight = wHeight + wPad;
    const long fixedFloors  = [[GorillasConfig get] fixedFloors];
    const long varFloors    = (size.height * [[GorillasConfig get] buildingMax]
                               - (fixedFloors * floorHeight) - wPad) / floorHeight;

    contentSize = CGSizeMake([[GorillasConfig get] buildingWidth],
                             (fixedFloors + (random() % varFloors)) * floorHeight + wPad);
    
    // Add windows.
    if(windows != nil || colors != nil) {
        for(int w = 0; w < windowCount; ++w) {
            free(windows[w]);
            free(colors[w]);
        }
        free(windows);
        free(colors);
    }
    windowCount = (1 + (int) (contentSize.height - wHeight - (int)wPad) / (int) (wPad + wHeight))
                * (1 + (int) (contentSize.width  - wWidth  - (int)wPad) / (int) (wPad + wWidth));
    
    windows = malloc(sizeof(GLfloat *) * windowCount);
    colors  = malloc(sizeof(GLubyte *) * windowCount);
    
	GLubyte r0, g0, b0, a0, r1, g1, b1, a1;
	r0 = (wColor0>>24) & 0xff;
	g0 = (wColor0>>16) & 0xff;
	b0 = (wColor0>>8 ) & 0xff;
	a0 = (wColor0>>0 ) & 0xff;
	r1 = (wColor1>>24) & 0xff;
	g1 = (wColor1>>16) & 0xff;
	b1 = (wColor1>>8 ) & 0xff;
	a1 = (wColor1>>0 ) & 0xff;
    
    int w = 0;
    for (int y = wPad;
         y < contentSize.height - wHeight;
         y += wPad + wHeight) {
        
        for (int x = wPad;
             x < contentSize.width - wWidth;
             x += wPad + wWidth) {
            
            GLubyte r, g, b, a;
            if(random() % 100 > 80) {
                r = r0; g = g0; b = b0; a = a0;
            } else {
                r = r1; g = g1; b = b1; a = a1;
            }
            
            colors[w] = malloc(sizeof(GLubyte) * 4 * 4);
            colors[w][0] = r;
            colors[w][1] = g;
            colors[w][2] = b;
            colors[w][3] = a;
            colors[w][4] = r;
            colors[w][5] = g;
            colors[w][6] = b;
            colors[w][7] = a;
            colors[w][8] = r;
            colors[w][9] = g;
            colors[w][10] = b;
            colors[w][11] = a;
            colors[w][12] = r;
            colors[w][13] = g;
            colors[w][14] = b;
            colors[w][15] = a;
            
            windows[w] = malloc(sizeof(GLfloat) * 4 * 2);
            windows[w][0] = x;
            windows[w][1] = y;
            windows[w][2] = x + wWidth;
            windows[w][3] = y;
            windows[w][4] = x;
            windows[w][5] = y + wHeight;
            windows[w][6] = x + wWidth;
            windows[w][7] = y + wHeight;
            
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
    for(int w = 0; w < windowCount; ++w) {
        glVertexPointer(2, GL_FLOAT, 0, windows[w]);
        glColorPointer(4, GL_UNSIGNED_BYTE, 0, colors[w]);
	
        // Draw our windows.
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    }
    
    // Reset blend & data source.
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_COLOR_ARRAY);
}


-(void) dealloc {
 
    [super dealloc];
    
    if(windows != nil || colors != nil) {
        for(int w = 0; w < windowCount; ++w) {
            free(windows[w]);
            free(colors[w]);
        }
        free(windows);
        free(colors);
    }
}


@end
