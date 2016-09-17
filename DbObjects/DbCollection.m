//
//  DbSqliteCollection.m
//  DbBridge
//
//  Created by John Huang on 3/18/14.
//  Copyright (c) 2014 John Huang. All rights reserved.
//

#import "DbCollection.h"
#import "DbCollection+Private.h"
#import "DbDatabase.h"
#import "DbTable.h"
#import "DbQuery.h"
#import "DbOperatorSearchTerm.h"
#import "DbObjectCache.h"

@implementation DbCollection

@synthesize entries = _entries;

- (bool)isCollection
{
    return true;
}

+ (DbCollection *)collectionWithDb:(DbDatabase *)db entityType:(NSString *)entityType
{
    return [[DbCollection alloc] initWithDb:db entityType:entityType];
}

+ (DbCollection *)collectionWithExample:(DbObject *)example
{
    return [[DbCollection alloc] initWithExample:example];
}

- (id)initWithDb:(DbDatabase *)db entityType:(NSString *)entityType;
{
    if (self = [super initWithDb:db])
    {
        self.entityType = entityType;
        self.entries = [NSMutableArray array];
        return self;
    }
    return nil;
}

- (id)initWithExample:(DbObject *)example
{
    if (self = [super initWithDb:example.db])
    {
        self.entityType = NSStringFromClass([example class]);
        self.entries = [NSMutableArray array];
        self.example = example;
        return self;
    }
    return nil;
}

- (DbTable *)verifyTable
{
    if (!self.table && self.db)
    {
        self.table = [self.db.tables objectForKey:_entityType];
    }
    return self.table;
}

- (void)addSorting:(DbSortDescriptor *)sorting
{
    if (!_sortings)
    {
        self.sortings = [NSMutableArray array];
    }
    [_sortings addObject:sorting];
}

- (NSString *)whereClause
{
    NSString * whereString = nil;
    if (_example)
    {
        whereString = [_example whereClause];
    }
    if (_searchTerm)
    {
        NSString * searchString = _searchTerm.asString;
        if (whereString)
        {
            whereString = [whereString stringByReplacingOccurrencesOfString:@"WHERE " withString:@"WHERE ("];
            whereString = [NSString stringWithFormat:@"%@ AND %@)", whereString, searchString];
        }
        else
        {
            whereString = [NSString stringWithFormat:@"WHERE %@", searchString];
        }
    }
    
    if (whereString)
    {
        return whereString;
    }
    else
    {
        return [super whereClause];
    }
}

- (DbObject *)loadFromDb
{
    DbQuery * query = self.db.query;
    return [query loadCollection:self];
    
}

- (void)saveToDb
{
    for (DbObject * object in _entries)
    {
        [object saveToDb];
    }
    self.saved = true;
}

- (NSUInteger)count
{
    if (self.saved)
    {
        return _entries.count;
    }
    else
    {
        DbQuery * query = self.db.query;
        return [query count:self];
    }
}

- (DbObject *)loadFirstObject
{
    self.paging = true;
    self.itemsPerPage = 1;
    self.page = 0;
    [self loadFromDb];
    return self.firstObject;
}

- (DbObject *)loadLastObject
{
    self.paging = true;
    self.itemsPerPage = 1;
    self.page = self.count - 1;
    [self loadFromDb];
    return self.firstObject;
}

- (DbObject *)firstObject
{
    if (_entries.count)
    {
        return (DbObject *)[_entries objectAtIndex:0];
    }
    return nil;
}

- (DbObject *)lastObject
{
    if (_entries.count)
    {
        return (DbObject *)[_entries objectAtIndex:_entries.count - 1];
    }
    return nil;
}

- (DbObject *)objectAtIndex:(NSUInteger)index
{
    return (DbObject *)[_entries objectAtIndex:index];
}

- (void)loadFromDbAsync:(RefreshBlock)completionBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self loadFromDb];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (completionBlock)
            {
                completionBlock();
            }
            
        });
    });
}


- (void)addObject:(DbObject *)entry
{
    if (_entries)
    {
        NSInteger index = _entries.count;
        [self insertObject:entry atIndex:index];
    }
}

- (void)insertObject:(DbObject *)entry atIndex:(NSUInteger)index
{
    NSIndexSet * loneIndex = [NSIndexSet indexSetWithIndex:index];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:loneIndex forKey:@"entries"];
    [self.entries insertObject:entry atIndex:index];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:loneIndex forKey:@"entries"];
}

- (void)removeObject:(DbObject *)entry
{
    if (_entries)
    {
        NSInteger index = [_entries indexOfObject:entry];
        if (index != NSNotFound)
        {
            [self removeObjectAtIndex:index];
        }
    }
    
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
    NSIndexSet * loneIndex = [NSIndexSet indexSetWithIndex:index];
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:loneIndex forKey:@"entries"];
    [self.entries removeObjectAtIndex:index];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:loneIndex forKey:@"entries"];
}

- (NSUInteger)indexOfObject:(DbObject *)obj options:(NSBinarySearchingOptions)opts usingComparator:(NSComparator)cmp
{
    return [_entries indexOfObject:obj inSortedRange:(NSRange){0, _entries.count} options:opts usingComparator:cmp];
}

- (void)iterate:(ObjectBlock)objBlock
{
    for (DbObject * obj in _entries)
    {
        objBlock(obj);
    }
}

- (NSArray *)sortedArrayUsingComparator:(SortBlock)sortBlock
{
    return [_entries sortedArrayUsingComparator:sortBlock];
}

- (DbObject *)createObject
{
    return [[NSClassFromString(_entityType) alloc] initWithDb:self.db];
}

- (DbObject *)createObjectWithKeyValue:(NSString *)keyValue
{
    DbObject * obj = nil;
    if (keyValue)
    {
        obj = [self.db.cache cachedObject:_entityType keyValue:keyValue];
    }
    if (!obj)
    {
        obj = [self createObject];
    }
    return obj;
}

- (bool)satisfy:(DbObject *)obj
{
    bool satisfy = true;
    if (_example)
    {
        for (int i = 0; satisfy && i < _example.verifyTable.fields.count; i ++)
        {
            NSString * fieldName = _example.table.fields.allKeys[i];
            DbField * field = _example.table.fields[fieldName];
            
            NSString * key = field.sqlFieldName;
            NSObject * value1 = [_example valueForKey:key];
            if (value1)
            {
                NSObject * value2 = [obj valueForKey:key];
                satisfy = [DbObject compare:value1 to:value2] == NSOrderedSame;
            }
        }
    }
    if (satisfy && _searchTerm)
    {
        satisfy = [_searchTerm satisfy:obj];
    }
    return satisfy;
}

- (void)dealloc
{
    self.example = nil;
    self.entityType = nil;
    self.entries = nil;
    self.sortings = nil;
    self.searchTerm = nil;
}
@end
