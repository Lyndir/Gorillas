//
//  BuildingLayer.h
//  Gorillas
//
//  Created by Maarten Billemont on 25/10/08.
//  Copyright 2008 Lin.k. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "Resettable.h"
#import "GorillasConfig.h"


@interface BuildingLayer : Layer <CocosNodeSize, Resettable> {
    
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
