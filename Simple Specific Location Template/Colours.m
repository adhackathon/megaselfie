//
//  Colours.m
//  Simple Specific Location Template
//
//  Created by Yannick Meel on 07/06/14.
//  Copyright (c) 2014 Yannick Meel. All rights reserved.
//

#import "Colours.h"

@implementation Colours

static UIColor *__blue;
static UIColor *__lightGray;
static UIColor *__darkGray;

+ (void)initialize
{
    if (self == [Colours class]) {
        __blue = [UIColor colorWithRed:111.0/255.0 green:149.0/255.0 blue:227.0/255.0 alpha:1.0];
        __lightGray = [UIColor colorWithRed:214.0/255.0 green:215.0/255.0 blue:215.0/255.0 alpha:1.0];
        __darkGray = [UIColor colorWithRed:144.0/255.0 green:145.0/255.0 blue:147.0/255.0 alpha:1.0];
    }
}

+ (UIColor*)blue
{
    return __blue;
}

+ (UIColor *)lightGray
{
    return __lightGray;
}

+ (UIColor *)darkGray
{
    return __darkGray;
}

@end
