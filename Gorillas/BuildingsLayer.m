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
//  BuildingsLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 25/10/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "BuildingsLayer.h"

@implementation BuildingsLayer

@synthesize buildings, buildingCount;


- (id) init {
    
    if (!(self = [self initWithWidthRatio:1 heightRatio:1 lightRatio:0]))
        return nil;
    
	return self;
}


- (id) initWithWidthRatio:(CGFloat)w heightRatio:(float)h lightRatio:(float)l {
    
	if (!(self = [super init]))
        return self;
    
    buildingWidthRatio      = w;
    buildingHeightRatio     = h;
    lightRatio              = l;
    
    buildingsVertexBuffer   = 0;
    buildingsIndicesBuffer  = 0;
    windowsVertexBuffer     = 0;
    windowsIndicesBuffer    = 0;
    
    // Must reset before onEnter.  Others' onEnter depends on us being done.
    [self reset];
    
	return self;
}


-(BOOL) hitsBuilding:(CGPoint)pos {
    
    for (NSUInteger b = 0; b < buildingCount; ++b)
        if (pos.y >= 0 && pos.y <= buildings[b].size.height)
            if (pos.x >= buildings[b].x && pos.x <= buildings[b].x + buildings[b].size.width)
                return YES;
    
    return NO;
}


