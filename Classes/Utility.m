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




NSString* rpad(NSString* string, NSUInteger l) {
    
    NSMutableString *newString = [NSMutableString stringWithCapacity:l];
    [newString setString:string];
    while ([newString length] < l)
        [newString appendString:@" "];
    
    return newString;
}


NSString* lpad(NSString* string, NSUInteger l) {
    
    NSMutableString *newString = [NSMutableString stringWithCapacity:l];
    while ([newString length] + [string length] < l)
        [newString appendString:@" "];
    [newString appendString:string];
    
    return newString;
}


NSString* appendOrdinalPrefix(int number, NSString* prefix) {
    
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

    return [[[UIDevice currentDevice] model] hasPrefix:@"iPod touch"];
}


BOOL IsIPhone() {
    
    return [[[UIDevice currentDevice] model] hasPrefix:@"iPhone"];
}


void drawPointsAt(const CGPoint* points, int n, long color) {
    
    // Define vertices and pass to GL.
    glVertexPointer(2, GL_FLOAT, 0, points);
	BOOL vWasEnabled = glIsEnabled(GL_VERTEX_ARRAY);
    if(!vWasEnabled)
        glEnableClientState(GL_VERTEX_ARRAY);
    
    // Define colors and pass to GL.
    GLubyte *colorBytes = (GLubyte *)&color;
    glColor4ub(colorBytes[3], colorBytes[2], colorBytes[1], colorBytes[0]);
    
    // Draw.
    glDrawArrays(GL_POINTS, 0, n);
    
    // Reset data source.
    if(!vWasEnabled)
        glDisableClientState(GL_VERTEX_ARRAY);
}


void drawLinesTo(CGPoint from, const CGPoint* to, int n, long color, float width) {
    
    CGPoint *points = malloc(sizeof(CGPoint) * (n + 1));
    points[0] = from;
    for(int i = 0; i < n; ++i)
        points[i + 1] = to[i];

    GLubyte *colorBytes = (GLubyte *)&color;
    glColor4ub(colorBytes[3], colorBytes[2], colorBytes[1], colorBytes[0]);
    
    drawLines(points, nil, n + 1, width);
    free(points);
}
    

void drawLines(const CGPoint* points, const long* longColors, int n, float width) {
    
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


void drawBoxFrom(CGPoint from, CGPoint to, long fromColor, long toColor) {
    
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
    BOOL cWasEnabled = YES; // keeps us from disabling it at the end.
    const GLubyte *fromColorBytes = (GLubyte *)&fromColor;
    if(fromColor != toColor) {
        const GLubyte *toColorBytes = (GLubyte *)&toColor;
        const GLubyte colors[4 * 4] = {
            fromColorBytes[3], fromColorBytes[2], fromColorBytes[1], fromColorBytes[0],
            fromColorBytes[3], fromColorBytes[2], fromColorBytes[1], fromColorBytes[0],
            toColorBytes[3], toColorBytes[2], toColorBytes[1], toColorBytes[0],
            toColorBytes[3], toColorBytes[2], toColorBytes[1], toColorBytes[0],
        };
        
        glColorPointer(4, GL_UNSIGNED_BYTE, 0, colors);
        cWasEnabled = glIsEnabled(GL_COLOR_ARRAY);
        if(!cWasEnabled)
            glEnableClientState(GL_COLOR_ARRAY);
    } else
        glColor4ub(fromColorBytes[3], fromColorBytes[2], fromColorBytes[1], fromColorBytes[0]);

    // Draw.
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    // Untoggle state.
    if(!vWasEnabled)
        glDisableClientState(GL_VERTEX_ARRAY);
    if(!cWasEnabled)
        glDisableClientState(GL_COLOR_ARRAY);
}


void drawBorderFrom(CGPoint from, CGPoint to, long color, float width) {
    
    // Define vertices and pass to GL.
    const GLfloat vertices[4 * 2] = {
        from.x, from.y,
        to.x,   from.y,
        to.x,   to.y,
        from.x, to.y,
    };
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	BOOL vWasEnabled = glIsEnabled(GL_VERTEX_ARRAY);
    if(!vWasEnabled)
        glEnableClientState(GL_VERTEX_ARRAY);
    
    // Define colors and pass to GL.
    const GLubyte *colorBytes = (GLubyte *)&color;
    glColor4ub(colorBytes[3], colorBytes[2], colorBytes[1], colorBytes[0]);
    
	// Draw.
    if(width && width != 1)
        glLineWidth(width);
	glDrawArrays(GL_LINE_LOOP, 0, 4);
    if(width && width != 1)
        glLineWidth(1.0f);
    
    // Untoggle state.
    if(!vWasEnabled)
        glDisableClientState(GL_VERTEX_ARRAY);
}
