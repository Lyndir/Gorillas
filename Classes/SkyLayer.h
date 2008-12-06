//
//  SkyLayer.h
//  Gorillas
//
//  Created by Maarten Billemont on 26/10/08.
//  Copyright 2008 Lin.k. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResettableLayer.h"
#import "GorillasConfig.h"


@interface SkyLayer : ResettableLayer <CocosNodeSize> {

    CGSize contentSize;
    
    GLfloat *stars;
    NSUInteger starCount;
}

@property (readonly) CGSize contentSize;


@end
