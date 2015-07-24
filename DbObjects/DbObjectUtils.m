//
//  DbObjectUtils.m
//  DbBridge
//
//  Created by John Huang on 3/18/14.
//  Copyright (c) 2014 John Huang. All rights reserved.
//

#import "DbObjectUtils.h"

static NSMutableDictionary * _getterCache = nil;
static NSMutableDictionary * _setterCache = nil;

@implementation DbObjectUtils

+ (NSSet *)reservedKeywords
{
    static NSSet *_reservedKeywords;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray * reserved = @[
                              @"ABORT",
                              @"ACTION",
                              @"ADD",
                              @"AFTER",
                              @"ALL",
                              @"ALTER",
                              @"ANALYZE",
                              @"AND",
                              @"AS",
                              @"ASC",
                              @"ATTACH",
                              @"AUTOINCREMENT",
                              @"BEFORE",
                              @"BEGIN",
                              @"BETWEEN",
                              @"BY",
                              @"CASCADE",
                              @"CASE",
                              @"CAST",
                              @"CHECK",
                              @"COLLATE",
                              @"COLUMN",
                              @"COMMIT",
                              @"CONFLICT",
                              @"CONSTRAINT",
                              @"CREATE",
                              @"CROSS",
                              @"CURRENT_DATE",
                              @"CURRENT_TIME",
                              @"CURRENT_TIMESTAMP",
                              @"DATABASE",
                              @"DEFAULT",
                              @"DEFERRABLE",
                              @"DEFERRED",
                              @"DELETE",
                              @"DESC",
                              @"DETACH",
                              @"DISTINCT",
                              @"DROP",
                              @"EACH",
                              @"ELSE",
                              @"END",
                              @"ESCAPE",
                              @"EXCEPT",
                              @"EXCLUSIVE",
                              @"EXISTS",
                              @"EXPLAIN",
                              @"FAIL",
                              @"FOR",
                              @"FOREIGN",
                              @"FROM",
                              @"FULL",
                              @"GLOB",
                              @"GROUP",
                              @"HAVING",
                              @"IF",
                              @"IGNORE",
                              @"IMMEDIATE",
                              @"IN",
                              @"INDEX",
                              @"INDEXED",
                              @"INITIALLY",
                              @"INNER",
                              @"INSERT",
                              @"INSTEAD",
                              @"INTERSECT",
                              @"INTO",
                              @"IS",
                              @"ISNULL",
                              @"JOIN",
                              @"KEY",
                              @"LEFT",
                              @"LIKE",
                              @"LIMIT",
                              @"MATCH",
                              @"NATURAL",
                              @"NO",
                              @"NOT",
                              @"NOTNULL",
                              @"NULL",
                              @"OF",
                              @"OFFSET",
                              @"ON",
                              @"OR",
                              @"ORDER",
                              @"OUTER",
                              @"PLAN",
                              @"PRAGMA",
                              @"PRIMARY",
                              @"QUERY",
                              @"RAISE",
                              @"RECURSIVE",
                              @"REFERENCES",
                              @"REGEXP",
                              @"REINDEX",
                              @"RELEASE",
                              @"RENAME",
                              @"REPLACE",
                              @"RESTRICT",
                              @"RIGHT",
                              @"ROLLBACK",
                              @"ROW",
                              @"SAVEPOINT",
                              @"SELECT",
                              @"SET",
                              @"TABLE",
                              @"TEMP",
                              @"TEMPORARY",
                              @"THEN",
                              @"TO",
                              @"TRANSACTION",
                              @"TRIGGER",
                              @"UNION",
                              @"UNIQUE",
                              @"UPDATE",
                              @"USING",
                              @"VACUUM",
                              @"VALUES",
                              @"VIEW",
                              @"VIRTUAL",
                              @"WHEN",
                              @"WHERE",
                              @"WITH",
                              @"WITHOUT"];
        NSMutableArray * lowercase = [NSMutableArray array];
        for (NSString * keyword in reserved)
        {
            [lowercase addObject:keyword.lowercaseString];
        }
        _reservedKeywords = [NSSet setWithArray:lowercase];
    });
    return _reservedKeywords;
}

+ (NSString *)setterFromFieldName:(NSString *)fieldName
{
    NSString * firstChar = [fieldName substringToIndex:1];
    NSString * afterFirst = [fieldName substringFromIndex:1];
    return [NSString stringWithFormat:@"set%@%@:", firstChar.uppercaseString, afterFirst];
    
}

+ (NSString *)fieldNameFromGetter:(SEL)getter
{
    NSString * getterName = NSStringFromSelector(getter);
    if (!_getterCache)
    {
        _getterCache = [NSMutableDictionary dictionary];
    }
    NSString * fieldName = _getterCache[getterName];
    if (!fieldName)
    {
        fieldName = [self sqlFieldName:getterName];
        [_getterCache setObject:fieldName forKey:getterName];
    }
    return fieldName;
    
}

+ (NSString *)fieldNameFromSetter:(SEL)selector
{
    NSString * setterName = NSStringFromSelector(selector);
    if (!_setterCache)
    {
        _setterCache = [NSMutableDictionary dictionary];
    }
    NSString * fieldName = _setterCache[setterName];
    if (!fieldName)
    {
        NSString * partialName = [setterName substringWithRange:NSMakeRange(3, setterName.length - 4)];
        fieldName = [self sqlFieldName:partialName];
        [_setterCache setObject:fieldName forKey:setterName];
    }
    return fieldName;
}

+ (NSString *)sqlFieldName:(NSString *)fieldName
{
    NSSet * reserved = [self reservedKeywords];
    NSString * lowercase = fieldName.lowercaseString;
    if ([reserved containsObject:lowercase])
    {
        return [NSString stringWithFormat:@"_%@", lowercase];
    }
    else
    {
        return lowercase;
    }
    
}

@end
