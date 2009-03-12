//
//  BarLayer.h
//  Gorillas
//
//  Created by Maarten Billemont on 05/03/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//



@interface BarLayer : Layer {
    
    MenuItemFont        *menuButton;
    Menu                *menuMenu;
    LabelAtlas          *messageLabel;
    
    long                fromColor, toColor, renderFromColor, renderToColor;
    float               width;
    float               height;
    cpVect              showPosition;
    
    BOOL                dismissed;
}

-(id) initWithColorFrom:(long)_fromColor to:(long)_toColor position:(cpVect)_showPosition;

-(void) setButtonString:(NSString *)_string callback:(id)target :(SEL)selector;
-(cpVect) hidePosition;
-(void) dismiss;

-(void) message:(NSString *)msg isImportant:(BOOL)important;
-(void) message:(NSString *)msg duration:(ccTime)_duration isImportant:(BOOL)important;
-(void) dismissMessage;

@property (readonly) BOOL dismissed;

@end
