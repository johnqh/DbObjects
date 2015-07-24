//
//  DbSortDescriptor.h
//  DbBridge
//
//  Created by John Huang on 3/18/14.
//  Copyright (c) 2014 John Huang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DbSortDescriptor : NSObject

@property (nonatomic, strong) NSString * fieldName;
@property (nonatomic) bool ascending;

+ (DbSortDescriptor *)sortOnKey:(NSString *)fieldName ascending:(BOOL)ascending;
- (id)initWithKey:(NSString *)fieldName ascending:(BOOL)ascending;

@end
