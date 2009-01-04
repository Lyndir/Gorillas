//
//  HoleLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 04/01/09.
//  Copyright 2009 Lin.k. All rights reserved.
//

#import "HoleLayer.h"


@implementation HoleLayer


-(id) init {
    
    if(!(self = [super initWithFile:@"hole.png"]))
        return self;
    
    return self;
}


-(void) draw {
    
    // Blend our transarent white with DST.  If SRC, make DST transparent, hide original DST.
    glColorMask(GL_FALSE, GL_FALSE, GL_FALSE, GL_TRUE);
    glBlendFunc(GL_ZERO, GL_SRC_ALPHA);
    
    [super draw];
    
    // Reset blend & data source.
    glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}


@end
