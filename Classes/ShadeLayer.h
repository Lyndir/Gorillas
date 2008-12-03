//
//  MenuLayer.h
//  Gorillas
//
//  Created by Maarten Billemont on 26/10/08.
//  Copyright 2008 Lin.k. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "GorillasConfig.h"


@interface ShadeLayer : ColorLayer {

    @private
    BOOL showing;
}

-(void) reveal;
-(void) dismiss;

-(void) ready;
-(void) gone;

@property (readonly) BOOL showing;


@end
