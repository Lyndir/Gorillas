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
//  Utility.h
//  Gorillas
//
//  Created by Maarten Billemont on 26/11/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//


// Color Struct
static inline ccColor4B
ccc(const long c)
{
    GLubyte *components = (GLubyte *)&c;
	ccColor4B cc = { components[3], components[2], components[1], components[0] };
	return cc;
}


// Vertex: Position & Color 
typedef struct _Vertex {
	CGPoint p;
    ccColor4B c;
} Vertex;

static inline Vertex
ivc(const CGPoint p, const long c)
{
    Vertex v;
    v.p = p; //cpvtoiv(p);
    v.c = ccc(c);
	return v;
}

static inline Vertex
ivcf(const CGFloat x, const CGFloat y, const long c)
{
    Vertex v;
    v.p = ccp(x, y);
    v.c = ccc(c);
	return v;
}


NSString* rpad(const NSString* string, NSUInteger l);
NSString* lpad(const NSString* string, NSUInteger l);
NSString* appendOrdinalPrefix(const NSInteger number, const NSString* prefix);

BOOL IsIPod();
BOOL IsIPhone();
BOOL IsSimulator();

void drawPointsAt(const CGPoint* points, const NSUInteger count, const ccColor4B color);

void drawLinesTo(const CGPoint from, const CGPoint* to, const NSUInteger count, const ccColor4B color, const CGFloat width);
void drawLines(const CGPoint* points, const ccColor4B* colors, const NSUInteger n, const CGFloat width);

void drawBoxFrom(const CGPoint from, const CGPoint to, const ccColor4B fromColor, const ccColor4B toColor);

void drawBorderFrom(const CGPoint from, const CGPoint to, const ccColor4B color, const CGFloat width);
