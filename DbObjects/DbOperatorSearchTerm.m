//
//  DbOperatorSearchTerm.m
//  DbObjects
//
//  Created by Qiang Huang on 6/2/15.
//  Copyright (c) 2015 Sudobility. All rights reserved.
//

#import "DbOperatorSearchTerm.h"
#import "DbObject.h"
#import "DbTable.h"

#import "DbDateUtils.h"

@implementation DbOperatorSearchTerm

+ (NSComparisonResult)compare:(NSObject *)value1 to:(NSObject *)value2 type:(EDbType)type
{
    switch (type)
    {
        case kDbTypeBoolean:
        case kDbTypeInt16:
        case kDbTypeInt32:
        case kDbTypeInt64:
        case kDbTypeFloat:
        {
            NSNumber * number1 = (NSNumber *)value1;
            NSNumber * number2 = (NSNumber *)value2;
            return [number1 compare:number2];
        }
            
        case kDbTypeDate:
        case kDbTypeDateTime:
        {
            NSDate * date1 = (NSDate *)value1;
            NSDate * date2 = (NSDate *)value2;
            long secs1 = [date1 timeIntervalSince1970];
            long secs2 = [date2 timeIntervalSince1970];
            long diff = secs2 - secs1;
            if (diff > 0)
            {
                return NSOrderedDescending;
            }
            else if (diff < 0)
            {
                return NSOrderedAscending;
            }
            else
            {
                return NSOrderedSame;
            }
        }
            
        case kDbTypeString:
        {
            NSString * string1 = (NSString *)value1;
            NSString * string2 = (NSString *)value2;
            return [string1 compare:string2];
        }
            
        default:
            return NSOrderedSame;
    }
}

+ (DbOperatorSearchTerm *)searchWhen:(NSString *)field op:(EDbCompare)op value:(id)value
{
    bool pass = false;
    switch (op)
    {
        case kDbEqualsTo:
        case kDbNotEqualTo:
            pass = ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSDate class]] || [value isKindOfClass:[NSString class]]);
            break;
            
        case kDbLargerThan:
        case kDbLargerThanOrEqualsTo:
        case kDbSmallerThan:
        case kDbSmallerThanOrEqualsTo:
            pass = ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSDate class]]);
            break;
            
        case kDbContains:
        case kDbNotContain:
        case kDbLike:
        case kDbNotLike:
            pass = ([value isKindOfClass:[NSString class]]);
            break;
            
        default:
            break;
    }
    if (pass)
    {
        return [[DbOperatorSearchTerm alloc] initWithField:field op:op value:value];
    }
    return nil;
}

- (id)initWithField:(NSString *)field op:(EDbCompare)op value:(id)value
{
    if (self = [super init])
    {
        self.field = field;
        self.op = op;
        self.value = value;
        return self;
    }
    return nil;
}

- (NSString *)asString
{
    switch (_op)
    {
        case kDbEqualsTo:
            return [NSString stringWithFormat:@"%@ = '%@'", _field, self.valueString];
            
        case kDbNotEqualTo:
            return [NSString stringWithFormat:@"%@ != '%@'", _field, self.valueString];
            
        case kDbLargerThan:
            return [NSString stringWithFormat:@"%@ > '%@'", _field, self.valueString];
            
        case kDbLargerThanOrEqualsTo:
            return [NSString stringWithFormat:@"%@ >= '%@'", _field, self.valueString];
            
        case kDbSmallerThan:
            return [NSString stringWithFormat:@"%@ < '%@'", _field, self.valueString];
            
        case kDbSmallerThanOrEqualsTo:
            return [NSString stringWithFormat:@"%@ <= '%@'", _field, self.valueString];
            
        case kDbContains:
            return [NSString stringWithFormat:@"%@ CONTAIN '%@'", _field, self.valueString];
            
        case kDbNotContain:
            return [NSString stringWithFormat:@"%@ NOT CONTAIN '%@'", _field, self.valueString];
            
        case kDbLike:
            return [NSString stringWithFormat:@"%@ LIKE '%@'", _field, self.valueString];
            
        case kDbNotLike:
            return [NSString stringWithFormat:@"%@ NOT LIKE '%@'", _field, self.valueString];
            
        default:
            break;
    }
}

- (NSString *)valueString
{
    if ([_value isKindOfClass:[NSDate class]])
    {
        NSDate * date = (NSDate *)_value;
        return [DbDateUtils datetimeToGmtSqliteString:date];
    }
    else
    {
        return [NSString stringWithFormat:@"%@", _value];
    }
}

- (bool)satisfy:(DbObject *)obj
{
    if (_field && _value && obj.verifyTable)
    {
        DbField * field = [obj.table fieldWithName:_field];
        if (field)
        {
            NSObject * value = [obj valueForKey:_field];
            if (value)
            {
                switch (_op)
                {
                    case kDbEqualsTo:
                        return [DbOperatorSearchTerm compare:_value to:value type:field.type] == NSOrderedSame;
                        
                    case kDbNotEqualTo:
                        return [DbOperatorSearchTerm compare:_value to:value type:field.type] != NSOrderedSame;
                        
                    case kDbLargerThan:
                        return [DbOperatorSearchTerm compare:_value to:value type:field.type] == NSOrderedAscending;
                        
                    case kDbLargerThanOrEqualsTo:
                        return [DbOperatorSearchTerm compare:_value to:value type:field.type] != NSOrderedDescending;
                        
                    case kDbSmallerThan:
                        return [DbOperatorSearchTerm compare:_value to:value type:field.type] == NSOrderedDescending;
                        
                    case kDbSmallerThanOrEqualsTo:
                        return [DbOperatorSearchTerm compare:_value to:value type:field.type] != NSOrderedAscending;
                        
                    case kDbContains:
                        return [self string:(NSString *)value contains:(NSString *)_value];
                        
                    case kDbNotContain:
                        return ![self string:(NSString *)value contains:(NSString *)_value];
                        
                    case kDbLike:
                        return [self string:(NSString *)value like:(NSString *)_value];
                        
                    case kDbNotLike:
                        return ![self string:(NSString *)value like:(NSString *)_value];
                }
            }
        }
    }
    return false;
}

- (bool)string:(NSString *)string1 contains:(NSString *)string2
{
    NSRange range = [string1 rangeOfString:string2];
    return range.location != NSNotFound;
}

- (bool)string:(NSString *)string1 like:(NSString *)string2
{
    NSArray * elements = [string2 componentsSeparatedByString:@"%"];
    bool pass = true;
    for (int i = 0; pass && i < elements.count; i ++)
    {
        NSString * element = elements[i];
        if (i == 0)
        {
            pass = [string1 hasPrefix:element];
            if (pass)
            {
                string1 = [string1 substringFromIndex:element.length];
            }
        }
        else
        {
            NSRange range = [string1 rangeOfString:element];
            pass = range.location != NSNotFound;
            if (pass)
            {
                string1 = [string1 substringFromIndex:range.location + range.length];
            }
        }
    }
    if (pass)
    {
        pass = string1.length == 0;
    }
    return pass;
}

- (void)dealloc
{
    self.field = nil;
    self.value = nil;
}
@end
