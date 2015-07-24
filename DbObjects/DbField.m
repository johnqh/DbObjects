//
//  DbField.m
//  DbBridge
//
//  Created by John Huang on 3/18/14.
//  Copyright (c) 2014 John Huang. All rights reserved.
//

#import "DbField.h"
#import "DbObjectUtils.h"

@implementation DbField

+ (EDbType)typeFromString:(NSString *)text
{
    if ([text isEqualToString:@"Integer 16"])
    {
        return kDbTypeInt16;
    }
    else if ([text isEqualToString:@"Integer 32"])
    {
        return kDbTypeInt32;
    }
    else if ([text isEqualToString:@"Integer 64"])
    {
        return kDbTypeInt64;
    }
    else if ([text isEqualToString:@"Boolean"])
    {
        return kDbTypeBoolean;
    }
    else if ([text isEqualToString:@"Float"])
    {
        return kDbTypeFloat;
    }
    else if ([text isEqualToString:@"String"])
    {
        return kDbTypeString;
    }
    else if ([text isEqualToString:@"Date"])
    {
        return kDbTypeDate;
    }
    else if ([text isEqualToString:@"DateTime"])
    {
        return kDbTypeDateTime;
    }
    else if ([text isEqualToString:@"Transformable"])
    {
        return kDbTypeTransformable;
    }
    else
    {
        return kDbTypeUnknown;
    }
    
}

- (NSString *)sqlFieldName
{
    return [DbObjectUtils sqlFieldName:_name];
}

- (id)initWithName:(NSString *)name type:(EDbType)type
{
    
    if (self = [super init])
    {
        self.name = name;
        self.type = type;
        return self;
    }
    return nil;
}

// sample: <attribute name="address" optional="YES" attributeType="String" syncable="YES"/>
- (id)initWithSchema:(NSDictionary *)dictionary
{
    if (self = [super init])
    {
        self.name = [dictionary objectForKey:@"name"];
        self.display = [dictionary objectForKey:@"display"];
        if (!_display)
        {
            self.display = _name;
        }
        self.type = [DbField typeFromString:[dictionary objectForKey:@"attributeType"]];
        self.syncable = [[dictionary objectForKey:@"syncable"] isEqualToString:@"YES"];
        self.key = [[dictionary objectForKey:@"key"] isEqualToString:@"YES"];
        if (self.key)
        {
            self.autoIncrement = [[dictionary objectForKey:@"autoIncrement"] isEqualToString:@"YES"];
        }
        self.optional = [[dictionary objectForKey:@"optional"] isEqualToString:@"YES"];
        self.defaultValueString = [dictionary objectForKey:@"defaultValueString"];
        return self;
    }
    return nil;
}

- (NSString *)typeText
{
    if (_type == kDbTypeInt16 ||
        _type == kDbTypeInt32 ||
        _type == kDbTypeInt64 ||
        _type == kDbTypeBoolean)
    {
        return @"INTEGER";
    }
    else if (_type == kDbTypeFloat)
    {
        return @"NUMERIC";
    }
    else if (_type == kDbTypeString)
    {
        return @"TEXT";
    }
    else if (_type == kDbTypeDate)
    {
        return @"DATE";
    }
    else if (_type == kDbTypeDateTime)
    {
        return @"DATE";
    }
    else if (_type == kDbTypeTransformable)
    {
        return @"TEXT";
    }
    else
    {
        return nil;
    }
    //    if ([_type isEqualToString:@"Integer 16"] ||
    //        [_type isEqualToString:@"Integer 32"] ||
    //        [_type isEqualToString:@"Boolean"])
    //    {
    //        return @"INTEGER";
    //    }
    //    else if ([_type isEqualToString:@"Float"])
    //    {
    //        return @"NUMERIC";
    //    }
    //    else if ([_type isEqualToString:@"String"])
    //    {
    //        return @"TEXT";
    //    }
    //    else if ([_type isEqualToString:@"Date"])
    //    {
    //        return @"DATE";
    //    }
    //    else if ([_type isEqualToString:@"Transformable"])
    //    {
    //        return @"TEXT";
    //    }
    //    else
    //    {
    //        return nil;
    //    }
}

- (NSString *)createText
{
    if (self.key && self.autoIncrement)
    {
		return [NSString stringWithFormat:@"%@ %@ PRIMARY KEY ASC AUTOINCREMENT", self.sqlFieldName, [self typeText]];
    }
    else
    {
        NSString * typeText = self.typeText;
        if (!_optional)
        {
            if ([typeText isEqualToString:@"INTEGER"] || [typeText isEqualToString:@"NUMERIC"])
            {
                return [NSString stringWithFormat:@"%@ %@ NOT NULL DEFAULT '%@'", self.sqlFieldName, typeText, self.defaultValueString];
            }
            else
            {
                return [NSString stringWithFormat:@"%@ %@ NOT NULL", self.sqlFieldName, typeText];
            }
            
        }
        else
        {
            return [NSString stringWithFormat:@"%@ %@", self.sqlFieldName, typeText];
        }
    }
    
}

- (void)dealloc
{
    self.name = nil;
    self.defaultValueString = nil;
}

@end
