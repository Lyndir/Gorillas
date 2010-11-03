//
//  MovingTo.h
//  Gorillas
//
//  Created by Maarten Billemont on 03/11/10.
//  Copyright 2010 lhunath (Maarten Billemont). All rights reserved.
//

#import "cocos2d.h"


@interface MovingTo : CCMoveTo {

    ccTime stepDuration;
}

- (void)updatePosition:(CGPoint)pos;

@end
