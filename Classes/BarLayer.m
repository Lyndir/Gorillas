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


-(id) initWithColorFrom:(long)_fromColor to:(long)_toColor position:(cpVect)_showPosition {
    
    if(!(self = [super init]))
        return self;
    
    CGSize winSize = [[Director sharedDirector] winSize];
    
    fromColor       = _fromColor;
    toColor         = _toColor;
    renderFromColor = fromColor;
    renderToColor   = toColor;
    width           = winSize.width;
    height          =[[GorillasConfig get] smallFontSize] + 10;
    showPosition    = _showPosition;
    dismissed       = YES;

    menuButton      = nil;
    menuMenu        = nil;
    
    return self;
}


-(void) setButtonString:(NSString *)_string callback:(id)target :(SEL)selector {

    if(menuMenu) {
        [self removeChild:menuMenu cleanup:NO];
        [menuMenu release];
        [menuButton release];
        menuMenu    = nil;
        menuButton  = nil;
    }
    
    if(!_string)
        // No string means no button.
        return;
        
    menuButton          = [[MenuItemAtlasFont itemFromString:[NSString stringWithFormat:@"%@ ", _string]
                                         charMapFile:@"bonk.png" itemWidth:13 itemHeight:26 startCharMap:' '
                                              target:target selector:selector] retain];
    menuMenu            = [[Menu menuWithItems:menuButton, nil] retain];
    menuMenu.position   = cpv(width - [menuButton contentSize].width / 2,
                              [menuButton contentSize].height / 2);

    
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
    
    CGSize winSize = [Director sharedDirector].winSize;
    msg = [NSString stringWithFormat:@" %@ ", msg];
    
    if (!messageLabel)
        messageLabel = [[LabelAtlas alloc] initWithString:msg
                                              charMapFile:@"bonk.png" itemWidth:13 itemHeight:26 startCharMap:' '];
    else
        [messageLabel setString:msg];

    // Make sure message fits on screen.
    [messageLabel setScale:fminf(1, winSize.width / ([msg length] * 13))];
    
    if(important) {
        renderFromColor = 0x993333FF;
        renderToColor   = 0x330000FF;
        [messageLabel setRGB:0xCC :0x33 :0x33];
    } else {
        renderFromColor = fromColor;
        renderToColor   = toColor;
        [messageLabel setRGB:0xFF :0xFF :0xFF];
    }
    
    if([messageLabel parent])
        [self removeChild:messageLabel cleanup:YES];
    
    [messageLabel setPosition:cpv((winSize.width - [messageLabel contentSize].width * messageLabel.scale) / 2,
                                  (height - [messageLabel contentSize].height * messageLabel.scale) / 2)];
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
    
    renderFromColor = fromColor;
    renderToColor   = toColor;
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
    
    return cpvadd(showPosition, cpv(0, -height));
}


-(void) draw {
    
    cpVect to = cpv(width, height);
    drawBoxFrom(cpvzero, to, renderFromColor, renderToColor);
    drawLinesTo(cpv(0, height), &to, 1, 0x999999FF, 1);
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
