//
//  DbAppObjectCache.m
//  DbObjects
//
//  Created by Qiang Huang on 5/23/15.
//  Copyright (c) 2015 Sudobility. All rights reserved.
//

#import "DbAppObjectCache.h"
#import "DbObject.h"
#import "DbCollection.h"
#import "DbCollectionMarker.h"
#import "DbWeakArray.h"

/*
 
 Handle DbCollection removeFromDb
 Handle DbObject add/remove from cache and add/remove to collection
 
 */

@class DbObject;

@interface DbAppObjectCache()
{
    NSMutableDictionary * _objectCache;
    NSMutableDictionary * _collectionCache;
    NSMutableDictionary * _markers;
}
@end

@implementation DbAppObjectCache

- (DbWeakArray *)collectionCache:(NSString *)className
{
    if (!_collectionCache)
    {
        _collectionCache = [NSMutableDictionary dictionary];
    }
    DbWeakArray * classCache = _collectionCache[className];
    if (!classCache)
    {
        classCache = [DbWeakArray array];
        _collectionCache[className] = classCache;
    }
    else
    {
        [classCache compact];
    }
    return classCache;
}

- (NSMapTable *)objectCache:(NSString *)className
{
    if (!_objectCache)
    {
        _objectCache = [NSMutableDictionary dictionary];
    }
    NSMapTable * classCache = _objectCache[className];
    if (!classCache)
    {
        classCache = [NSMapTable mapTableWithKeyOptions:NSMapTableCopyIn valueOptions:NSMapTableWeakMemory];
        _objectCache[className] = classCache;
    }
    return classCache;
}

- (NSMutableArray *)markersWithClassName:(NSString *)className keyValue:(NSString *)keyValue forced:(bool)forced
{
    NSMutableDictionary * classCache = [self markersClassCache:className forced:forced];
    return [self markersWithClassCache:classCache keyValue:keyValue forced:forced];
}

- (NSMutableDictionary *)markersClassCache:(NSString *)className forced:(bool)forced
{
    if (!_markers && forced)
    {
        _markers = [NSMutableDictionary dictionary];
    }
    if (_markers)
    {
        NSMutableDictionary * classCache = _markers[className];
        if (!classCache && forced)
        {
            classCache = [NSMutableDictionary dictionary];
            _markers[className] = classCache;
        }
        return classCache;
    }
    return nil;
}

- (NSMutableArray *)markersWithClassCache:(NSMutableDictionary *)classCache keyValue:(NSString *)keyValue forced:(bool)forced
{
    if (classCache)
    {
        NSMutableArray * markers = classCache[keyValue];
        if (!markers && forced)
        {
            markers = [NSMutableArray array];
            classCache[keyValue] = markers;
        }
        return markers;
    }
    return nil;
    
}

- (void)markInCache:(DbObject *)obj
{
    if ([obj isKindOfClass:[DbCollection class]])
    {
    }
    else
    {
        NSString * keyValue = obj.keyValue;
        if (keyValue)
        {
            NSString * className = NSStringFromClass([obj class]);
            DbWeakArray * classCache = [self collectionCache:className];
            [classCache compact];
            if (classCache.count)
            {
                NSMutableArray * markers = [self markersWithClassName:className keyValue:keyValue forced:true];
                for (DbCollection * collection in classCache)
                {
                    DbCollectionMarker * marker = [[DbCollectionMarker alloc] initWithCollection:collection object:obj];
                    [markers addObject:marker];
                }
            }
        }
    }
}

- (void)saveToCache:(DbObject *)obj
{
    if ([obj isKindOfClass:[DbCollection class]])
    {
        DbCollection * collection = (DbCollection *)obj;
        DbWeakArray * classCache = [self collectionCache:collection.entityType];
        [classCache addObject:collection];
    }
    else
    {
        NSString * keyValue = obj.keyValue;
        if (keyValue)
        {
            NSString * className = NSStringFromClass([obj class]);
            NSMapTable * classCache = [self objectCache:className];
            [classCache setObject:obj forKey:keyValue];
            
            NSMutableDictionary * markersClassCache = [self markersClassCache:className forced:false];
            NSMutableArray * markers = [self markersWithClassCache:markersClassCache keyValue:keyValue forced:false];
            if (markers)    // was in db
            {
                for (DbCollectionMarker * marker in markers)
                {
                    [marker commit];
                }
                [markersClassCache removeObjectForKey:keyValue];
            }
            else            // was new
            {
                DbWeakArray * collectionClassCache = [self collectionCache:className];
                
                for (DbCollection * collection in collectionClassCache)
                {
                    if ([collection satisfy:obj])
                    {
                        DbCollectionMarker * marker = [[DbCollectionMarker alloc] initWithCollectionWithoutLooking:collection object:obj];
                        [marker commit];
                    }
                }
            }
            
        }
    }
}

- (void)updateCache:(DbObject *)obj
{
    if ([obj isKindOfClass:[DbCollection class]])
    {
    }
    else
    {
        NSString * keyValue = obj.keyValue;
        if (keyValue)
        {
            NSString * className = NSStringFromClass([obj class]);
            NSMutableDictionary * markersClassCache = [self markersClassCache:className forced:false];
            NSMutableArray * markers = [self markersWithClassCache:markersClassCache keyValue:keyValue forced:false];
            if (markers)    // was in db
            {
                for (DbCollectionMarker * marker in markers)
                {
                    [marker commit];
                }
                [markersClassCache removeObjectForKey:keyValue];
            }
        }
    }
}

- (void)removeFromCache:(DbObject *)obj
{
    if ([obj isKindOfClass:[DbCollection class]])
    {
        DbCollection * collection = (DbCollection *)obj;
        DbWeakArray * classCache = [self collectionCache:collection.entityType];
        NSInteger found = -1;
        for (NSInteger i = 0; found == -1 && i < classCache.count; i ++)
        {
            DbCollection * existing = [classCache objectAtIndex:i];
            if (existing == obj)
            {
                found = i;
            }
        }
        if (found != -1)
        {
            [classCache removeObjectAtIndex:found];
        }
    }
    else
    {
        NSString * keyValue = obj.keyValue;
        if (keyValue)
        {
            NSString * className = NSStringFromClass([obj class]);
            NSMapTable * classCache = [self objectCache:className];
            [classCache removeObjectForKey:obj.keyValue];
            
            NSMutableDictionary * markersClassCache = [self markersClassCache:className forced:false];
            NSMutableArray * markers = [self markersWithClassCache:markersClassCache keyValue:keyValue forced:false];
            if (markers)    // was in db
            {
                for (DbCollectionMarker * marker in markers)
                {
                    [marker commit];
                }
                [markersClassCache removeObjectForKey:keyValue];
            }
        }
    }
}

- (DbObject *)cachedObject:(NSString *)className keyValue:(NSString *)keyValue
{
    if (_objectCache && keyValue)
    {
        NSMapTable * classCache = _objectCache[className];
        if (classCache)
        {
            return (DbObject *)[classCache objectForKey:keyValue];
        }
    }
    return nil;
}

@end
