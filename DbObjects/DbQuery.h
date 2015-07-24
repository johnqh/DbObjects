//
//  DbQuery.h
//  DbObjects
//
//  Created by Libriance on 8/23/14.
//  Copyright (c) 2014 Sudobility. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DbDatabase;
@class DbObject;
@class DbCollection;

@interface DbQuery : NSObject

- (bool)connectDatabase:(DbDatabase *)db;
- (void)disconnectDatabase:(DbDatabase *)db;

- (DbObject *)loadObject:(DbObject *)object;
- (DbCollection *)loadCollection:(DbCollection *)collection;
- (bool)saveObject:(DbObject *)object;
- (bool)removeObject:(DbObject *)object;

- (int)count:(DbCollection *)collection;

- (NSString *)loadStatement:(DbObject *)object;
- (NSString *)loadStatementForCollection:(DbCollection *)collection;
- (NSString *)sortStatement:(DbCollection *)collection;
- (NSString *)randomStatement;
- (NSString *)limitStatement:(DbCollection *)collection;
- (NSString *)insertStatement:(DbObject *)object;
- (NSString *)updateStatement:(DbObject *)object;
- (NSString *)updateStatementForCollection:(DbCollection *)collection;
- (NSString *)removeStatement:(DbObject *)object;
- (NSString *)countStatement:(DbCollection *)collection;

- (NSString *)sqlEncode:(NSString *)text;

@end
