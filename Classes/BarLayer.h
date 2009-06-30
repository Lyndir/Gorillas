/*
 * This file is part of Gorillas.
 *
 *  Gorillas is open software: you can use or modify it under the
 *  terms of the Java Research License or optionally a more
 *  permissive Commercial License.
 *
 *  Gorillas is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *
 *  You should have received a copy of the Java Research License
 *  along with Gorillas in the file named 'COPYING'.
 *  If not, see <http://stuff.lhunath.com/COPYING>.
 */

//
//  BarLayer.h
//  Gorillas
//
//  Created by Maarten Billemont on 05/03/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//



@interface BarLayer : Sprite {
    
    MenuItemFont        *menuButton;
    Menu                *menuMenu;
    Label               *messageLabel;
    
    long                color, renderColor;
    CGPoint              showPosition;
    
    BOOL                dismissed;
}

-(id) initWithColor:(long)aColor position:(CGPoint)_showPosition;

-(void) setButtonImage:(NSString *)aFile callback:(id)target :(SEL)selector;
-(CGPoint) hidePosition;
-(void) dismiss;

-(void) message:(NSString *)msg isImportant:(BOOL)important;
-(void) message:(NSString *)msg duration:(ccTime)_duration isImportant:(BOOL)important;
-(void) dismissMessage;

@property (nonatomic, readonly) BOOL dismissed;

@end
