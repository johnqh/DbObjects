//
//  DbLogicSearchTerm.h
//  DbBridge
//
//  Created by John Huang on 3/20/14.
//  Copyright (c) 2014 John Huang. All rights reserved.
//

#import "DbSearchTerm.h"

@interface DbLogicSearchTerm : DbSearchTerm

@property (nonatomic, strong) NSString * logicString;   // AND or OR
@property (nonatomic, strong) NSMutableArray * alternatives;

+ (DbLogicSearchTerm *)searchWithAnd;
+ (DbLogicSearchTerm *)searchWithOr;
- (void)addAlternative:(DbSearchTerm *)searchTerm;

@end
