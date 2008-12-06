//
//  Utility.h
//  Gorillas
//
//  Created by Maarten Billemont on 26/11/08.
//  Copyright 2008 Lin.k. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"


@interface Utility : NSObject {

}

+(void) drawPointAt:(cpVect)point;
+(void) drawPointAt:(GLfloat)x :(GLfloat)y;
+(void) drawPointAt:(cpVect)point color:(long)color;
+(void) drawPointAt:(GLfloat)x :(GLfloat)y color:(long) color;

+(void) drawLineFrom:(cpVect)from to:(cpVect)to;
+(void) drawLineFrom:(cpVect)from by:(cpVect)by;
+(void) drawLineFrom:(GLfloat)x0 :(GLfloat)y0 to:(GLfloat)x1 :(GLfloat)y1;
+(void) drawLineFrom:(cpVect)from to:(cpVect)to color:(long)color;
+(void) drawLineFrom:(cpVect)from by:(cpVect)by color:(long)color;
+(void) drawLineFrom:(GLfloat)x0 :(GLfloat)y0 to:(GLfloat)x1 :(GLfloat)y1 color:(long)color;
+(void) drawLineFrom:(cpVect)from to:(cpVect)to color:(long)color width:(float)width;
+(void) drawLineFrom:(cpVect)from by:(cpVect)by color:(long)color width:(float)width;
+(void) drawLineFrom:(GLfloat)x0 :(GLfloat)y0 to:(GLfloat)x1 :(GLfloat)y1 color:(long)color width:(float)width;

+(void) drawBoxFrom:(cpVect)from to:(cpVect)to;
+(void) drawBoxFrom:(cpVect)from size:(cpVect)to;
+(void) drawBoxFrom:(GLfloat)x0 :(GLfloat)y0 to:(GLfloat)x1 :(GLfloat)y1;
+(void) drawBoxFrom:(cpVect)from to:(cpVect)to color:(long)color;
+(void) drawBoxFrom:(cpVect)from size:(cpVect)to color:(long)color;
+(void) drawBoxFrom:(GLfloat)x0 :(GLfloat)y0 to:(GLfloat)x1 :(GLfloat)y1 color:(long)color;

@end
