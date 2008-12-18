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
    int     padding;
    float   innerRatio;
    long    color;
}

@property (readwrite) GLubyte   opacity;
@property (readwrite) CGSize    contentSize;
@property (readwrite) int       padding;
@property (readwrite) float     innerRatio;
@property (readwrite) long      color;

@end
