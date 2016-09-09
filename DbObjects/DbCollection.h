//
//  DbSqliteCollection.h
//  DbBridge
//
//  Created by John Huang on 3/18/14.
//  Copyright (c) 2014 John Huang. All rights reserved.
//

#import "InteractiveObject.h"
#import "DbObject.h"
#import "DbSortDescriptor.h"

typedef void (^ RefreshBlock)();
typedef void (^ ObjectBlock)(DbObject * obj);
typedef NSComparisonResult (^ SortBlock)(id obj1, id obj2);

@class DbSearchTerm;

@interface DbCollection : DbObject<InteractiveArray>

@property (nonatomic, strong) NSString * entityType;
@property (nonatomic, strong) DbSearchTerm * searchTerm;
@property (nonatomic) bool random;
@property (nonatomic) bool paging;
@property (nonatomic) NSUInteger itemsPerPage;
@property (nonatomic) NSUInteger page;

+ (DbCollection *)collectionWithDb:(DbDatabase *)db entityType:(NSString *)entityType;
+ (DbCollection *)collectionWithExample:(DbObject *)example;

- (id)initWithDb:(DbDatabase *)db entityType:(NSString *)entityType;
- (id)initWithExample:(DbObject *)example;

- (void)addSorting:(DbSortDescriptor *)sorting;

- (NSUInteger)count;
- (DbObject *)loadFirstObject;
- (DbObject *)loadLastObject;

- (DbObject *)firstObject;
- (DbObject *)lastObject;
- (DbObject *)objectAtIndex:(NSUInteger)index;

- (void)loadFromDbAsync:(RefreshBlock)completionBlock;


- (NSUInteger)indexOfObject:(DbObject *)obj options:(NSBinarySearchingOptions)opts usingComparator:(NSComparator)cmp;
- (void)iterate:(ObjectBlock)objBlock;
- (NSArray *)sortedArrayUsingComparator:(SortBlock)sortBlock;

- (DbObject *)createObject;
- (DbObject *)createObjectWithKeyValue:(NSString *)keyValue;

- (bool)satisfy:(DbObject *)obj;

@end
