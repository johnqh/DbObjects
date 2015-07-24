//
//  DbConfiguration.m
//  DbObjects
//
//  Created by Qiang Huang on 12/18/14.
//  Copyright (c) 2014 Sudobility. All rights reserved.
//

#import "DbConfiguration.h"

static DbConfiguration * _singleton = nil;

@implementation DbConfiguration

+ (DbConfiguration *)singleton
{
    if (!_singleton)
    {
        _singleton = [[DbConfiguration alloc] init];
        _singleton.platform = @"Mobile";
    }
    return _singleton;
}
@end
