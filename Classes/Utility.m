//
//  Utility.m
//  Gorillas
//
//  Created by Maarten Billemont on 26/11/08.
//  Copyright 2008 Lin.k. All rights reserved.
//

#import "Utility.h"


@implementation Utility


+(void) drawPointAt:(cpVect)point {
    
    [self drawPointAt:point.x :point.y];
}


+(void) drawPointAt:(GLfloat)x :(GLfloat)y {
    
    [self drawPointAt:x :y color:0xffffffff];
}


+(void) drawPointAt:(cpVect)point color:(long) color {

    [self drawPointAt:point.x :point.y color:color];
}


+(void) drawPointAt:(GLfloat)x :(GLfloat)y color:(long) color {
    
    const GLfloat point[1 * 2] = { x, y };
    const GLubyte *colorBytes = [Utility colorToBytes:color];
    
    glVertexPointer(2, GL_FLOAT, 0, point);
    glEnableClientState(GL_VERTEX_ARRAY);
    glColor4f(colorBytes[0], colorBytes[1], colorBytes[2], colorBytes[3]);
    
    glDrawArrays(GL_POINTS, 0, 1);
    
    glDisableClientState(GL_VERTEX_ARRAY);
}


+(void) drawLineFrom:(cpVect)from to:(cpVect)to {

    [self drawLineFrom:from.x :from.y to:to.x :to.y];
}


+(void) drawLineFrom:(cpVect)from by:(cpVect)by {
    
    [self drawLineFrom:from.x :from.y to:from.x + by.x :from.y + by.y];
}


+(void) drawLineFrom:(GLfloat)x0 :(GLfloat)y0 to:(GLfloat)x1 :(GLfloat)y1 {
    
    [self drawLineFrom:x0 :y0 to:x1 :y1 color:0xffffffff];
}


+(void) drawLineFrom:(cpVect)from to:(cpVect)to color:(long)color {
    
    [self drawLineFrom:from.x :from.y to:to.x :to.y color:color];
}


+(void) drawLineFrom:(cpVect)from by:(cpVect)by color:(long)color {
    
    [self drawLineFrom:from.x :from.y to:from.x + by.x :from.y + by.y color:color];
}


+(void) drawLineFrom:(GLfloat)x0 :(GLfloat)y0 to:(GLfloat)x1 :(GLfloat)y1 color:(long)color {
    
    [self drawLineFrom:x0 :y0 to:x1 :y1 color:color width:1];
}


+(void) drawLineFrom:(cpVect)from to:(cpVect)to color:(long)color width:(float)width {
    
    [self drawLineFrom:from.x :from.y to:to.x :to.y color:color width:width];
}


+(void) drawLineFrom:(cpVect)from by:(cpVect)by color:(long)color width:(float)width {
    
    [self drawLineFrom:from.x :from.y to:from.x + by.x :from.y + by.y color:color width:width];
}


+(void) drawLineFrom:(GLfloat)x0 :(GLfloat)y0 to:(GLfloat)x1 :(GLfloat)y1 color:(long)color width:(float)width {
    
    const GLfloat vertices[4 * 2] = {
        x0, y0,
        x1, y1,
    };
    const GLubyte *colorBytes = [Utility colorToBytes:color];
    const GLubyte colors[4 * 4] = {
        colorBytes[0], colorBytes[1], colorBytes[2], colorBytes[3],
        colorBytes[0], colorBytes[1], colorBytes[2], colorBytes[3],
    };
    
    // Tell OpenGL about our data.
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glEnableClientState(GL_VERTEX_ARRAY);
	glColorPointer(4, GL_UNSIGNED_BYTE, 0, colors);
	glEnableClientState(GL_COLOR_ARRAY);
	
    glLineWidth(width);
	glDrawArrays(GL_LINES, 0, 2);
    glLineWidth(1.0f);
    
    // Reset data source.
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
}


+(void) drawBoxFrom:(cpVect)from to:(cpVect)to {
    
    [self drawBoxFrom:from.x :from.y to:to.x :to.y];
}


+(void) drawBoxFrom:(cpVect)from size:(cpVect)size {
    
    [self drawBoxFrom:from to:cpv(from.x + size.x, from.y + size.y)];
}


+(void) drawBoxFrom:(GLfloat)x0 :(GLfloat)y0 to:(GLfloat)x1 :(GLfloat)y1 {
    
    [self drawBoxFrom:x0 :y0 to:x1 :y1 color:0xffffffff];
}


+(void) drawBoxFrom:(cpVect)from size:(cpVect)size color:(long)color {

    [self drawBoxFrom:from to:cpv(from.x + size.x, from.y + size.y) color:color];
}


+(void) drawBoxFrom:(cpVect)from to:(cpVect)to color:(long)color {
    
    [self drawBoxFrom:from.x :from.y to:to.x :to.y color:color];
}


+(void) drawBoxFrom:(GLfloat)x0 :(GLfloat)y0 to:(GLfloat)x1 :(GLfloat)y1 color:(long)color {
    
    const GLfloat vertices[4 * 4] = {
        x0, y0,
        x1, y0,
        x0, y1,
        x1, y1,
    };
    const GLubyte *colorBytes = [Utility colorToBytes:color];
    const GLubyte colors[4 * 4] = {
        colorBytes[0], colorBytes[1], colorBytes[2], colorBytes[3],
        colorBytes[0], colorBytes[1], colorBytes[2], colorBytes[3],
        colorBytes[0], colorBytes[1], colorBytes[2], colorBytes[3],
        colorBytes[0], colorBytes[1], colorBytes[2], colorBytes[3],
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


+(const GLubyte *) colorToBytes: (long)color {
    
    GLubyte *bytes = malloc(sizeof(GLubyte) * 4);
    bytes[0] = color >> 24 & 0xff;
    bytes[1] = color >> 16 & 0xff;
    bytes[2] = color >> 8  & 0xff;
    bytes[3] = color >> 0  & 0xff;
    
    return bytes;
}


@end
