//
//  DbSqliteIndex.h
//  DbBridge
//
//  Created by John Huang on 3/18/14.
//  Copyright (c) 2014 John Huang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DbIndex : NSObject

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSMutableArray<NSString *> * fields;

- (id)initWithName:(NSString *)name fields:(NSMutableArray *)fields;
- (id)initWithSchema:(NSDictionary *)dictionary;

- (NSString *)fieldsText;

@end
