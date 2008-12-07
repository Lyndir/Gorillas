//
//  HUDLayer.h
//  Gorillas
//
//  Created by Maarten Billemont on 10/11/08.
//  Copyright 2008 Lin.k. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"


@interface HUDLayer : Layer {

    @private
    MenuItemFont *menuButton;
    Menu *menuMenu;
    Label *scoreLabel;
    
    BOOL revealed;

    float width;
    float height;
}

-(void) reveal;
-(void) dismiss;

-(void) setMenuTitle: (NSString *)title;
-(void) updateScore;

-(BOOL) hitsHud: (cpVect)pos;

@end
