//
//  GorillasViewController.h
//  Gorillas
//
//  Created by Maarten Billemont on 18/10/08.
//  Copyright 2008 Lin.k. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GorillasViewController : UIViewController {
    
    UIViewController *currentViewController;
}

- (void) showMainMenu;
- (void) showStatistics;
- (void) showConfirmReset;
- (void) showPlayerSelection;
- (void) showAbout;
- (void) showGame;

- (void) show:(UIViewController *)newViewController;


@end
