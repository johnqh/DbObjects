//
//  DbObjectCache.h
//  DbObjects
//
//  Created by Libriance on 5/21/15.
//  Copyright (c) 2015 Sudobility. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DbObject;

@interface DbObjectCache : NSObject

- (void)markInCache:(DbObject *)obj;
- (void)saveToCache:(DbObject *)obj;
- (void)updateCache:(DbObject *)obj;
- (void)removeFromCache:(DbObject *)obj;
- (DbObject *)cachedObject:(NSString *)className keyValue:(NSString *)keyValue;

@end
