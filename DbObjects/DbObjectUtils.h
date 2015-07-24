//
//  DbObjectUtils.h
//  DbBridge
//
//  Created by John Huang on 3/18/14.
//  Copyright (c) 2014 John Huang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DbObjectUtils : NSObject

+ (NSSet *)reservedKeywords;
+ (NSString *)setterFromFieldName:(NSString *)fieldName;
+ (NSString *)fieldNameFromGetter:(SEL)_cmd;
+ (NSString *)fieldNameFromSetter:(SEL)_cmd;
+ (NSString *)sqlFieldName:(NSString *)fieldName;


@end
