//
//  ExplosionAnimationLayer.h
//  Gorillas
//
//  Created by Maarten Billemont on 30/11/08.
//  Copyright 2008 Lin.k. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"


@interface ExplosionAnimationLayer : Sprite {

    Animation *explosion;
}

+(ExplosionAnimationLayer *) get;


@end
