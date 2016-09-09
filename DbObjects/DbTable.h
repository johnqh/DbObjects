//
//  DbTable.h
//  DbBridge
//
//  Created by John Huang on 3/18/14.
//  Copyright (c) 2014 John Huang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DbDatabase;
@class DbObject;
@class DbField;
@class DbIndex;

@interface DbTable : NSObject

@property (nonatomic, weak) DbDatabase * db;
@property (nonatomic, strong) NSMutableDictionary<NSString *, DbField *> * fields;
@property (nonatomic, strong) NSMutableDictionary<NSString *, DbIndex *> * indice;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * className;
@property (nonatomic) bool syncable;

- (id)initWithDb:(DbDatabase *)db;
- (id)initWithDb:(DbDatabase *)db Schema:(NSDictionary *)dictionary;
- (void)populateObjectMethods;

- (DbField *)fieldWithName:(NSString *)name;
- (DbField *)autoIncrementField;

- (NSString *)fieldNames;


@end
