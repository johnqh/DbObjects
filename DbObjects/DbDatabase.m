//
//  DbDatabase.m
//  DbObjects
//
//  Created by John Huang on 4/1/14.
//  Copyright (c) 2014 River Past Corporation. All rights reserved.
//

#import "DbDatabase.h"
#import "DbConfiguration.h"
#import "DbQuery.h"
#import "DbTable.h"
#import "DbObjectCache.h"
#import "XMLReader.h"
#import "NSString+Utils.h"

@interface DbDatabase()
{
    DbQuery * _query;
    DbObjectCache * _cache;
}

@end

@implementation DbDatabase

- (DbQuery *)query
{
    if (!_query)
    {
        _query = [self createQuery];
    }
    return _query;
}

- (DbObjectCache *)cache
{
    if (!_cache)
    {
        _cache = [self createCache];
    }
    return _cache;
}

- (NSArray *)loadXmlSchemaFile:(NSString *)schemaFile
{
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSString * schemaText = [NSString stringWithContentsOfFile:schemaFile usedEncoding:&encoding error:nil];
    NSError * error = nil;
    NSDictionary * schemaDictionary = [XMLReader dictionaryForXMLString:schemaText error:&error];
    NSDictionary * schemaModel = [schemaDictionary objectForKey:@"model"];
    return [self schemaArray:[schemaModel objectForKey:@"entity"]];
}

- (NSArray *)schemaArray:(id)entity
{
    if ([entity isKindOfClass:[NSArray class]])
    {
        return entity;
    }
    else
    {
        return [NSArray arrayWithObject:entity];
    }
}

- (void)loadSchemas:(NSArray *)schema
{
    for (NSDictionary * schemaTable in schema)
    {
        NSString * platform = schemaTable[@"Platform"];
        bool pass = platform ? [platform contains:[DbConfiguration singleton].platform] : true;
        if (pass)
        {
            DbTable * table = [[DbTable alloc] initWithDb:self Schema:schemaTable];
            [self.tables setObject:table forKey:table.className];
        }
    }
}

- (DbQuery *)createQuery
{
    return nil;
}

- (DbObjectCache *)createCache
{
    return [[DbObjectCache alloc] init];
}

- (bool)connect
{
    return [self.query connectDatabase:self];
}

- (void)disconnect
{
    [self.query disconnectDatabase:self];
}

- (void)beginTransactions
{
    
}

- (void)commitTransactions
{
    
}

- (void)dealloc
{
    _query = nil;
    _cache = nil;
}

@end
