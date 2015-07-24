//
//  DbFileDatabase.h
//  DbObjects
//
//  Created by Libriance on 8/23/14.
//  Copyright (c) 2014 Sudobility. All rights reserved.
//

#import "DbDatabase.h"

@interface DbFileDatabase : DbDatabase

@property (nonatomic, strong) NSString * path;

- (id)initWithPath:(NSString *)path;
- (id)initWithPath:(NSString *)path schemas:(NSArray *)schemas;
- (id)initWithPath:(NSString *)path schemaFile:(NSString *)schemaFile;

- (void)readExistingSchemas;
- (void)syncTables;

@end
