//
//  GorillaLayer.h
//  Gorillas
//
//  Created by Maarten Billemont on 07/11/08.
//  Copyright 2008 Lin.k. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"


@interface GorillaLayer : Sprite {

    NSString *name;
    
    BOOL human;
    BOOL alive;
}

-(BOOL) hitsGorilla: (cpVect)pos;

@property (readwrite, retain) NSString *name;

@property (readwrite, assign) BOOL human;
@property (readwrite, assign) BOOL alive;

@end
