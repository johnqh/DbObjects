//
//  DbField.h
//  DbBridge
//
//  Created by John Huang on 3/18/14.
//  Copyright (c) 2014 John Huang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum EDbType : NSUInteger
{
    kDbTypeUnknown = 0,
    kDbTypeString = 1,
    kDbTypeInt16 = 2,
    kDbTypeInt32 = 4,
    kDbTypeInt64 = 8,
    kDbTypeBoolean = 16,
    kDbTypeFloat = 32,
    kDbTypeDate = 64,
    kDbTypeDateTime = 128,
    kDbTypeTransformable = 1024,
} EDbType;

@interface DbField : NSObject

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * display;
@property (nonatomic) EDbType type;
@property (nonatomic) bool optional;
@property (nonatomic) bool syncable;
@property (nonatomic) bool key;
@property (nonatomic) bool autoIncrement;
@property (nonatomic, strong) NSString * defaultValueString;
@property (nonatomic, readonly) NSString * sqlFieldName;

- (id)initWithName:(NSString *)name type:(EDbType)type;
- (id)initWithSchema:(NSDictionary *)dictionary;

- (NSString *)typeText;
- (NSString *)createText;

@end
