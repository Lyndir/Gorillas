/**
 * Copyright Maarten Billemont (http://www.lhunath.com, lhunath@lyndir.com)
 *
 * See the enclosed file LICENSE for license information (LGPLv3). If you did
 * not receive this file, see http://www.gnu.org/licenses/lgpl-3.0.txt
 *
 * @author   Maarten Billemont <lhunath@lyndir.com>
 * @license  http://www.gnu.org/licenses/lgpl-3.0.txt
 */
//
//  MenuItemDescription.m
//  Pearl
//
//  Created by Maarten Billemont on 08/09/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "MenuItemDescription.h"

@implementation MenuItemDescription

+ (instancetype)itemWithString:(NSString *)string {

    return [[self alloc] initWithString:string];
}

- (id)initWithString:(NSString *)string {

    UIFont *font = [UIFont fontWithName:[PearlConfig get].fixedFontName size:[[PearlConfig get].smallFontSize unsignedIntegerValue] * 0.8f];
    CGSize boundingSize = CGSizeMake( [CCDirector sharedDirector].winSize.width * 0.8f, CGFLOAT_MAX );
    CGSize dim = [string sizeWithFont:font constrainedToSize:boundingSize lineBreakMode:NSLineBreakByWordWrapping];

    if (!(self = ([super initWithLabel:[CCLabelTTF labelWithString:string fontName:font.fontName fontSize:font.pointSize
                                                        dimensions:dim hAlignment:kCCTextAlignmentLeft]
                                 block:nil])))
        return nil;

    return self;
}

@end
