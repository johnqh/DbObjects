//
//  DbObject.m
//  DbBridge
//
//  Created by John Huang on 3/18/14.
//  Copyright (c) 2014 John Huang. All rights reserved.
//

#import "DbObject.h"
#import "DbDatabase.h"
#import "DbTable.h"
#import "DbField.h"
#import "DbQuery.h"
#import "DbObjectUtils.h"
#import "DbDateUtils.h"
#import "DbObjectCache.h"

@interface DbObject()
{
    bool _saved;
    NSMutableDictionary * _writeData;
}

@end

@implementation DbObject

+ (NSComparisonResult)compare:(NSObject *)value1 to:(NSObject *)value2
{
    if (value1)
    {
        if (value2)
        {
            if ([value1 isKindOfClass:[NSNumber class]])
            {
                NSNumber * number1 = (NSNumber *)value1;
                NSNumber * number2 = (NSNumber *)value2;
                return [number1  compare:number2];
            }
            else if ([value1 isKindOfClass:[NSString class]])
            {
                NSString * string1 = (NSString *)value1;
                NSString * string2 = (NSString *)value2;
                return [string1  compare:string2];
            }
            else if ([value1 isKindOfClass:[NSDate class]])
            {
                NSDate * date1 = (NSDate *)value1;
                NSDate * date2 = (NSDate *)value2;
                return [date1  compare:date2];
            }
            else
            {
                return NSOrderedSame;
            }
        }
        else
        {
            return NSOrderedDescending;
        }
    }
    else
    {
        if (value2)
        {
            return NSOrderedAscending;
        }
        else
        {
            return NSOrderedSame;
        }
    }
}

- (NSMutableDictionary *)writeData
{
    return _writeData;
}

- (void)setWriteData:(NSMutableDictionary *)writeData
{
    if (_writeData != writeData)
    {
        _writeData = writeData;
        if (_db) // not from dealloc
        {
            if (_writeData)
            {
                if (_saved) // already in memory, so search in collections
                {
                    [self.db.cache markInCache:self];
                }
            }
            else
            {
                if (_saved)
                {
                    
                }
                else
                {
                    // deleted
                }
            }
        }
    }
}

- (bool)saved
{
    return _saved;
}

- (void)setSaved:(bool)saved
{
    if (_saved != saved)
    {
        if (_saved)
        {
            [self.db.cache markInCache:self];
        }
        _saved = saved;
        if (saved)
        {
            if (_writeData)
            {
                if (!_readData)
                {
                    self.readData = [NSMutableDictionary dictionaryWithCapacity:self.table.fields.count];
                }
                for (NSString * fieldName in _writeData)
                {
                    NSString * value = [_writeData objectForKey:fieldName];
                    [_readData setObject:value forKey:fieldName];
                }
            }
            self.writeData = nil;
            [self.db.cache saveToCache:self];
        }
        else
        {
            [self.db.cache removeFromCache:self];
            if (_readData)
            {
                if (!_writeData)
                {
                    self.writeData = [NSMutableDictionary dictionaryWithCapacity:self.table.fields.count];
                }
                for (NSString * fieldName in _readData)
                {
                    NSString * value = [_readData objectForKey:fieldName];
                    [_writeData setObject:value forKey:fieldName];
                }
            }
            self.readData = nil;
        }
    }
    else
    {
        if (_writeData)
        {
            if (_saved)
            {
                [self.db.cache markInCache:self];
            }
            if (!_readData)
            {
                self.readData = [NSMutableDictionary dictionaryWithCapacity:self.table.fields.count];
            }
            for (NSString * fieldName in _writeData)
            {
                NSString * value = [_writeData objectForKey:fieldName];
                [_readData setObject:value forKey:fieldName];
            }
            self.writeData = nil;
            [self.db.cache updateCache:self];
        }
    }
}

- (bool)isCollection
{
    return false;
}

- (id)initWithDb:(DbDatabase *)db
{
    if (self = [super init])
    {
        self.db = db;
        return self;
    }
    return nil;
}

- (DbTable *)verifyTable
{
    if (!_table && _db)
    {
        self.table = [_db.tables objectForKey:NSStringFromClass(self.class)];
    }
    return _table;
}

