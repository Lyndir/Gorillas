//
//  FancyLayer.h
//  Gorillas
//
//  Created by Maarten Billemont on 18/12/08.
//  Copyright 2008 Lin.k. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"


@interface FancyLayer : Layer <CocosNodeOpacity, CocosNodeSize> {

    GLubyte opacity;
    CGSize  contentSize;
    float   outerPadding;
    float   padding;
    float   innerRatio;
    long    color;
    
    GLfloat *vertices;
    GLubyte *colors;
}

-(void) update;

@property (readwrite) GLubyte   opacity;
@property (readwrite) CGSize    contentSize;
@property (readwrite) float     outerPadding;
@property (readwrite) float     padding;
@property (readwrite) float     innerRatio;
@property (readwrite) long      color;

@end
