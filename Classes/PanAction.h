//
//  PanAction.h
//  Gorillas
//
//  Created by Maarten Billemont on 26/10/08.
//  Copyright 2008 Lin.k. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "GorillasConfig.h"


@interface PanAction : MoveBy {

    @private
    NSMutableArray *subNodes;
    int padding;
    BOOL cancelled;
}

+(PanAction *) actionWithSubNodes: (NSMutableArray *)nSubNodes duration: (ccTime)nDuration padding: (int) nPadding;
-(PanAction *) initWithSubNodes: (NSMutableArray *)nSubNodes duration: (ccTime)nDuration padding: (int)nPadding;
-(void) cancel;


@end