- (bool)sameValue:(NSString *)value1 with:(NSString *)value2
{
    if (value1 && ![value1 isEqualToString:@""])
    {
        return [value1 isEqualToString:value2];
    }
    else if (value2 && ![value2 isEqualToString:@""])
    {
        return false;
    }
    else
    {
        return true;
    }
    
}

- (bool)setPrivate:(NSString *)fieldName data:(NSString *)data
{
    if (self.verifyTable)
    {
        NSString * existing = [self getPrivate:fieldName];
        if (!_readData || ![self sameValue:existing with:data])
        {
            bool mainThread = [NSThread isMainThread];
            if (mainThread)
            {
                [self willChangeValueForKey:fieldName];
            }
            if (!_writeData)
            {
                self.writeData = [NSMutableDictionary dictionaryWithCapacity:self.table.fields.count];
            }
            
            if (data.length == 0)
            {
                data = nil;
            }
            [_writeData setObject:(data ? data : [NSNull null]) forKey:[DbObjectUtils sqlFieldName:fieldName]];
            if (mainThread)
            {
                [self didChangeValueForKey:fieldName];
            }
            return true;
        }
    }
    return false;
}

- (NSString *)getPrivate:(NSString *)fieldName
{
    id value = nil;
	if (_writeData)
	{
		value = [_writeData objectForKey:[DbObjectUtils sqlFieldName:fieldName]];
	}
    if (!value)
    {
        if (_readData)
        {
            value = [_readData objectForKey:[DbObjectUtils sqlFieldName:fieldName]];
        }
    }
    if (!value)
    {
        value = [self getDerived:fieldName];
    }
	return [value isKindOfClass:[NSString class]] ? value : nil;
}

- (NSString *)getDerived:(NSString *)fieldName
{
    return nil;
}

- (NSNumber *)boolForKey:(NSString *)fieldName
{
    NSString * value = [self getPrivate:fieldName];
    return value ? [NSNumber numberWithBool:[value isEqualToString:@"1"]] : nil;
}

- (void)setBool:(NSNumber *)value forKey:(NSString *)fieldName
{
    [self setPrivate:fieldName data:value ? value.stringValue : nil];
}

- (NSNumber *)int16ForKey:(NSString *)fieldName
{
    NSString * value = [self getPrivate:fieldName];
    return value ? [NSNumber numberWithInt:[value intValue]] : nil;
}

- (void)setInt16:(NSNumber *)value forKey:(NSString *)fieldName
{
    [self setPrivate:fieldName data:value ? value.stringValue : nil];
}

- (NSNumber *)int32ForKey:(NSString *)fieldName
{
    NSString * value = [self getPrivate:fieldName];
    return value ? [NSNumber numberWithInt:[value intValue]] : nil;
}

- (void)setInt32:(NSNumber *)value forKey:(NSString *)fieldName
{
    [self setPrivate:fieldName data:value ? value.stringValue : nil];
}

- (NSNumber *)int64ForKey:(NSString *)fieldName
{
    NSString * value = [self getPrivate:fieldName];
    return value ? [NSNumber numberWithLongLong:[value longLongValue]] : nil;
}

- (void)setInt64:(NSNumber *)value forKey:(NSString *)fieldName
{
    [self setPrivate:fieldName data:value ? value.stringValue : nil];
}

- (NSNumber *)floatForKey:(NSString *)fieldName
{
    NSString * value = [self getPrivate:fieldName];
    return value ? [NSNumber numberWithDouble:[value floatValue]] : nil;
}

- (void)setFloat:(NSNumber *)value forKey:(NSString *)fieldName
{
    [self setPrivate:fieldName data:value ? value.stringValue : nil];
}

- (NSString *)stringForKey:(NSString *)fieldName
{
    NSString * value = [self getPrivate:fieldName];
    return value;
}

- (void)setString:(NSString *)value forKey:(NSString *)fieldName
{
    [self setPrivate:fieldName data:value];
}

- (NSDate *)dateForKey:(NSString *)fieldName
{
    NSString * value = [self getPrivate:fieldName];
    return value ? [DbDateUtils dateFromSqliteString:value] : nil;
}

- (void)setDate:(NSDate *)value forKey:(NSString *)fieldName
{
    [self setPrivate:fieldName data:[DbDateUtils dateToSqliteString:value]];
}

- (NSDate *)dateTimeForKey:(NSString *)fieldName
{
    NSString * value = [self getPrivate:fieldName];
    return value ? [DbDateUtils datetimeFromGmtSqliteString:value] : nil;
}

