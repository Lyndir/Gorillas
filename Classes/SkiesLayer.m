//
//  SkiesLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 26/10/08.
//  Copyright 2008 Lin.k. All rights reserved.
//

#import "SkiesLayer.h"
#import "SkyLayer.h"
#import "PanAction.h"


@implementation SkiesLayer


-(id) init {
    
    if (!(self = [super init]))
		return self;
    
    const float w = [[Director sharedDirector] winSize].size.width;
    
    skies = [[NSMutableArray alloc] init];
    for (int i = 0; i < 3; ++i) {
        const float x = i * w - w;
        
        const SkyLayer *sky =  [SkyLayer node];
        [skies addObject: sky];
        
        [sky setPosition: cpv(x, 0)];
        [self add: sky z:1];
    }
    
    [self do: [PanAction actionWithSubNodes:skies duration: [[GorillasConfig get] starSpeed] padding:0]];
    
    return self;
}


-(void) reset {

    for(SkyLayer *sky in skies)
        [sky reset];
}


-(void) draw {
    
    long color = [[GorillasConfig get] skyColor];
    GLubyte *colorBytes = (GLubyte *)&color;
    
    glClearColor(colorBytes[3] / (float)0xff, colorBytes[2] / (float)0xff, colorBytes[1] / (float)0xff, colorBytes[0] / (float)0xff);
    glClear(GL_COLOR_BUFFER_BIT);
}


@end
