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
//  Utility.m
//  Gorillas
//
//  Created by Maarten Billemont on 26/11/08.
//  Copyright 2008, lhunath (Maarten Billemont). All rights reserved.
//

#import "Utility.h"


@implementation Utility


+(NSString *) rpad:(NSString *)string to:(NSUInteger)l {
    
    NSMutableString *newString = [NSMutableString stringWithCapacity:l];
    [newString setString:string];
    while ([newString length] < l)
        [newString appendString:@" "];
    
    return newString;
}


+(NSString *) lpad:(NSString *)string to:(NSUInteger)l {
    
    NSMutableString *newString = [NSMutableString stringWithCapacity:l];
    while ([newString length] + [string length] < l)
        [newString appendString:@" "];
    [newString appendString:string];
    
    return newString;
}


+(NSString *) appendOrdinalPrefixFor:(int)number to:(NSString *)prefix {
    
    NSString *suffix = @"th";
    if(number % 10 == 1 && number != 11)
        suffix = @"st";
    else if(number % 10 == 2 && number != 12)
        suffix = @"nd";
    else if(number % 10 == 3 && number != 13)
        suffix = @"rd";
    
    return [NSString stringWithFormat:@"%@%@", prefix, suffix];
}


+(void) drawPointAt:(cpVect)point {
    
    const cpVect points[] = { point };
    [self drawPointsAt:points count:1];
}


+(void) drawPointsAt:(cpVect *)points count:(int)count {
    
    [self drawPointsAt:points count:count color:0xffffffff];
}


+(void) drawPointAt:(cpVect)point color:(long) color {

    const cpVect points[] = { point };
    [self drawPointsAt:points count:1 color:color];
}


+(void) drawPointsAt:(cpVect *)points count:(int)n color:(long) color {
    
    GLfloat *vertices = malloc(sizeof(GLfloat) * 2 * (n + 1));
    for(int i = 0; i < n; ++i) {
        vertices[(i + 1) * 2 + 0] = points[i].x;
        vertices[(i + 1) * 2 + 1] = points[i].y;
    }
    
    const GLubyte *colorBytes = (GLubyte *)&color;
    GLubyte *colors = malloc(sizeof(GLubyte) * 4 * (n + 1));
    for(int i = 0; i < n + 1; ++i) {
        colors[i * 4 + 0] = colorBytes[3];
        colors[i * 4 + 1] = colorBytes[2];
        colors[i * 4 + 2] = colorBytes[1];
        colors[i * 4 + 3] = colorBytes[0];
    }
    
    glVertexPointer(2, GL_FLOAT, 0, points);
    glEnableClientState(GL_VERTEX_ARRAY);
	glColorPointer(4, GL_UNSIGNED_BYTE, 0, colors);
	glEnableClientState(GL_COLOR_ARRAY);
    
    glDrawArrays(GL_POINTS, 0, n);
    
    glDisableClientState(GL_VERTEX_ARRAY);
    
    free(vertices);
    free(colors);
}


+(void) drawLineFrom:(cpVect)from by:(cpVect)by {
    
    const cpVect _by[] = { by };
    [Utility drawLinesFrom:from by:_by count:1];
}


+(void) drawLinesFrom:(cpVect)from by:(const cpVect *)by count:(int)count {

    [Utility drawLinesFrom:from by:by count:count color:0xffffffff];
}


+(void) drawLineFrom:(cpVect)from to:(cpVect)to {
    
    const cpVect _to[] = { to };
    [Utility drawLinesFrom:from to:_to count:1];
}


+(void) drawLinesFrom:(cpVect)from to:(const cpVect *)to count:(int)count {
    
    [Utility drawLinesFrom:from to:to count:count color:0xffffffff];
}


+(void) drawLineFrom:(cpVect)from by:(cpVect)by color:(long)color {
    
    const cpVect _by[] = { by };
    [Utility drawLinesFrom:from by:_by count:1 color:color];
}


+(void) drawLinesFrom:(cpVect)from by:(const cpVect *)by count:(int)count color:(long)color {
    
    [Utility drawLinesFrom:from by:by count:count color:color width:1];
}


+(void) drawLineFrom:(cpVect)from to:(cpVect)to color:(long)color {

    const cpVect _to[] = { to };
    [Utility drawLinesFrom:from to:_to count:1 color:color];
}


+(void) drawLinesFrom:(cpVect)from to:(const cpVect *)to count:(int)count color:(long)color {
    
    [Utility drawLinesFrom:from to:to count:count color:color width:1];
}


+(void) drawLineFrom:(cpVect)from by:(cpVect)by color:(long)color width:(float)width {

    const cpVect _by[] = { by };
    [Utility drawLinesFrom:from by:_by count:1 color:color width:width];
}


+(void) drawLinesFrom:(cpVect)from by:(const cpVect *)by count:(int)n color:(long)color width:(float)width {

    cpVect *to = malloc(sizeof(cpVect) * n);
    cpFloat fx = from.x, fy = from.y;
    for(int i = 0; i < n; ++i) {
        fx += by[i].x;
        fy += by[i].y;
        
        to[i] = cpv(fx, fy);
    }
    
    [Utility drawLinesFrom:from to:to count:n color:color width:width];
    free(to);
}


+(void) drawLineFrom:(cpVect)from to:(cpVect)to color:(long)color width:(float)width {

    const cpVect _to[] = { to };
    [Utility drawLinesFrom:from to:_to count:1 color:color width:width];
}


