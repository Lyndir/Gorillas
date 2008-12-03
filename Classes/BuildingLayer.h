//
//  BuildingLayer.h
//  Gorillas
//
//  Created by Maarten Billemont on 25/10/08.
//  Copyright 2008 Lin.k. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "ResettableLayer.h"
#import "GorillasConfig.h"


@interface BuildingLayer : ResettableLayer {
    
    @private
    long buildingColor;

    float width;
    float height;
    
    GLfloat **windows;
    GLubyte **colors;
    int windowCount;
}

-(void) reset;

@property (readonly) float width;
@property (readonly) float height;

@end
