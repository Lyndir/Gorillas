//
//  StatisticsLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 26/10/08.
//  Copyright 2008 Lin.k. All rights reserved.
//

#import "StatisticsLayer.h"
#import "GorillasAppDelegate.h"


@implementation StatisticsLayer


-(void) reveal {
    
    [super reveal];
    [[GorillasAppDelegate get] hideHud];
}


-(void) dismiss {
    
    [super dismiss];
    [[GorillasAppDelegate get] revealHud];
}


@end
