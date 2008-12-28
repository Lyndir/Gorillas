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
//  Utility.h
//  Gorillas
//
//  Created by Maarten Billemont on 26/11/08.
//  Copyright 2008, lhunath (Maarten Billemont). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"


@interface Utility : NSObject {

}

+(NSString *) rpad:(NSString *)string to:(NSUInteger)l;
+(NSString *) lpad:(NSString *)string to:(NSUInteger)l;
+(NSString *) appendOrdinalPrefixFor:(int)number to:(NSString *)prefix;

+(void) drawPointAt:(cpVect)point;
+(void) drawPointsAt:(const cpVect *)points count:(int)count;
+(void) drawPointAt:(cpVect)point color:(long)color;
+(void) drawPointsAt:(const cpVect *)points count:(int)count color:(long)color;


+(void) drawLineFrom:(cpVect)from by:(cpVect)by;
+(void) drawLinesFrom:(cpVect)from by:(const cpVect *)by count:(int)count;
+(void) drawLineFrom:(cpVect)from to:(cpVect)to;
+(void) drawLinesFrom:(cpVect)from to:(const cpVect *)to count:(int)count;
+(void) drawLineFrom:(cpVect)from by:(cpVect)by color:(long)color;
+(void) drawLinesFrom:(cpVect)from by:(const cpVect *)by count:(int)count color:(long)color;
+(void) drawLineFrom:(cpVect)from to:(cpVect)to color:(long)color;
+(void) drawLinesFrom:(cpVect)from to:(const cpVect *)to count:(int)count color:(long)color;
+(void) drawLineFrom:(cpVect)from by:(cpVect)by color:(long)color width:(float)width;
+(void) drawLinesFrom:(cpVect)from by:(const cpVect *)by count:(int)count color:(long)color width:(float)width;
+(void) drawLineFrom:(cpVect)from to:(cpVect)to color:(long)color width:(float)width;
+(void) drawLinesFrom:(cpVect)from to:(const cpVect *)to count:(int)count color:(long)color width:(float)width;
+(void) drawLines:(const cpVect *)points colors:(const long *)colors count:(int)n width:(float)width;


+(void) drawBoxFrom:(cpVect)from to:(cpVect)to;
+(void) drawBoxFrom:(cpVect)from size:(cpVect)to;
+(void) drawBoxFrom:(cpVect)from to:(cpVect)to color:(long)color;
+(void) drawBoxFrom:(cpVect)from size:(cpVect)to color:(long)color;

+(void) drawBorderFrom:(cpVect)from to:(cpVect)to;
+(void) drawBorderFrom:(cpVect)from size:(cpVect)size;
+(void) drawBorderFrom:(cpVect)from size:(cpVect)size color:(long)color width:(float)width;
+(void) drawBorderFrom:(cpVect)from to:(cpVect)to color:(long)color width:(float)width;
    
    
@end
