//
//  ConfigurationLayer.h
//  Gorillas
//
//  Created by Maarten Billemont on 26/10/08.
//  Copyright 2008 Lin.k. All rights reserved.
//

#import "ShadeLayer.h"


@interface ConfigurationLayer : ShadeLayer {
    
@private
    Menu *menu;
}


-(void) reset;

@end