-(void) reset {
    
    dbg(@"BuildingsLayer reset start");
    const GorillasConfig *config    = [GorillasConfig get];
    const BOOL visualFx             = [config.visualFx boolValue];
    
    const ccColor4B skyColor        = ccc4l([config.skyColor longValue]);
    const ccColor4B wColor0         = ccc4shade(ccc4lighten(ccc4l([config.windowColorOff longValue]), lightRatio), skyColor, MAX(0, -lightRatio / 2));
    const ccColor4B wColor1         = ccc4shade(ccc4lighten(ccc4l([config.windowColorOn longValue]), lightRatio), skyColor, MAX(0, -lightRatio / 2));
    ccColor4B wColor10;
    wColor10.r                      = (wColor0.r + wColor1.r) / 2;
    wColor10.g                      = (wColor0.g + wColor1.g) / 2;
    wColor10.b                      = (wColor0.b + wColor1.b) / 2;
    wColor10.a                      = (wColor0.a + wColor1.a) / 2;
    
    const NSUInteger fixedFloors    = [config.fixedFloors unsignedIntValue];
    const NSInteger varFloors       = [config.varFloors unsignedIntValue];
    const CGSize winSize            = [CCDirector sharedDirector].winSize;
    const CGFloat buildingWidth     = buildingWidthRatio * (winSize.width / [config.buildingAmount unsignedIntValue]);
    const CGFloat wWidthPt                  = buildingWidth / ([config.windowAmount unsignedIntValue] * 2 + 1);
    const CGFloat wPadPt                    = wWidthPt;
    const CGFloat wHeightPt                 = wWidthPt * 2;
    const CGFloat floorHeightPt             = wHeightPt + wPadPt;
    
    // Calculcate buildings.
    windowCount                     = 0;
    buildingCount                   = [config.buildingAmount unsignedIntValue] * 3;
    free(buildings);
    if (!buildingCount)
        return;
    buildings = malloc(sizeof(Building) * buildingCount);
    for (NSUInteger b = 0; b < buildingCount; ++b) {
        // Building's position.
        buildings[b].x              = b * buildingWidth - buildingWidth * (buildingCount - [config.buildingAmount unsignedIntValue]) / 2;
        
        // Building's size.
        NSInteger addFloors = 0;
        if (varFloors)
            addFloors               = buildingHeightRatio * (gameRandom() % varFloors);
        buildings[b].size           = CGSizeMake(buildingWidth - 1, (fixedFloors + addFloors) * floorHeightPt + wPadPt);
        
        // Building's windows.
        buildings[b].windowCount    = (fixedFloors + addFloors) * [config.windowAmount unsignedIntValue];
        windowCount                 += buildings[b].windowCount;
        
        // Building's color.
        buildings[b].frontColor     = ccc4shade(ccc4lighten([config buildingColor], lightRatio), skyColor, MAX(0, -lightRatio / 2));
        buildings[b].backColor.r    = (GLubyte)(buildings[b].frontColor.r * 0.2f);
        buildings[b].backColor.g    = (GLubyte)(buildings[b].frontColor.g * 0.2f);
        buildings[b].backColor.b    = (GLubyte)(buildings[b].frontColor.b * 0.2f);
        buildings[b].backColor.a    = (GLubyte)(buildings[b].frontColor.a * 1.0f);
    }
    
    // Build vertex arrays.
    BuildingVertex *buildingVertices        = malloc(sizeof(BuildingVertex)     /* size of a vertex */
                                                     * 4                        /* amount of vertices per building */
                                                     * buildingCount            /* amount of buildings */);
    GLushort *buildingIndices               = malloc(sizeof(GLushort)           /* size of an index */
                                                     * 6                        /* amount of indexes per window */
                                                     * buildingCount            /* amount of windows in all buildings */);
    Vertex *windowVertices                  = malloc(sizeof(Vertex)             /* size of a vertex */
                                                     * 4                        /* amount of vertices per window */
                                                     * windowCount              /* amount of windows in all buildings */);
    GLushort *windowIndices                 = malloc(sizeof(GLushort)           /* size of an index */
                                                     * 6                        /* amount of indexes per window */
                                                     * windowCount              /* amount of windows in all buildings */);
    const CGFloat wPadPx = wPadPt * CC_CONTENT_SCALE_FACTOR();
    const CGFloat wWidthPx = wWidthPt * CC_CONTENT_SCALE_FACTOR();
    const CGFloat wHeightPx = wHeightPt * CC_CONTENT_SCALE_FACTOR();
    const CGFloat floorHeightPx = floorHeightPt * CC_CONTENT_SCALE_FACTOR();
    for (NSUInteger w = 0, b = 0; b < buildingCount; ++b) {
        
        const CGFloat bx                    = buildings[b].x * CC_CONTENT_SCALE_FACTOR();
        const CGSize bs                     = CGSizeMake(buildings[b].size.width    * CC_CONTENT_SCALE_FACTOR(),
                                                         buildings[b].size.height   * CC_CONTENT_SCALE_FACTOR());
        const NSUInteger bv                 = b * 4;
        const NSUInteger bi                 = b * 6;
        
        buildingVertices[bv + 0].front.c    = buildingVertices[bv + 1].front.c      = buildings[b].backColor;
        buildingVertices[bv + 2].front.c    = buildingVertices[bv + 3].front.c      = buildings[b].frontColor;
        buildingVertices[bv + 0].backColor  = buildingVertices[bv + 1].backColor    = buildings[b].backColor;
        buildingVertices[bv + 2].backColor  = buildingVertices[bv + 3].backColor    = buildings[b].backColor;
        
        buildingVertices[bv + 0].front.p    = ccp(bx                          , 0);
        buildingVertices[bv + 1].front.p    = ccp(bx + bs.width, 0);
        buildingVertices[bv + 2].front.p    = ccp(bx           , 0 + bs.height);
        buildingVertices[bv + 3].front.p    = ccp(bx + bs.width, 0 + bs.height);
        
        buildingIndices[bi + 0]             = bv + 0;
        buildingIndices[bi + 1]             = bv + 1;
        buildingIndices[bi + 2]             = bv + 2;
        buildingIndices[bi + 3]             = bv + 2;
        buildingIndices[bi + 4]             = bv + 3;
        buildingIndices[bi + 5]             = bv + 1;
        
        NSUInteger bw = 0, floor = 0;
        while (bw < buildings[b].windowCount) {
            const CGFloat y = wPadPx + floor * floorHeightPx;
            
            for (NSInteger wx = wPadPx;
                 wx < bs.width - wWidthPx && bw < buildings[b].windowCount;
                 wx += wPadPx + wWidthPx) {
                
                // Reason we don't use gameRandom for windows:
                // Window count across multiple resolution devices is unpredictable due to rounding errors.
                const BOOL isOff            = random() % 100 < 20;
                const NSUInteger wv         = (w + bw) * 4;
                const NSUInteger wi         = (w + bw) * 6;
                
                windowVertices[wv + 0].c    = windowVertices[wv + 1].c  = isOff? wColor0: visualFx? wColor10: wColor1;
                windowVertices[wv + 2].c    = windowVertices[wv + 3].c  = isOff? wColor0: wColor1;
                
                windowVertices[wv + 0].p    = ccp(bx + wx           , y);
                windowVertices[wv + 1].p    = ccp(bx + wx + wWidthPx, y);
                windowVertices[wv + 2].p    = ccp(bx + wx           , y + wHeightPx);
                windowVertices[wv + 3].p    = ccp(bx + wx + wWidthPx, y + wHeightPx);
                
                windowIndices[wi + 0]       = wv + 0;
                windowIndices[wi + 1]       = wv + 1;
                windowIndices[wi + 2]       = wv + 2;
                windowIndices[wi + 3]       = wv + 2;
                windowIndices[wi + 4]       = wv + 3;
                windowIndices[wi + 5]       = wv + 1;
                
                ++bw;
            }
            
            ++floor;
        }
        if(bw != buildings[b].windowCount)
            err(@"Windows vertex count not the same as window amount.");
        
        w += bw;
    }
    
    // Push our window data into VBOs.
    glDeleteBuffers(1, &buildingsVertexBuffer);
    glDeleteBuffers(1, &buildingsIndicesBuffer);
    glDeleteBuffers(1, &windowsVertexBuffer);
    glDeleteBuffers(1, &windowsIndicesBuffer);
    glGenBuffers(1, &buildingsVertexBuffer);
    glGenBuffers(1, &buildingsIndicesBuffer);
    glGenBuffers(1, &windowsVertexBuffer);
    glGenBuffers(1, &windowsIndicesBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, buildingsVertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(BuildingVertex) * buildingCount * 4, buildingVertices, GL_DYNAMIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, windowsVertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertex) * windowCount * 4, windowVertices, GL_DYNAMIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, buildingsIndicesBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(GLushort) * buildingCount * 6, buildingIndices, GL_DYNAMIC_DRAW);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, windowsIndicesBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(GLushort) * windowCount * 6, windowIndices, GL_DYNAMIC_DRAW);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    
    // Free the client side data.
    free(buildingVertices);
    free(windowVertices);
    free(windowIndices);
}


