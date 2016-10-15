//
//  DbCollectionMarker.m
//  DbObjects
//
//  Created by John Huang on 3/9/15.
//  Copyright (c) 2015 Sudobility. All rights reserved.
//

#import "DbCollectionMarker.h"

#import "DbTable.h"
#import "DbField.h"
#import "DbCollection.h"
#import "DbObject.h"
#import "DbObjectUtils.h"

@interface DbCollection()

@property (nonatomic, strong) NSMutableArray * sortings;

- (void)addObject:(DbObject *)entry;
- (void)insertObject:(DbObject *)entry atIndex:(NSUInteger)index;
- (void)removeObject:(DbObject *)entry;
- (void)removeObjectAtIndex:(NSUInteger)index;

@end

@interface DbCollectionMarker()

@property (nonatomic, strong) DbCollection * collection;

@end


@implementation DbCollectionMarker

- (id)initWithCollectionWithoutLooking:(DbCollection *)collection object:(DbObject *)entry
{
    if (self = [super init])
    {
        _index = NSNotFound;
        self.collection = collection;
        self.entry = entry;
        return self;
    }
    return nil;
}

- (id)initWithCollection:(DbCollection *)collection object:(DbObject *)entry
{
    if (self = [super init])
    {
        _index = NSNotFound;
        self.collection = collection;
        if (entry.saved) // if already in DB, look in the list with sorting
        {
            if (_collection.sortings)
            {
                self.index = [collection indexOfObject:entry options:NSBinarySearchingFirstEqual usingComparator:^NSComparisonResult(id obj1, id obj2) {
                    DbObject * entry1 = (DbObject *)obj1;
                    DbObject * entry2 = (DbObject *)obj2;
                    
                    return [self compareObj1:entry1 withObj2:entry2 sort:collection.sortings];
                }];
            }
            else
            {
                for (int i = 0; _index == NSNotFound && i < _collection.count; i ++)
                {
                    DbObject * obj = [_collection objectAtIndex:i];
                    if (obj == entry || [self compareKeysOfObj1:obj withObj2:entry] == NSOrderedSame)
                    {
                        _index = i;
                    }
                }
            }
            if (_index == NSNotFound)
            {
                self.entry = entry;
            }
            else
            {
                self.entry = [collection objectAtIndex:_index];
            }
        }
        else
        {
            self.entry = entry;
        }
        
        return self;
    }
    return nil;
}

- (bool)looselyCheckSameObj1:(DbObject *)obj1 withObj2:(DbObject *)obj2
{
    // obj2 is not in DB yet.
    
    DbTable * table = _collection.verifyTable;
    bool foundDiff = false;
    NSArray * fields = table.fields.allKeys;
    for (int i = 0; !foundDiff && i < fields.count; i ++)
    {
        DbField * field = (DbField *)table.fields[fields[i]];
        NSString * value2 = [obj2 getPrivate:field.name];
        if (value2)
        {
            NSString * value1 = [obj1 getPrivate:field.name];
            foundDiff = ![value2 isEqualToString:value1];
        }
    }
    return !foundDiff;
    
}

- (NSComparisonResult)compareObj1:(DbObject *)obj1 withObj2:(DbObject *)obj2 sort:(NSArray *)sortings
{
    NSComparisonResult idCompare = [self compareKeysOfObj1:obj1 withObj2:obj2];
    
    if (idCompare == NSOrderedSame)
    {
        return NSOrderedSame;
    }
    else
    {
        NSComparisonResult result = NSOrderedSame;
        for (int i = 0; result == NSOrderedSame && i < sortings.count; i ++)
        {
            DbSortDescriptor * sorting = (DbSortDescriptor *)sortings[i];
            result = [self compareObj1:obj1 withObj2:obj2 fieldName:sorting.fieldName ascending:sorting.ascending];
        }
        
        return (result != NSOrderedSame) ? result : idCompare;
    }
}

- (NSComparisonResult)compareObj1:(DbObject *)obj1 withObj2:(DbObject *)obj2 fieldName:(NSString *)fieldName ascending:(bool)ascending
{
    NSString * sqlFieldName = [DbObjectUtils sqlFieldName:fieldName];
    NSObject * value1 = [obj1 valueForKey:sqlFieldName];
    NSObject * value2 = [obj2 valueForKey:sqlFieldName];
    
    if (ascending)
    {
        return [DbObject compare:value1 to:value2];
    }
    else
    {
        return [DbObject compare:value2 to:value1];
    }
}

- (NSComparisonResult)compareKeysOfObj1:(DbObject *)obj1 withObj2:(DbObject *)obj2
{
    DbTable * table = _collection.verifyTable;
    NSComparisonResult result = NSOrderedSame;
    bool hasKey = false;
    NSArray * fields = table.fields.allKeys;
    for (int i = 0; !hasKey && result == NSOrderedSame && i < fields.count; i ++)
    {
        DbField * field = (DbField *)table.fields[fields[i]];
        if (field.key)
        {
            result = [self compareObj1:obj1 withObj2:obj2 fieldName:field.sqlFieldName ascending:true];
            hasKey = true;
        }
    }
    return hasKey ? result : NSOrderedAscending;
}


- (void)commit
{
    if (_entry.saved)
    {
        if (_index == NSNotFound)
        {
            if ([_collection satisfy:_entry])
            {
                [self insertBack];
            }
        }
        else
        {
            if ([_collection satisfy:_entry])
            {
                NSComparisonResult previousOrder = NSOrderedAscending;
                if (_index > 0)
                {
                    DbObject * previousObj = (DbObject *)[_collection objectAtIndex:(_index - 1)];
                    previousOrder = [self compareObj1:previousObj withObj2:_entry sort:_collection.sortings];
                }
                if (previousOrder != NSOrderedAscending)
                {
                    [self reOrder];
                }
                else
                {
                    NSComparisonResult nextOrder = NSOrderedAscending;
                    if (_index < _collection.count - 1)
                    {
                        DbObject * nextObj = (DbObject *)[_collection objectAtIndex:(_index + 1)];
                        nextOrder = [self compareObj1:_entry withObj2:nextObj sort:_collection.sortings];
                    }
                    if (nextOrder != NSOrderedAscending)
                    {
                        [self reOrder];
                    }
                }
            }
            else
            {
                [_collection satisfy:_entry];
                [_collection removeObjectAtIndex:_index];
            }
        }
    }
    else
    {
        if (_index != NSNotFound)
        {
            [_collection removeObjectAtIndex:_index];
        }
    }
}

- (void)reOrder
{
    [_collection removeObjectAtIndex:_index];
    [self insertBack];
}

- (void)insertBack
{
    NSUInteger insertIndex = [_collection indexOfObject:_entry options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(id obj1, id obj2) {
        DbObject * entry1 = (DbObject *)obj1;
        DbObject * entry2 = (DbObject *)obj2;
        
        NSComparisonResult compare = [self compareObj1:entry1 withObj2:entry2 sort:_collection.sortings];
        return compare;
    }];
    if (insertIndex == NSNotFound)
    {
    }
    else
    {
        [_collection insertObject:_entry atIndex:insertIndex];
        self.index = insertIndex;
    }
}


@end
