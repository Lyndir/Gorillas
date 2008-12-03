//
//  Explosion.m
//  Gorillas
//
//  Created by Maarten Billemont on 04/11/08.
//  Copyright 2008 Lin.k. All rights reserved.
//

#import "ExplosionLayer.h"
#import "ExplosionAnimationLayer.h"


@implementation ExplosionLayer


-(id) init {
    
    if(!(self = [super initWithFile:@"hole.png"]))
        return self;
    
    [self add:[ExplosionAnimationLayer get] z:-9];
    
    return self;
}


-(BOOL) hitsExplosion: (cpVect)pos {
    
    return ((position.x - pos.x) * (position.x - pos.x) +
            (position.y - pos.y) * (position.y - pos.y) ) < ([self width] * [self width]) / 9;
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


-(float) width {
    
    return [self contentSize].width;
}


-(float) height {
    
    return [self contentSize].height;
}


@end
