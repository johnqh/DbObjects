//
//  SqliteDatabases.m
//  SqliteTest
//
//  Created by Libriance on 4/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DbDatabases.h"
#import "DbFileUtils.h"
#import "DbQuery.h"

DbDatabases * _databases = nil;


@implementation DbDatabases


+ (DbDatabases *)databases
{
    if (!_databases)
    {
        _databases = [[DbDatabases alloc] init];
    }
    return _databases;
}

+ (DbDatabase *)singleton
{
    DbDatabases * databases = [DbDatabases databases];
    return [databases database:@"singleton"];
}

+ (DbDatabase *)openSingleton:(DbDatabase *)database
{
    return [self openDatabase:database tag:@"singleton"];
}

+ (DbDatabase *)openDatabase:(DbDatabase *)database tag:(NSString *)tag
{
    DbDatabases * databases = [DbDatabases databases];
    return [databases openDatabase:database tag:tag];
}

+ (void)shutdown
{
    DbDatabases * databases = [DbDatabases databases];
    if (databases.databases)
    {
        for (NSString * key in databases.databases)
        {
            DbDatabase * db = (DbDatabase *)[databases.databases objectForKey:key];
            [db disconnect];
        }
    }
}

- (DbDatabase *)database:(NSString *)tag
{
    if (_databases)
    {
        return (DbDatabase *)[_databases objectForKey:tag];
    }
    return nil;
}

- (DbDatabase *)openDatabase:(DbDatabase *)database tag:(NSString *)tag
{
    if ([database connect])
    {
        if (!_databases)
        {
            self.databases = [[NSMutableDictionary alloc] init];
        }
        [_databases setObject:database forKey:tag];
        return database;
    }
    return nil;
}

//- (DbSqliteDatabase *)openDatabase:(NSString *)tag at:(NSString *)path schemaFiles:(NSArray *)schemaFiles
//{
//    if (schemaFiles)
//    {
//        if (!_databases)
//        {
//            _databases = [[NSMutableDictionary alloc] init];
//        }
//        DbSqliteDatabase * database = [[[DbSqliteDatabase alloc] initWithPath:path] autorelease];
//        for (NSString * schemaFile in schemaFiles)
//        {
//            if (schemaFile && [FileUtils fileExists:schemaFile])
//            {
//                [database loadSchemaFromFile:schemaFile];
//                [database connect];
//            }
//        }
//        [_databases setObject:database forKey:tag];
//        
//        return database;
//    }
//    return nil;
//    
//}


- (void)suspend
{
    if (_databases)
    {
        for (NSString * key in _databases)
        {
            DbDatabase * db = (DbDatabase *)[_databases objectForKey:key];
            [db disconnect];
        }
    }
    
}

- (void)resume
{
    if (_databases)
    {
        for (NSString * key in _databases)
        {
            DbDatabase * db = (DbDatabase *)[_databases objectForKey:key];
            [db connect];
        }
    }
    
}

@end
