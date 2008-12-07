//
//  SkyLayer.h
//  Gorillas
//
//  Created by Maarten Billemont on 26/10/08.
//  Copyright 2008 Lin.k. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Resettable.h"
#import "GorillasConfig.h"


@interface SkyLayer : Layer <CocosNodeSize, Resettable> {

    CGSize contentSize;
    
    GLfloat *stars;
    NSUInteger starCount;
}

@property (readonly) CGSize contentSize;


@end
