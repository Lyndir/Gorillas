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


@interface BuildingLayer : ResettableLayer <CocosNodeSize> {
    
    @private
    long buildingColor;

    CGSize contentSize;
    
    GLfloat *windows;
    GLubyte *colors;
    int windowCount;
}

@property (readonly) CGSize contentSize;

-(void) reset;

@end
