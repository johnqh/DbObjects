//
//  DbTable.m
//  DbBridge
//
//  Created by John Huang on 3/18/14.
//  Copyright (c) 2014 John Huang. All rights reserved.
//

#import "DbTable.h"
#import "DbConfiguration.h"
#import "DbField.h"
#import "DbIndex.h"
#import "DbObject.h"
#import "DbObjectUtils.h"
#import "DbDateUtils.h"
#import "DictionaryUtils.h"

#import <objc/runtime.h>
#import "NSString+Utils.h"


@implementation DbTable



// string property

static NSString * stringPropertyImp(DbObject * self, SEL _cmd)
{
    NSString * fieldName = [DbObjectUtils fieldNameFromGetter:_cmd];
    return [self stringForKey:fieldName];
}

static void setStringPropertyImp(DbObject * self, SEL _cmd, NSString * value)
{
    NSString * fieldName = [DbObjectUtils fieldNameFromSetter:_cmd];
    [self setString:value forKey:fieldName];
}

// bool property

static NSNumber * booleanPropertyImp(DbObject * self, SEL _cmd)
{
    NSString * fieldName = [DbObjectUtils fieldNameFromGetter:_cmd];
    return [self boolForKey:fieldName];
}

static void setBooleanPropertyImp(DbObject * self, SEL _cmd, NSNumber * value)
{
    NSString * fieldName = [DbObjectUtils fieldNameFromSetter:_cmd];
    [self setBool:value forKey:fieldName];
}

// int16 property

static NSNumber * int16PropertyImp(DbObject * self, SEL _cmd)
{
    NSString * fieldName = [DbObjectUtils fieldNameFromGetter:_cmd];
    return [self int16ForKey:fieldName];
}

static void setInt16PropertyImp(DbObject * self, SEL _cmd, NSNumber * value)
{
    NSString * fieldName = [DbObjectUtils fieldNameFromSetter:_cmd];
    [self setInt16:value forKey:fieldName];
}

// int32 property

static NSNumber * int32PropertyImp(DbObject * self, SEL _cmd)
{
    NSString * fieldName = [DbObjectUtils fieldNameFromGetter:_cmd];
    return [self int32ForKey:fieldName];
}

static void setInt32PropertyImp(DbObject * self, SEL _cmd, NSNumber * value)
{
    NSString * fieldName = [DbObjectUtils fieldNameFromSetter:_cmd];
    [self setInt32:value forKey:fieldName];
}

// int64 property

static NSNumber * int64PropertyImp(DbObject * self, SEL _cmd)
{
    NSString * fieldName = [DbObjectUtils fieldNameFromGetter:_cmd];
    return [self int64ForKey:fieldName];
}

static void setInt64PropertyImp(DbObject * self, SEL _cmd, NSNumber * value)
{
    NSString * fieldName = [DbObjectUtils fieldNameFromSetter:_cmd];
    [self setInt64:value forKey:fieldName];
}

// float property

static NSNumber * floatPropertyImp(DbObject * self, SEL _cmd)
{
    NSString * fieldName = [DbObjectUtils fieldNameFromGetter:_cmd];
    return [self floatForKey:fieldName];
}

static void setFloatPropertyImp(DbObject * self, SEL _cmd, NSNumber * value)
{
    NSString * fieldName = [DbObjectUtils fieldNameFromSetter:_cmd];
    [self setFloat:value forKey:fieldName];
}

// date property

static NSDate * datePropertyImp(DbObject * self, SEL _cmd)
{
    NSString * fieldName = [DbObjectUtils fieldNameFromGetter:_cmd];
    return [self dateForKey:fieldName];
}

static void setDatePropertyImp(DbObject * self, SEL _cmd, NSDate * value)
{
    NSString * fieldName = [DbObjectUtils fieldNameFromSetter:_cmd];
    [self setDate:value forKey:fieldName];
}

// time property

static NSDate * dateTimePropertyImp(DbObject * self, SEL _cmd)
{
    NSString * fieldName = [DbObjectUtils fieldNameFromGetter:_cmd];
    return [self dateTimeForKey:fieldName];
}