- (void)setDateTime:(NSDate *)value forKey:(NSString *)fieldName
{
    [self setPrivate:fieldName data:[DbDateUtils datetimeToGmtSqliteString:value]];
}

- (NSObject *)valueForKey:(NSString *)fieldName
{
    if (self.verifyTable)
    {
        DbField * field = [_table fieldWithName:fieldName];
        
        switch (field.type)
        {
            case kDbTypeBoolean:
                return [self boolForKey:fieldName];
                
            case kDbTypeDate:
                return [self dateForKey:fieldName];
                
            case kDbTypeDateTime:
                return [self dateTimeForKey:fieldName];
                
            case kDbTypeFloat:
                return [self floatForKey:fieldName];
                
            case kDbTypeInt16:
                return [self int16ForKey:fieldName];
                
            case kDbTypeInt32:
                return [self int32ForKey:fieldName];
                
            case kDbTypeInt64:
                return [self int64ForKey:fieldName];
                
            case kDbTypeString:
                return [self stringForKey:fieldName];
                
            default:
                return nil;
        }
    }
    return nil;
}

- (void)refresh:(DbObject *)obj
{
    // forcing KVO key change
    self.readData = [NSMutableDictionary dictionary];
    self.writeData = [NSMutableDictionary dictionary];
    for (NSString * key in obj.readData)
    {
        id readValue = obj.readData[key];
        id writeValue = obj.writeData[key];
        if (!writeValue)
        {
            [self setPrivate:key data:readValue];
        }
    }
    self.readData = self.writeData;
    
    self.writeData = [NSMutableDictionary dictionary];
    for (NSString * key in obj.writeData)
    {
        id writeValue = obj.writeData[key];
        [self setPrivate:key data:writeValue];
    }
    self.saved = obj.saved;
}

- (void)fillDefaults
{
    for (NSString * fieldName in _table.fields)
    {
        DbField * field = _table.fields[fieldName];
        if (!field.optional)
        {
            if (field.defaultValueString)
            {
                if (![self getPrivate:field.name])
                {
                    [self setPrivate:field.name data:field.defaultValueString];
                }
            }
        }
    }
}

- (id)loadFromDb
{
    DbQuery * query = _db.query;
    return [query loadObject:self];
}

- (void)saveToDb
{
    [self fillDefaults];
    DbQuery * query = _db.query;
    [query saveObject:self];
}

- (void)removeFromDb
{
    DbQuery * query = _db.query;
    [query removeObject:self];
}

- (void)revert
{
    self.writeData = nil;
}

- (void)delayedSave
{
    [self performSelector:@selector(saveToDb) withObject:nil afterDelay:0];
}

- (void)delayedRemove
{
    [self performSelector:@selector(removeFromDb) withObject:nil afterDelay:0];
}

- (NSString *)idText:(NSDictionary *)data
{
    NSMutableString * whereString = [[NSMutableString alloc] initWithCapacity:128];
    bool hasData = false;
    bool missingData = false;
    
    NSArray * fieldNames = _table.fields.allKeys;
    for (int i = 0; !missingData && i < fieldNames.count; i ++)
    {
        NSString * fieldName = [fieldNames objectAtIndex:i];
        DbField * field = [_table.fields objectForKey:fieldName];
        if (field.key)
        {
            NSString * value = [data objectForKey:fieldName];
            
            if (value)
            {
                if (hasData)
                {
                    [whereString appendString:@" AND "];
                }
                else
                {
                    [whereString appendString:@"WHERE "];
                    hasData = true;
                }
                [whereString appendString:@" "];
                [whereString appendString:fieldName];
                
                NSString * valueText = nil;
                if ([value isKindOfClass:[NSString class]])
                {
                    if (field.type == kDbTypeString)
                    {
                        valueText = [_db.query sqlEncode:value];
                    }
                    else
                    {
                        valueText = value;
                    }
                }
                if (valueText)
                {
                    [whereString appendString:@" = "];
                    [whereString appendString:@"'"];
                    [whereString appendString:valueText];
                    [whereString appendString:@"'"];
                }
                else
                {
                    [whereString appendString:@" is "];
                    [whereString appendString:@"NULL"];
                }
                //    [whereString appendFormat:@" %@ = '%@'", fieldName, [_db.query sqlEncode:value]];
            }
            else
            {
                missingData = true;
            }
        }
    }
    return (missingData || !hasData) ? nil : whereString;
}

