//
//  DbQuery.m
//  DbObjects
//
//  Created by Libriance on 8/23/14.
//  Copyright (c) 2014 Sudobility. All rights reserved.
//

#import "DbQuery.h"
#import "DbObject.h"
#import "DbCollection.h"
#import "DbCollection+Private.h"
#import "DbTable.h"
#import "DbField.h"
#import "DbObjectUtils.h"
#import "DbSearchTerm.h"

@implementation DbQuery

- (bool)connectDatabase:(DbDatabase *)db
{
    return false;
}

- (void)disconnectDatabase:(DbDatabase *)db
{
    
}

- (id)loadObject:(DbObject *)object
{
    return nil;
}

- (id)loadCollection:(DbCollection *)collection
{
    return nil;
}

- (bool)saveObject:(DbObject *)object
{
    return false;
}

- (bool)removeObject:(DbObject *)object
{
    return false;
}

- (int)count:(DbCollection *)collection
{
    return 0;
}

- (NSString *)tableName:(NSString *)tableName
{
    return tableName;
}

- (NSString *)loadStatement:(DbObject *)object
{
    if ([object verifyTable])
    {
        NSMutableString * builder = [[NSMutableString alloc] initWithCapacity:128];
        [builder appendString:@"SELECT "];
        [builder appendString:object.table.fieldNames];
        [builder appendString:@" FROM "];
        [builder appendString:[self tableName:object.table.name]];
        NSString * where = [object whereClause];
        if (where)
        {
            [builder appendString:@" "];
            [builder appendString:where];
        }
        return builder;
    }
    return nil;
}

- (NSString *)loadStatementForCollection:(DbCollection *)collection
{
    NSMutableString * builder = [[NSMutableString alloc] initWithCapacity:128];
    [builder appendString:[self loadStatement:collection]];
    
    NSString * sortStatement = [self sortStatement:collection];
    if (sortStatement)
    {
        [builder appendString:@" "];
        [builder appendString:sortStatement];
    }
    NSString * limitStatement = [self limitStatement:collection];
    if (limitStatement)
    {
        [builder appendString:@" "];
        [builder appendString:limitStatement];
    }
    return builder;
}


- (NSString *)sortStatement:(DbCollection *)collection
{
    if (collection.random)
    {
        return [self randomStatement];
    }
    else if (collection.sortings != nil && [collection.sortings count] > 0)
    {
        NSMutableString * builder = [[NSMutableString alloc] initWithCapacity:128];
        
        bool first = true;
        for (int i = 0; i < [collection.sortings count]; i ++)
        {
            DbSortDescriptor * sort = [collection.sortings objectAtIndex:i];
            NSDictionary * fields = collection.table.fields;
            NSString * sqlFieldName = [DbObjectUtils sqlFieldName:sort.fieldName];
            if (sqlFieldName && fields[sqlFieldName] != nil)
            {
                if (first)
                {
                    [builder appendString:@"ORDER BY "];
                    first = false;
                }
                else
                {
                    [builder appendString:@", "];
                }
                [builder appendString:sqlFieldName];
                if (!sort.ascending)
                {
                    [builder appendString:@" DESC"];
                }
            }
        }
        return builder;
    }
    else
    {
        return nil;
    }
    
}

- (NSString *)randomStatement
{
    return @"ORDER BY RANDOM()";
}

- (NSString *)limitStatement:(DbCollection *)collection
{
    if (collection.paging)
    {
        NSUInteger startItem = collection.itemsPerPage * collection.page;
        return [NSString stringWithFormat:@" LIMIT %lu, %lu", (unsigned long)startItem, (unsigned long)collection.itemsPerPage];
    }
    return nil;
}


- (NSString *)insertStatement:(DbObject *)object
{
    if (object.verifyTable)
    {
        NSString * modified = object.modifiedFields;
        if (modified)
        {
            NSMutableString * builder = [[NSMutableString alloc] initWithCapacity:128];
            [builder appendString:@"INSERT INTO "];
            [builder appendString:object.table.name];
            if (object.writeData)
            {
                [builder appendString:@" ("];
                [builder appendString:modified];
                [builder appendString:@") VALUES ("];
                [builder appendString:object.modifiedData];
                [builder appendString:@")"];
            }
            return builder;
        }
    }
    return nil;
}

- (NSString *)updateStatement:(DbObject *)object
{
    if (object.verifyTable)
    {
        NSString * modified = object.modifiedFieldsAndData;
        if (modified)
        {
            NSMutableString * builder = [[NSMutableString alloc] initWithCapacity:128];
            [builder appendString:@"UPDATE "];
            [builder appendString:object.table.name];
            [builder appendString:@" SET "];
            [builder appendString:modified];
            NSString * where = [object whereClause];
            if (where)
            {
                [builder appendString:@" "];
                [builder appendString:where];
            }
            return builder;
        }
    }
    return nil;
}

- (NSString *)updateStatementForCollection:(DbCollection *)collection
{
    if (collection.verifyTable)
    {
        NSString * modified = collection.modifiedFieldsAndData;
        if (modified)
        {
            NSMutableString * builder = [[NSMutableString alloc] initWithCapacity:128];
            [builder appendString:@"UPDATE "];
            [builder appendString:collection.table.name];
            [builder appendString:@" SET "];
            [builder appendString:modified];
            return builder;
        }
    }
    return nil;
}

- (NSString *)removeStatement:(DbObject *)object
{
    if (object.verifyTable)
    {
        NSMutableString * builder = [[NSMutableString alloc] initWithCapacity:128];
        [builder appendString:@"DELETE FROM "];
        [builder appendString:[self tableName:object.table.name]];
        NSString * where = [object whereClause];
        if (where)
        {
            [builder appendString:@" "];
            [builder appendString:where];
        }
        return builder;
    }
    return nil;
}

- (NSString *)countStatement:(DbCollection *)collection
{
    if (collection.verifyTable)
    {
        NSMutableString * builder = [[NSMutableString alloc] initWithCapacity:128];
        [builder appendString:@"SELECT COUNT(*) FROM "];
        [builder appendString:[self tableName:collection.table.name]];
        NSString * where = [collection whereClause];
        if (where)
        {
            [builder appendString:@" "];
            [builder appendString:where];
        }
        return builder;
    }
    return nil;
}

- (NSString *)sqlEncode:(NSString *)text
{
    if (text)
    {
        return text;
    }
    return @"NULL";
}

@end
