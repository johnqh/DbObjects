//
//  DbDatabase.h
//  DbObjects
//
//  Created by John Huang on 4/1/14.
//  Copyright (c) 2014 River Past Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DbObjectCache;
@class DbQuery;

@interface DbDatabase : NSObject

@property (nonatomic, strong) NSMutableDictionary * tables;
@property (nonatomic, strong) NSArray * schemas;
@property (nonatomic, readonly) DbQuery * query;
@property (nonatomic, readonly) DbObjectCache * cache;

- (NSArray *)loadXmlSchemaFile:(NSString *)schemaFile;
- (void)loadSchemas:(NSArray *)schema;

- (DbQuery *)createQuery;
- (DbObjectCache *)createCache;

- (bool)connect;
- (void)disconnect;

- (void)beginTransactions;
- (void)commitTransactions;

@end