- (NSString *)whereClause
{
    NSMutableDictionary * data = _saved ? _readData : _writeData;
	if (data && [self verifyTable])
	{
		NSString * idText = [self idText:data];
		if (idText)
		{
			return idText;
		}
		else
		{
            NSMutableString * whereString = [[NSMutableString alloc] initWithCapacity:128];
            bool hasData = false;
            
            
            for (NSString * fieldName in data)
            {
                DbField * field = [_table.fields objectForKey:fieldName];
                NSString * value = [data objectForKey:fieldName];
                
                if (hasData)
                {
                    [whereString appendString:@" AND "];
                }
                else
                {
                    [whereString appendString:@"WHERE "];
                    hasData = true;
                }
                [whereString appendString:fieldName];
                
                NSString * valueText = nil;
                if ([value isKindOfClass:[NSString class]])
                {
                    if (field.type == kDbTypeString)
                    {
                        valueText = [_db.query sqlEncode:value];
                    }
                    else
                    {
                        valueText = value;
                    }
                }
                if (valueText)
                {
                    [whereString appendString:@" = "];
                    [whereString appendString:@"'"];
                    [whereString appendString:valueText];
                    [whereString appendString:@"'"];
                }
                else
                {
                    [whereString appendString:@" is "];
                    [whereString appendString:@"NULL"];
                }
                //    [whereString appendFormat:@" %@ = '%@'", fieldName, [_db.query sqlEncode:value]];
            }
            return whereString;
		}
	}
	return nil;
}

- (NSString *)keyValue
{
    NSString * keyField = self.keyField;
    if (keyField)
    {
        return [self getPrivate:keyField];
    }
    return nil;
}

- (NSString *)keyField
{
    NSString * found = nil;
    if ([self verifyTable])
    {
        for (int i = 0; !found && i < self.table.fields.allKeys.count; i ++)
        {
            NSString * fieldName = self.table.fields.allKeys[i];
            DbField * field = self.table.fields[fieldName];
            if (field.key)
            {
                found = fieldName;
            }
        }
    }
    return found;
}

- (bool)modified
{
    return _writeData && _writeData.count != 0;
}

- (NSString *)modifiedFields:(bool)wantsFields data:(bool)wantsData
{
    
    if (_writeData && _writeData.count)
    {
        NSMutableString * builder = [[NSMutableString alloc] initWithCapacity:128];
        bool hasData = false;
        for (NSString * fieldName in _writeData)
        {
            if (hasData)
            {
                [builder appendString:@", "];
            }
            else
            {
                hasData = true;
            }
            if (wantsFields)
            {
                [builder appendString:fieldName];
            }
            
            if (wantsData)
            {
                if (wantsFields)
                {
                    [builder appendString:@" = "];
                }
                DbField * field = [_table.fields objectForKey:fieldName];
                id value = _writeData[fieldName];
                NSString * valueText = nil;
                if ([value isKindOfClass:[NSString class]])
                {
                    if (field.type == kDbTypeString)
                    {
                        valueText = [_db.query sqlEncode:value];
                    }
                    else
                    {
                        valueText = value;
                    }
                }
                if (valueText)
                {
                    [builder appendString:@"'"];
                    [builder appendString:valueText];
                    [builder appendString:@"'"];
                    //    [builder appendFormat:@"'%@'", valueText];
                }
                else
                {
                    [builder appendString:@"NULL"];
                }
            }
        }
        return builder;
    }
    return nil;
}

- (NSString *)modifiedFields
{
    return [self modifiedFields:true data:false];
}

- (NSString *)modifiedData
{
    return [self modifiedFields:false data:true];
}

- (NSString *)modifiedFieldsAndData
{
    return [self modifiedFields:true data:true];
}

- (DbObject *)cached:(NSString *)keyValue
{
    if (keyValue)
    {
        return [self.db.cache cachedObject:NSStringFromClass(self.class) keyValue:keyValue];
    }
    return nil;
}

- (DbObject *)cachedOrMe:(NSString *)keyValue
{
    DbObject * obj = [self cached:keyValue];
    if (obj)
    {
        return obj;
    }
    else
    {
        return self;
    }
}

- (void)dealloc
{
    self.db = nil;
    self.table = nil;
    self.readData = nil;
    self.writeData = nil;
}

@end
