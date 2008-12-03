//
//  StatisticsViewController.m
//  Gorillas
//
//  Created by Maarten Billemont on 18/10/08.
//  Copyright 2008 Lin.k. All rights reserved.
//

#import "StatisticsViewController.h"


@implementation StatisticsViewController


- (IBAction) back {
    
    [[self getGorillasViewController] showMainMenu];
}


- (IBAction) reset {
    
    [[self getGorillasViewController] showConfirmReset];
}


@end