static void setDateTimePropertyImp(DbObject * self, SEL _cmd, NSDate * value)
{
    NSString * fieldName = [DbObjectUtils fieldNameFromSetter:_cmd];
    [self setDateTime:value forKey:fieldName];
}

// transform property

static NSData * transformablePropertyImp(DbObject * self, SEL _cmd)
{
    NSString * fieldName = [DbObjectUtils fieldNameFromGetter:_cmd];
    NSString * value = [self getPrivate:fieldName];
    return value ? [value dataUsingEncoding:NSUTF8StringEncoding] : nil;
}

static void setTransformablePropertyImp(DbObject * self, SEL _cmd, NSData * value)
{
    NSString * fieldName = [DbObjectUtils fieldNameFromSetter:_cmd];
    
    NSString * dataString = [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];
    [self setPrivate:fieldName data:dataString];
}


- (id)initWithDb:(DbDatabase *)db
{
    if (self = [super init])
    {
        self.db = db;
        self.fields = [NSMutableDictionary dictionary];
        self.indice = [NSMutableDictionary dictionary];
        return self;
    }
    return nil;
}

// sample: <entity name="Address" representedClassName="Address" syncable="YES">
- (id)initWithDb:(DbDatabase *)db Schema:(NSDictionary *)dictionary
{
    if (self = [super init])
    {
        self.db = db;
        self.name = [dictionary objectForKey:@"name"];
        self.className = [dictionary objectForKey:@"representedClassName"];
        self.syncable = [[dictionary objectForKey:@"syncable"] isEqualToString:@"YES"];
        self.fields = [NSMutableDictionary dictionary];
        self.indice = [NSMutableDictionary dictionary];
        NSArray * fields = [DictionaryUtils asArray:dictionary[@"attribute"]];
        NSArray * indice = [DictionaryUtils asArray:dictionary[@"index"]];
        [self parseFields:fields];
        [self parseIndice:indice];
        [self populateObjectMethods];
        return self;
    }
    return nil;
}

- (void)parseFields:(NSArray *)fields
{
    if (fields)
    {
        for (NSDictionary * attributes in fields)
        {
            NSString * platform = attributes[@"Platform"];
            bool pass = platform ? [platform contains:[DbConfiguration singleton].platform] : true;
            if (pass)
            {
                DbField * field = [[DbField alloc] initWithSchema:attributes];
                [_fields setObject:field forKey:field.sqlFieldName];
            }
        }
    }
}

- (void)parseIndice:(NSArray *)indice
{
    if (indice)
    {
        for (NSDictionary * attributes in indice)
        {
            NSString * platform = attributes[@"Platform"];
            bool pass = platform ? [platform contains:[DbConfiguration singleton].platform] : true;
            if (pass)
            {
                DbIndex * index = [[DbIndex alloc] initWithSchema:attributes];
                [_indice setObject:index forKey:index.name];
            }
        }
    }
}

