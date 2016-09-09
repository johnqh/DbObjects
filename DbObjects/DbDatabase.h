//
//  DbDatabase.h
//  DbObjects
//
//  Created by John Huang on 4/1/14.
//  Copyright (c) 2014 River Past Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DbObjectCache;
@class DbTable;
@class DbQuery;

@interface DbDatabase : NSObject

@property (nonatomic, strong) NSMutableDictionary<NSString *, DbTable *> * tables;
@property (nonatomic, strong) NSArray<NSDictionary *> * schemas;
@property (nonatomic, readonly) DbQuery * query;
@property (nonatomic, readonly) DbObjectCache * cache;

- (NSArray<NSDictionary *> *)loadXmlSchemaFile:(NSString *)schemaFile;
- (void)loadSchemas:(NSArray<NSDictionary *> *)schema;

- (DbQuery *)createQuery;
- (DbObjectCache *)createCache;

- (bool)connect;
- (void)disconnect;

- (void)beginTransactions;
- (void)commitTransactions;

@end
