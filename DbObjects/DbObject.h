//
//  DbObject.h
//  DbBridge
//
//  Created by John Huang on 3/18/14.
//  Copyright (c) 2014 John Huang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModelObject.h"

@class DbDatabase;
@class DbTable;

@interface DbObject : NSObject<ModelObject>

@property (nonatomic, weak) DbDatabase * db;
@property (nonatomic, weak) DbTable * table;
@property (nonatomic, strong) NSMutableDictionary<NSString *, id> * readData;
@property (nonatomic, strong) NSMutableDictionary<NSString *, id> * writeData;
@property (nonatomic, assign) bool saved;

@property (nonatomic, readonly) bool modified;
@property (nonatomic, readonly) NSString * whereClause;
@property (nonatomic, readonly) NSString * keyValue;
@property (nonatomic, readonly) NSString * keyField;
@property (nonatomic, readonly) NSString * modifiedFields;
@property (nonatomic, readonly) NSString * modifiedData;
@property (nonatomic, readonly) NSString * modifiedFieldsAndData;
@property (nonatomic, readonly) bool isCollection;

+ (NSComparisonResult)compare:(NSObject *)value1 to:(NSObject *)value2;

- (id)initWithDb:(DbDatabase *)db;
- (DbTable *)verifyTable;

- (bool)setPrivate:(NSString *)fieldName data:(NSString *)data;
- (NSString *)getPrivate:(NSString *)fieldName;
- (NSString *)getDerived:(NSString *)fieldName;

- (NSNumber *)boolForKey:(NSString *)fieldName;
- (void)setBool:(NSNumber *)value forKey:(NSString *)fieldName;

- (NSNumber *)int16ForKey:(NSString *)fieldName;
- (void)setInt16:(NSNumber *)value forKey:(NSString *)fieldName;

- (NSNumber *)int32ForKey:(NSString *)fieldName;
- (void)setInt32:(NSNumber *)value forKey:(NSString *)fieldName;

- (NSNumber *)int64ForKey:(NSString *)fieldName;
- (void)setInt64:(NSNumber *)value forKey:(NSString *)fieldName;

- (NSNumber *)floatForKey:(NSString *)fieldName;
- (void)setFloat:(NSNumber *)value forKey:(NSString *)fieldName;

- (NSString *)stringForKey:(NSString *)fieldName;
- (void)setString:(NSString *)value forKey:(NSString *)fieldName;

- (NSDate *)dateForKey:(NSString *)fieldName;
- (void)setDate:(NSDate *)value forKey:(NSString *)fieldName;

- (NSDate *)dateTimeForKey:(NSString *)fieldName;
- (void)setDateTime:(NSDate *)value forKey:(NSString *)fieldName;

- (NSObject *)valueForKey:(NSString *)fieldName;

- (NSString *)formattedData:(NSString *)fieldName;

- (void)refresh:(DbObject *)obj;

- (id)loadFromDb;
- (void)saveToDb;
- (void)removeFromDb;
- (void)revert;

- (void)delayedSave;
- (void)delayedRemove;

- (DbObject *)cached:(NSString *)keyValue;
- (DbObject *)cachedOrMe:(NSString *)keyValue;

@end
