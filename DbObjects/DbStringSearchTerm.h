//
//  DbStringSearchTerm.h
//  DbBridge
//
//  Created by John Huang on 3/20/14.
//  Copyright (c) 2014 John Huang. All rights reserved.
//

#import "DbSearchTerm.h"

@interface DbStringSearchTerm : DbSearchTerm

@property (nonatomic, strong) NSString * searchText;

+ (DbStringSearchTerm *)searchTerm:(NSString *)searchText;


@end
