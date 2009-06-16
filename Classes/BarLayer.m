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
//  BarLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 05/03/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "BarLayer.h"
#import "Remove.h"


@implementation BarLayer

@synthesize dismissed;


-(id) initWithColor:(long)aColor position:(cpVect)_showPosition {
    
    if(!(self = [super initWithFile:@"bar.png"]))
        return self;
        
    color           = aColor;
    renderColor     = aColor;
    showPosition    = cpvadd(_showPosition, cpv(self.contentSize.width / 2, self.contentSize.height / 2));
    dismissed       = YES;

    menuButton      = nil;
    menuMenu        = nil;
    
    return self;
}


-(void) setButtonImage:(NSString *)aFile callback:(id)target :(SEL)selector {

    if(menuMenu) {
        [self removeChild:menuMenu cleanup:NO];
        [menuMenu release];
        [menuButton release];
        menuMenu    = nil;
        menuButton  = nil;
    }
    
    if(!aFile)
        // No string means no button.
        return;
        
    menuButton          = [[MenuItemImage itemFromNormalImage:aFile selectedImage:aFile
                                                       target:target selector:selector] retain];
    menuMenu            = [[Menu menuWithItems:menuButton, nil] retain];
    menuMenu.position   = cpv(self.contentSize.width - menuButton.contentSize.width / 2, 16);

    
    [menuMenu alignItemsHorizontally];
    [self addChild:menuMenu];
}


-(void) onEnter {
    
    dismissed = NO;
    
    [super onEnter];
    
    [self stopAllActions];
    
    if([messageLabel parent])
        [self removeChild:messageLabel cleanup:NO];
    
    self.position = self.hidePosition;
    [self runAction:[MoveTo actionWithDuration:[[GorillasConfig get] transitionDuration]
                               position:showPosition]];
}


-(void) message:(NSString *)msg isImportant:(BOOL)important {
    
    [self message:msg duration:0 isImportant:important];
}


-(void) message:(NSString *)msg duration:(ccTime)_duration isImportant:(BOOL)important {
    
    if (messageLabel) {
        [self removeChild:messageLabel cleanup:YES];
        [messageLabel release];
    }
    
    CGFloat fontSize = [GorillasConfig get].smallFontSize;
    messageLabel = [[Label alloc] initWithString:msg dimensions:self.contentSize alignment:UITextAlignmentCenter
                                        fontName:[GorillasConfig get].fixedFontName fontSize:fontSize];

    if(important) {
        renderColor = 0x993333FF;
        [messageLabel setRGB:0xCC :0x33 :0x33];
    } else {
        renderColor = color;
        [messageLabel setRGB:0xFF :0xFF :0xFF];
    }
    
    [messageLabel setPosition:cpv(self.contentSize.width / 2, fontSize / 2 + 2)];
    [self addChild:messageLabel];
    
    if(_duration)
        [messageLabel runAction:[Sequence actions:
                                 [DelayTime actionWithDuration:_duration],
                                 [CallFunc actionWithTarget:self selector:@selector(dismissMessage)],
                                 nil]];
}


-(void) dismissMessage {
    
    [messageLabel stopAllActions];
    [self removeChild:messageLabel cleanup:NO];
    
    renderColor = color;
}


-(void) dismiss {
    
    if(dismissed)
        // Already being dismissed.
        return;
    
    dismissed = YES;
    
    [self stopAllActions];
    
    self.position = showPosition;
    [self runAction:[Sequence actions:
              [MoveTo actionWithDuration:[[GorillasConfig get] transitionDuration]
                                position:self.hidePosition],
              [Remove action],
              nil]];
}


-(cpVect) hidePosition {
    
    return cpvadd(showPosition, cpv(0, -self.contentSize.height));
}


-(void) draw {

    [super draw];
    
    cpVect to = cpv(self.contentSize.width, self.contentSize.height);
    drawLinesTo(cpv(0, self.contentSize.height), &to, 1, 0xFFFFFFFF, 1);
}

-(void) dealloc {
    
    [messageLabel release];
    messageLabel = nil;
    
    [menuButton release];
    menuButton = nil;
    
    [menuMenu release];
    menuMenu = nil;
    
    [super dealloc];
}

@end
