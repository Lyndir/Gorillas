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
//  Utility.c
//  Gorillas
//
//  Created by Maarten Billemont on 26/11/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//




NSString* RPad(const NSString* string, const NSUInteger l) {
    
    NSMutableString *newString = [string mutableCopy];
    while (newString.length < l)
        [newString appendString:@" "];
    
    return newString;
}


NSString* LPad(const NSString* string, const NSUInteger l) {
    
    NSMutableString *newString = [string mutableCopy];
    while (newString.length < l)
        [newString insertString:@" " atIndex:0];
    
    return newString;
}


NSString* AppendOrdinalPrefix(const NSInteger number, const NSString* prefix) {
    
    NSString *suffix = NSLocalizedString(@"time.day.suffix", @"th");
    if(number % 10 == 1 && number != 11)
        suffix = NSLocalizedString(@"time.day.suffix.one", @"st");
    else if(number % 10 == 2 && number != 12)
        suffix = NSLocalizedString(@"time.day.suffix.two", @"nd");
    else if(number % 10 == 3 && number != 13)
        suffix = NSLocalizedString(@"time.day.suffix.three", @"rd");
    
    return [NSString stringWithFormat:@"%@%@", prefix, suffix];
}


BOOL IsIPod() {

#if TARGET_IPHONE_SIMULATOR
    return NO;
#else
    return [[[UIDevice currentDevice] model] hasPrefix:@"iPod touch"];
#endif
}


BOOL IsIPhone() {

#if TARGET_IPHONE_SIMULATOR
    return NO;
#else
    return [[[UIDevice currentDevice] model] hasPrefix:@"iPhone"];
#endif
}


BOOL IsSimulator() {
    
#if TARGET_IPHONE_SIMULATOR
    return YES;
#else
    return NO;
#endif
}


#define INDICATORS 300
static CGPoint *indicatorPoints     = nil;
static ccColor4B *indicatorColors   = nil;
static CocosNode* *indicatorSpaces  = nil;
static NSUInteger indicatorPosition = INDICATORS;

void IndicateInSpaceOf(CGPoint point, CocosNode *node) {
    
    if (indicatorPoints == nil) {
        indicatorPoints = calloc(INDICATORS, sizeof(CGPoint));
        indicatorColors = calloc(INDICATORS, sizeof(ccColor4B));
        indicatorSpaces = calloc(INDICATORS, sizeof(CocosNode*));
    }
    
    ++indicatorPosition;
    indicatorPoints[indicatorPosition % INDICATORS] = point;
    indicatorSpaces[indicatorPosition % INDICATORS] = node;
    for (NSUInteger i = 0; i <= indicatorPosition; ++i)
        if (i < indicatorPosition - INDICATORS)
            indicatorColors[i % INDICATORS] = ccc(0x000000ff);
        else {
            NSUInteger shade = 0xff - (0xff * (indicatorPosition - i) / INDICATORS);
            indicatorColors[i % INDICATORS].r = shade;
            indicatorColors[i % INDICATORS].g = shade;
            indicatorColors[i % INDICATORS].b = shade;
            indicatorColors[i % INDICATORS].a = 0xff;
        }
}


void DrawIndicators() {
    
    if (!indicatorPoints)
        return;
    
    CGPoint *points = malloc(sizeof(CGPoint) * INDICATORS);
    for (NSUInteger i = 0; i < INDICATORS; ++i)
        points[i] = [indicatorSpaces[i] convertToWorldSpace:indicatorPoints[i]];
    
    DrawPoints(points, indicatorColors, INDICATORS);
}


void DrawPointsAt(const CGPoint* points, const NSUInteger n, const ccColor4B color) {
    
    ccColor4B *colors = malloc(sizeof(ccColor4B) * n);
    for (NSUInteger i = 0; i < n; ++i)
        colors[i] = color;

    DrawPoints(points, colors, n);
}


void DrawPoints(const CGPoint* points, const ccColor4B* colors, const NSUInteger n) {

    // Define vertices and pass to GL.
    glVertexPointer(2, GL_FLOAT, 0, points);
	BOOL vWasEnabled = glIsEnabled(GL_VERTEX_ARRAY);
    if(!vWasEnabled)
        glEnableClientState(GL_VERTEX_ARRAY);
    
    // Define colors and pass to GL.
    BOOL cWasEnabled = YES; // keeps us from disabling it at the end.
    if(colors != nil) {
        glColorPointer(4, GL_UNSIGNED_BYTE, 0, colors);
        
        cWasEnabled = glIsEnabled(GL_COLOR_ARRAY);
        if(!cWasEnabled)
            glEnableClientState(GL_COLOR_ARRAY);
    }
    
    // Draw.
    glDrawArrays(GL_POINTS, 0, n);
    
    // Reset data source.
    if(!vWasEnabled)
        glDisableClientState(GL_VERTEX_ARRAY);
    if(!cWasEnabled)
        glDisableClientState(GL_COLOR_ARRAY);
}