+(void) drawLinesFrom:(cpVect)from to:(const cpVect *)to count:(int)n color:(long)color width:(float)width {
    
    cpVect *points = malloc(sizeof(cpVect) * (n + 1));
    long *colors = malloc(sizeof(long) * (n + 1));
    points[0] = from;
    colors[0] = color;
    for(int i = 1; i < n + 1; ++i) {
        points[i] = to[i - 1];
        colors[i] = color;
    }
    
    [Utility drawLines:points colors:colors count:n + 1 width:width];

    free(points);
    free(colors);
}


+(void) drawLines:(const cpVect *)points colors:(const long *)longColors count:(int)n width:(float)width {
    
    GLfloat *vertices = malloc(sizeof(GLfloat) * 2 * n);
    for(int i = 0; i < n; ++i) {
        vertices[i * 2 + 0] = points[i].x;
        vertices[i * 2 + 1] = points[i].y;
    }

    GLubyte *colors = malloc(sizeof(GLubyte) * 4 * n);
    for(int i = 0; i < n; ++i) {
        const GLubyte *colorBytes = (GLubyte *)&longColors[i];
        colors[i * 4 + 0] = colorBytes[3];
        colors[i * 4 + 1] = colorBytes[2];
        colors[i * 4 + 2] = colorBytes[1];
        colors[i * 4 + 3] = colorBytes[0];
    }
    
    // Tell OpenGL about our data.
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glEnableClientState(GL_VERTEX_ARRAY);
	glColorPointer(4, GL_UNSIGNED_BYTE, 0, colors);
	glEnableClientState(GL_COLOR_ARRAY);
	
    glLineWidth(width);
	glDrawArrays(GL_LINE_STRIP, 0, n);
    glLineWidth(1.0f);
    
    // Reset data source.
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
    
    free(vertices);
    free(colors);
}


+(void) drawBoxFrom:(cpVect)from to:(cpVect)to {
    
    [self drawBoxFrom:from to:to color:0xffffffff];
}


+(void) drawBoxFrom:(cpVect)from size:(cpVect)size {
    
    [self drawBoxFrom:from size:size color:0xffffffff];
}


+(void) drawBoxFrom:(cpVect)from size:(cpVect)size color:(long)color {

    [self drawBoxFrom:from to:cpv(from.x + size.x, from.y + size.y) color:color];
}


+(void) drawBoxFrom:(cpVect)from to:(cpVect)to color:(long)color {

    [self drawBoxFrom:from to:to colorFrom:color to:color];
}


+(void) drawBoxFrom:(cpVect)from to:(cpVect)to colorFrom:(long)fromColor to:(long)toColor {

    const GLfloat vertices[4 * 2] = {
        from.x, from.y,
        to.x,   from.y,
        from.x, to.y,
        to.x,   to.y,
    };
    const GLubyte *fromColorBytes = (GLubyte *)&fromColor;
    const GLubyte *toColorBytes = (GLubyte *)&toColor;
    const GLubyte colors[4 * 4] = {
        fromColorBytes[3], fromColorBytes[2], fromColorBytes[1], fromColorBytes[0],
        fromColorBytes[3], fromColorBytes[2], fromColorBytes[1], fromColorBytes[0],
        toColorBytes[3], toColorBytes[2], toColorBytes[1], toColorBytes[0],
        toColorBytes[3], toColorBytes[2], toColorBytes[1], toColorBytes[0],
    };
    
    // Tell OpenGL about our data.
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glEnableClientState(GL_VERTEX_ARRAY);
	glColorPointer(4, GL_UNSIGNED_BYTE, 0, colors);
	glEnableClientState(GL_COLOR_ARRAY);
	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    // Reset data source.
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
}


+(void) drawBorderFrom:(cpVect)from to:(cpVect)to {
    
    [self drawBorderFrom:from to:to color:0xffffffff width:1.0f];
}


+(void) drawBorderFrom:(cpVect)from size:(cpVect)size {
    
    [self drawBorderFrom:from to:cpv(from.x + size.x, from.y + size.y)];
}


+(void) drawBorderFrom:(cpVect)from size:(cpVect)size color:(long)color width:(float)width {
    
    [self drawBorderFrom:from to:cpv(from.x + size.x, from.y + size.y) color:color width:width];
}


+(void) drawBorderFrom:(cpVect)from to:(cpVect)to color:(long)color width:(float)width {

    const GLfloat vertices[4 * 2] = {
        from.x, from.y,
        to.x,   from.y,
        to.x,   to.y,
        from.x, to.y,
    };
    const GLubyte *colorBytes = (GLubyte *)&color;
    const GLubyte colors[4 * 4] = {
        colorBytes[3], colorBytes[2], colorBytes[1], colorBytes[0],
        colorBytes[3], colorBytes[2], colorBytes[1], colorBytes[0],
        colorBytes[3], colorBytes[2], colorBytes[1], colorBytes[0],
        colorBytes[3], colorBytes[2], colorBytes[1], colorBytes[0],
    };
    
    // Tell OpenGL about our data.
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glEnableClientState(GL_VERTEX_ARRAY);
	glColorPointer(4, GL_UNSIGNED_BYTE, 0, colors);
	glEnableClientState(GL_COLOR_ARRAY);
	
    glLineWidth(width);
	glDrawArrays(GL_LINE_LOOP, 0, 4);
    glLineWidth(1.0f);
    
    // Reset data source.
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
}


@end
