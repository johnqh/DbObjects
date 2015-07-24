//
//  DbSortDescriptor.m
//  DbBridge
//
//  Created by John Huang on 3/18/14.
//  Copyright (c) 2014 John Huang. All rights reserved.
//

#import "DbSortDescriptor.h"

@implementation DbSortDescriptor

+ (DbSortDescriptor *)sortOnKey:(NSString *)fieldName ascending:(BOOL)ascending
{
    return [[DbSortDescriptor alloc] initWithKey:fieldName ascending:ascending];
}

- (id)initWithKey:(NSString *)fieldName ascending:(BOOL)ascending
{
    if (self = [super init])
    {
        self.fieldName = fieldName;
        self.ascending = ascending;
        return self;
    }
    return nil;
}

- (void)dealloc
{
    self.fieldName = nil;
}
@end
