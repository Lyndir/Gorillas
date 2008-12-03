//
//  main.m
//  Gorillas
//
//  Created by Maarten Billemont on 18/10/08.
//  Copyright Lin.k 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, @"GorillasAppDelegate");
    [pool release];
    
    return retVal;
}
