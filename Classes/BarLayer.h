/*
 * This file is part of Gorillas.
 *
 *  Gorillas is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  Gorillas is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Gorillas in the file named 'COPYING'.
 *  If not, see <http://www.gnu.org/licenses/>.
 */

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

@property (nonatomic, readonly) BOOL dismissed;

@end
