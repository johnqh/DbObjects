//
//  DbSqliteIndex.m
//  DbBridge
//
//  Created by John Huang on 3/18/14.
//  Copyright (c) 2014 John Huang. All rights reserved.
//

#import "DbIndex.h"
#import "DictionaryUtils.h"
#import "DbObjectUtils.h"

@implementation DbIndex

- (id)init
{
    if (self == [super init])
    {
        self.fields = [NSMutableArray array];
        return self;
    }
    return nil;
}

- (id)initWithName:(NSString *)name fields:(NSMutableArray *)fields
{
    if (self = [super init])
    {
        self.name = name;
        self.fields = fields;
        return self;
    }
    return nil;
}

// sample: <index name="address"/>
// sample: <index name="address"><field name="address"/><field name="address2"/></index>
- (id)initWithSchema:(NSDictionary *)dictionary
{
    if (self = [super init])
    {
        self.name = [dictionary objectForKey:@"name"];
        self.fields = [NSMutableArray array];
        id fields = [dictionary objectForKey:@"field"];
        if (fields)
        {
            NSArray * fieldArray = [DictionaryUtils asArray:fields];
            for (NSDictionary * field in fieldArray)
            {
                [_fields addObject:[DbObjectUtils sqlFieldName:field[@"name"]]];
            }
        }
        else
        {
            [_fields addObject:[DbObjectUtils sqlFieldName:_name]];
            
        }
        return self;
    }
    return nil;
}
- (NSString *)fieldsText
{
	NSMutableString * builder = [[NSMutableString alloc] initWithCapacity:128];
	if (_fields)
	{
		for (int i = 0; i < [_fields count]; i ++)
		{
			if (i != 0)
			{
				[builder appendString:@", "];
			}
			NSString * fieldName = (NSString *)[_fields objectAtIndex:i];
			[builder appendString:fieldName];
		}
	}
	return builder;
}

- (void)dealloc
{
    self.name = nil;
    self.fields = nil;
}

@end
