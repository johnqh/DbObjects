//
//  DbLogicSearchTerm.m
//  DbBridge
//
//  Created by John Huang on 3/20/14.
//  Copyright (c) 2014 John Huang. All rights reserved.
//

#import "DbLogicSearchTerm.h"

@implementation DbLogicSearchTerm

+ (DbLogicSearchTerm *)searchWithAnd
{
    DbLogicSearchTerm * searchTerm = [[DbLogicSearchTerm alloc] init];
    searchTerm.logicString = @"AND";
    return searchTerm;
}

+ (DbLogicSearchTerm *)searchWithOr
{
    DbLogicSearchTerm * searchTerm = [[DbLogicSearchTerm alloc] init];
    searchTerm.logicString = @"OR";
    return searchTerm;
}

- (void)addAlternative:(DbSearchTerm *)searchTerm
{
    if (!_alternatives)
    {
        self.alternatives = [NSMutableArray array];
    }
    [_alternatives addObject:searchTerm];
}

- (NSString *)asString
{
    if (_alternatives)
    {
        NSMutableArray * searchTexts = [NSMutableArray array];
        for (DbSearchTerm * searchTerm in _alternatives)
        {
            NSString * searchText = searchTerm.asString;
            if (searchText)
            {
                [searchTexts addObject:searchText];
            }
        }
        switch (searchTexts.count)
        {
            case 0:
                return nil;
                
            case 1:
            {
                NSString * searchText = searchTexts.firstObject;
                return searchText;
            }
                
            default:
            {
                NSMutableString * asString = [[NSMutableString alloc] initWithCapacity:128];
                bool first = true;
                [asString appendString:@"("];
                for (NSString * searchText in searchTexts)
                {
                    if (first)
                    {
                        first = false;
                    }
                    else
                    {
                        [asString appendFormat:@" %@ ", _logicString];
                    }
                    [asString appendString:searchText];
                }
                [asString appendString:@")"];
                return asString;
            };
        }
    }
    return nil;
}

- (bool)satisfy:(DbObject *)obj
{
    bool satisfy = true;
    if (_alternatives)
    {
        for (int i = 0; satisfy && i < _alternatives.count; i ++)
        {
            DbSearchTerm * search = (DbSearchTerm *)_alternatives[i];
            satisfy = [search satisfy:obj];
        }
    }
    return satisfy;
}

- (void)dealloc
{
    self.logicString = nil;
    self.alternatives = nil;
}

@end
