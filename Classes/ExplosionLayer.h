//
//  Explosion.h
//  Gorillas
//
//  Created by Maarten Billemont on 04/11/08.
//  Copyright 2008 Lin.k. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"


@interface ExplosionLayer : Sprite {
    
}

-(BOOL) hitsExplosion: (cpVect)pos;

@property (readonly) float width;
@property (readonly) float height;

@end
