//
//  AbstractViewController.m
//  Gorillas
//
//  Created by Maarten Billemont on 19/10/08.
//  Copyright 2008 Lin.k. All rights reserved.
//

#import "AbstractViewController.h"
#import "GorillasAppDelegate.h"


@implementation AbstractViewController


- (GorillasViewController *)getGorillasViewController {
    
    return [(GorillasAppDelegate *)[[UIApplication sharedApplication] delegate] gorillasViewController];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


@end