-(void) draw {
    
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
    //glEnableClientState(GL_VERTEX_ARRAY);
    //glEnableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisable(GL_TEXTURE_2D);
    
    // Drawing Front Side.
    glBlendFunc(GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA);
    
    // == DRAW BUILDING ==
    // Blend with DST_ALPHA (DST_ALPHA of 1 means draw SRC, hide DST; DST_ALPHA of 0 means hide SRC, leave DST).
    glBindBuffer(GL_ARRAY_BUFFER, buildingsVertexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, buildingsIndicesBuffer);
    glVertexPointer(2, GL_FLOAT, sizeof(BuildingVertex), 0);
    glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(BuildingVertex), (GLvoid *) sizeof(CGPoint));
    
    glDrawElements(GL_TRIANGLES, buildingCount * 6, GL_UNSIGNED_SHORT, 0);
    //drawBoxFrom(CGPointZero, ccp(contentSize.width, contentSize.height), buildingColor, buildingColor);
    
    // == DRAW WINDOWS ==
    // Bind our VBOs & colors.
    glBindBuffer(GL_ARRAY_BUFFER, windowsVertexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, windowsIndicesBuffer);
    glVertexPointer(2, GL_FLOAT, sizeof(Vertex), 0);
    glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(Vertex), (GLvoid *) sizeof(CGPoint));
    
    // = DRAW FRONT WINDOWS =
    // Blend with DST_ALPHA (DST_ALPHA of 1 means draw SRC, hide DST; DST_ALPHA of 0 means hide SRC, leave DST).
    glDrawElements(GL_TRIANGLES, windowCount * 6, GL_UNSIGNED_SHORT, 0);
    
    // Drawing Rear Side.
    if ([[GorillasConfig get].visualFx boolValue] && buildingHeightRatio == 1) {
        glBlendFunc(GL_ONE, GL_ZERO);
        
        // = DRAW REAR WINDOWS =
        // Set opacity of DST to 1 where there are windows -> building back won't draw over it.
        glColorMask(GL_FALSE, GL_FALSE, GL_FALSE, GL_TRUE);
        glDrawElements(GL_TRIANGLES, windowCount * 6, GL_UNSIGNED_SHORT, 0);
        glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
        
        // == DRAW BUILDING BACK ==
        // Draw back of building where DST opacity is < 1.
        glBindBuffer(GL_ARRAY_BUFFER, buildingsVertexBuffer);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, buildingsIndicesBuffer);
        glVertexPointer(2, GL_FLOAT, sizeof(BuildingVertex), 0);
        glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(BuildingVertex), (GLvoid *) sizeof(Vertex));
        
        glBlendFunc(GL_ONE_MINUS_DST_ALPHA, GL_DST_ALPHA);
        glDrawElements(GL_TRIANGLES, buildingCount * 6, GL_UNSIGNED_SHORT, 0);
    }
    
    // Turn off state.
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    //glDisableClientState(GL_COLOR_ARRAY);
    //glDisableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);
    
}


-(void) dealloc {
    
    glDeleteBuffers(2, &buildingsVertexBuffer);
    glDeleteBuffers(2, &buildingsIndicesBuffer);
    glDeleteBuffers(2, &windowsVertexBuffer);
    glDeleteBuffers(2, &windowsIndicesBuffer);
    buildingsVertexBuffer   = 0;
    buildingsIndicesBuffer  = 0;
    windowsVertexBuffer     = 0;
    windowsIndicesBuffer    = 0;
    
    [super dealloc];
}


@end
