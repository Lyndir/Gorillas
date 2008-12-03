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
    CocosNode *node;
    NSMutableArray *subNodes;
    float nodeWidth;
    bool cancelled;
}

+(PanAction *) actionWithNode: (CocosNode *)node subNodes: (NSMutableArray *)subNodes nodeWidth: (float)width duration: (ccTime)seconds;
-(PanAction *) initWithNode: (CocosNode *)node subNodes: (NSMutableArray *)subNodes nodeWidth: (float)width duration: (ccTime)seconds;
-(void) cancel;


@end
