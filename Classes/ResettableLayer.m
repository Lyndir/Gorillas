//
//  ResettableLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 26/10/08.
//  Copyright 2008 Lin.k. All rights reserved.
//

#import "ResettableLayer.h"


@implementation ResettableLayer


-(void) reset {

    @throw [NSException exceptionWithName:@"AbstractClassException" reason:@"You need to override the -(void) reset method of this class." userInfo:nil];
}


@end
