//
//  DbStringSearchTerm.m
//  DbBridge
//
//  Created by John Huang on 3/20/14.
//  Copyright (c) 2014 John Huang. All rights reserved.
//

#import "DbStringSearchTerm.h"

@implementation DbStringSearchTerm

+ (DbStringSearchTerm *)searchTerm:(NSString *)searchText
{
    DbStringSearchTerm * searchTerm = [[DbStringSearchTerm alloc] init];
    searchTerm.searchText = searchText;
    return searchTerm;
}

- (NSString *)asString
{
    return _searchText;
}

- (void)dealloc
{
    self.searchText = nil;
}
@end
