//
//  DbFileDatabase.m
//  DbObjects
//
//  Created by Libriance on 8/23/14.
//  Copyright (c) 2014 Sudobility. All rights reserved.
//

#import "DbFileDatabase.h"

@implementation DbFileDatabase

- (id)initWithPath:(NSString *)path
{
    if (self = [super init])
    {
        self.path = path;
        return self;
    }
    return nil;
}

- (id)initWithPath:(NSString *)path schemas:(NSArray *)schemas
{
    if (self = [self initWithPath:path])
    {
        self.schemas = schemas;
        return self;
    }
    return nil;
    
}

- (id)initWithPath:(NSString *)path schemaFile:(NSString *)schemaFile
{
    if (self = [self initWithPath:path])
    {
        self.schemas = [self loadXmlSchemaFile:schemaFile];
        return self;
    }
    return nil;
}

- (bool)connect
{
    bool connected = [super connect];
    if (connected)
    {
        self.tables = [NSMutableDictionary dictionary];
        [self readExistingSchemas];
        if (self.schemas)
        {
            [self loadSchemas:self.schemas];
            [self syncTables];
        }
        else
        {
            [self createSchemaFromTable];
        }
    }
    return connected;
}

- (void)readExistingSchemas
{
    
}

- (void)createSchemaFromTable
{
    
}

- (void)syncTables
{
    
}

- (NSString *)description
{
    return self.path.lastPathComponent;
}
@end