void DrawLinesTo(const CGPoint from, const CGPoint* to, const NSUInteger n, const ccColor4B color, const CGFloat width) {
    
    CGPoint *points = malloc(sizeof(CGPoint) * (n + 1));
    points[0] = from;
    for(NSUInteger i = 0; i < n; ++i)
        points[i + 1] = to[i];

    glColor4ub(color.r, color.g, color.b, color.a);
    
    DrawLines(points, nil, n + 1, width);
    free(points);
}
    

void DrawLines(const CGPoint* points, const ccColor4B* longColors, const NSUInteger n, const CGFloat width) {
    
    // Define vertices and pass to GL.
	glVertexPointer(2, GL_FLOAT, 0, points);
	BOOL vWasEnabled = glIsEnabled(GL_VERTEX_ARRAY);
    if(!vWasEnabled)
        glEnableClientState(GL_VERTEX_ARRAY);
    
    // Define colors and pass to GL.
    BOOL cWasEnabled = YES; // keeps us from disabling it at the end.
    if(longColors != nil) {
        glColorPointer(4, GL_UNSIGNED_BYTE, 0, longColors);
        
        cWasEnabled = glIsEnabled(GL_COLOR_ARRAY);
        if(!cWasEnabled)
            glEnableClientState(GL_COLOR_ARRAY);
    }
    
    // Draw.
    if(width && width != 1)
        glLineWidth(width);
	glDrawArrays(GL_LINE_STRIP, 0, n);
    if(width && width != 1)
        glLineWidth(1.0f);
    
    // Reset data source.
    if(!vWasEnabled)
        glDisableClientState(GL_VERTEX_ARRAY);
    if(!cWasEnabled)
        glDisableClientState(GL_COLOR_ARRAY);
}


void DrawBoxFrom(const CGPoint from, const CGPoint to, const ccColor4B fromColor, const ccColor4B toColor) {
    
    // Define vertices and pass to GL.
    const GLfloat vertices[4 * 2] = {
        from.x, from.y,
        to.x,   from.y,
        from.x, to.y,
        to.x,   to.y,
    };
	BOOL vWasEnabled = glIsEnabled(GL_VERTEX_ARRAY);
    if(!vWasEnabled)
        glEnableClientState(GL_VERTEX_ARRAY);
    glVertexPointer(2, GL_FLOAT, 0, vertices);

    // Define colors and pass to GL.
    BOOL cWasEnabled = glIsEnabled(GL_COLOR_ARRAY);
    if(!cWasEnabled)
        glEnableClientState(GL_COLOR_ARRAY);
    const ccColor4B colors[4] = {
        fromColor, fromColor,
        toColor, toColor,
    };
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, colors);
    
    // Draw.
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    // Untoggle state.
    if(!vWasEnabled)
        glDisableClientState(GL_VERTEX_ARRAY);
    if(!cWasEnabled)
        glDisableClientState(GL_COLOR_ARRAY);
}


void DrawBorderFrom(const CGPoint from, const CGPoint to, const ccColor4B color, const CGFloat width) {
    
    // Define vertices and pass to GL.
	BOOL vWasEnabled = glIsEnabled(GL_VERTEX_ARRAY);
    if(!vWasEnabled)
        glEnableClientState(GL_VERTEX_ARRAY);
    const GLfloat vertices[4 * 2] = {
        from.x, from.y,
        to.x,   from.y,
        to.x,   to.y,
        from.x, to.y,
    };
	glVertexPointer(2, GL_FLOAT, 0, vertices);
    
    // Define colors and pass to GL.
    BOOL cWasEnabled = glIsEnabled(GL_COLOR_ARRAY);
    if(!cWasEnabled)
        glEnableClientState(GL_COLOR_ARRAY);
    const ccColor4B colors[4] = { color, color, color, color };
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, colors);
    
	// Draw.
    if(width && width != 1)
        glLineWidth(width);
	glDrawArrays(GL_LINE_LOOP, 0, 4);
    if(width && width != 1)
        glLineWidth(1.0f);
    
    // Untoggle state.
    if(!vWasEnabled)
        glDisableClientState(GL_VERTEX_ARRAY);
    if(!cWasEnabled)
        glDisableClientState(GL_COLOR_ARRAY);
}
