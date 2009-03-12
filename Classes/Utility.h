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
//  Utility.h
//  Gorillas
//
//  Created by Maarten Billemont on 26/11/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//



// Fixed Type Vector
typedef struct iVect{
	GLfixed x,y;
} iVect;

static inline GLfixed
ftoi(const GLfloat f)
{
	return (GLfixed)f * 65536;
}

static inline iVect
cpvtoiv(const cpVect cpv)
{
	iVect v = { ftoi(cpv.x), ftoi(cpv.y) };
	return v;
}

static inline iVect
iv(const GLfixed x, const GLfixed y)
{
	iVect v = {x * 65536, y * 65536};
	return v;
}


// Color Struct
static inline ccColorB
ccc(const long c)
{
    GLubyte *components = (GLubyte *)&c;
	ccColorB cc = { components[3], components[2], components[1], components[0] };
	return cc;
}


// Vertex: Position & Color 
typedef struct _Vertex {
	cpVect p;
    ccColorB c;
} Vertex;

static inline Vertex
ivc(const cpVect p, const long c)
{
    Vertex v;
    v.p = p; //cpvtoiv(p);
    v.c = ccc(c);
	return v;
}

static inline Vertex
ivcf(const cpFloat x, const cpFloat y, const long c)
{
    Vertex v;
    v.p = cpv(x, y);
    v.c = ccc(c);
	return v;
}


NSString* rpad(NSString* string, NSUInteger l);
NSString* lpad(NSString* string, NSUInteger l);
NSString* appendOrdinalPrefix(int number, NSString* prefix);

void drawPointsAt(const cpVect* points, int count, long color);

void drawLinesTo(cpVect from, const cpVect* to, int count, long color, float width);
void drawLines(const cpVect* points, const long* colors, int n, float width);

void drawBoxFrom(cpVect from, cpVect to, long fromColor, long toColor);

void drawBorderFrom(cpVect from, cpVect to, long color, float width);
