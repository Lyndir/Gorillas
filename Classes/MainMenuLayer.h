//
//  MainMenuLayer.h
//  Gorillas
//
//  Created by Maarten Billemont on 26/10/08.
//  Copyright 2008 Lin.k. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShadeLayer.h"

@interface MainMenuLayer : ShadeLayer {

    @private
    Menu *menu;
    
    MenuItem *newSingle;
    MenuItem *newMulti;
    
    MenuItem *continueGame;
    MenuItem *stopGame;
    
    MenuItem *config;
    MenuItem *stats;
}

-(void) newGameSingle: (id)sender;
-(void) newGameMulti: (id)sender;
-(void) continueGame: (id)sender;
-(void) stopGame: (id)sender;
-(void) statistics: (id)sender;
-(void) options: (id)sender;


@end