- (void)populateObjectMethods
{
    Class class = NSClassFromString(_className);
    for (NSString * fieldName in _fields)
    {
        DbField * field = [_fields objectForKey:fieldName];
        if (field.type == kDbTypeString) // string
        {
            SEL getter = NSSelectorFromString(field.name);
            class_addMethod(class, getter, (IMP)stringPropertyImp, "@@:");
            
            NSString * setterName = [DbObjectUtils setterFromFieldName:field.name];
            SEL setter = NSSelectorFromString(setterName);
            class_addMethod(class, setter, (IMP)setStringPropertyImp, "v@:@");
        }
        else if (field.type  == kDbTypeBoolean) // boolean
        {
            SEL getter = NSSelectorFromString(field.name);
            class_addMethod(class, getter, (IMP)booleanPropertyImp, "@@:");
            
            NSString * setterName = [DbObjectUtils setterFromFieldName:field.name];
            SEL setter = NSSelectorFromString(setterName);
            class_addMethod(class, setter, (IMP)setBooleanPropertyImp, "v@:@");
        }
        else if (field.type == kDbTypeInt16) // int 16
        {
            SEL getter = NSSelectorFromString(field.name);
            class_addMethod(class, getter, (IMP)int16PropertyImp, "@@:");
            
            NSString * setterName = [DbObjectUtils setterFromFieldName:field.name];
            SEL setter = NSSelectorFromString(setterName);
            class_addMethod(class, setter, (IMP)setInt16PropertyImp, "v@:@");
        }
        else if (field.type == kDbTypeInt32) // int 32
        {
            SEL getter = NSSelectorFromString(field.name);
            class_addMethod(class, getter, (IMP)int32PropertyImp, "@@:");
            
            NSString * setterName = [DbObjectUtils setterFromFieldName:field.name];
            SEL setter = NSSelectorFromString(setterName);
            class_addMethod(class, setter, (IMP)setInt32PropertyImp, "v@:@");
        }
        else if (field.type == kDbTypeInt64) // int 64
        {
            SEL getter = NSSelectorFromString(field.name);
            class_addMethod(class, getter, (IMP)int64PropertyImp, "@@:");
            
            NSString * setterName = [DbObjectUtils setterFromFieldName:field.name];
            SEL setter = NSSelectorFromString(setterName);
            class_addMethod(class, setter, (IMP)setInt64PropertyImp, "v@:@");
        }
        else if (field.type == kDbTypeFloat) // float
        {
            SEL getter = NSSelectorFromString(field.name);
            class_addMethod(class, getter, (IMP)floatPropertyImp, "@@:");
            
            NSString * setterName = [DbObjectUtils setterFromFieldName:field.name];
            SEL setter = NSSelectorFromString(setterName);
            class_addMethod(class, setter, (IMP)setFloatPropertyImp, "v@:@");
        }
        else if (field.type == kDbTypeDate) // date
        {
            SEL getter = NSSelectorFromString(field.name);
            class_addMethod(class, getter, (IMP)datePropertyImp, "@@:");
            
            NSString * setterName = [DbObjectUtils setterFromFieldName:field.name];
            SEL setter = NSSelectorFromString(setterName);
            class_addMethod(class, setter, (IMP)setDatePropertyImp, "v@:@");
        }
        else if (field.type == kDbTypeDateTime) // date
        {
            SEL getter = NSSelectorFromString(field.name);
            class_addMethod(class, getter, (IMP)dateTimePropertyImp, "@@:");
            
            NSString * setterName = [DbObjectUtils setterFromFieldName:field.name];
            SEL setter = NSSelectorFromString(setterName);
            class_addMethod(class, setter, (IMP)setDateTimePropertyImp, "v@:@");
        }
        else if (field.type == kDbTypeTransformable) // transformable
        {
            SEL getter = NSSelectorFromString(field.name);
            class_addMethod(class, getter, (IMP)transformablePropertyImp, "@@:");
            
            NSString * setterName = [DbObjectUtils setterFromFieldName:field.name];
            SEL setter = NSSelectorFromString(setterName);
            class_addMethod(class, setter, (IMP)setTransformablePropertyImp, "v@:@");
        }
        else
        {
            NSLog(@"Error:%@", @"Unknown type in database schema");
        }
    }
    
}


- (DbField *)fieldWithName:(NSString *)name
{
    return [_fields objectForKey:name];
}

- (DbField *)autoIncrementField
{
    DbField * found = nil;
    
    NSArray * keys = [_fields allKeys];
    for (int i = 0; !found && i < keys.count; i ++)
    {
        NSString * key = keys[i];
        DbField * field = _fields[key];
        if (field.key && field.autoIncrement)
        {
            found = field;
        }
    }
    return found;
}

- (NSString *)fieldNames
{
    NSArray * keys = [_fields allKeys];
    if ([keys count])
    {
        NSMutableString * builder = [[NSMutableString alloc] initWithCapacity:128];
        for (int i = 0; i < [keys count]; i ++)
        {
            if (i != 0)
            {
                [builder appendString:@", "];
            }
            [builder appendString:[keys objectAtIndex:i]];
        }
        return builder;
    }
	return @"*";
}

- (void)dealloc
{
    self.db = nil;
    self.fields = nil;
    self.indice = nil;
    self.name = nil;
    self.className = nil;
}

@end
