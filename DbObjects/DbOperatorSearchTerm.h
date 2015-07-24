//
//  DbOperatorSearchTerm.h
//  DbObjects
//
//  Created by Qiang Huang on 6/2/15.
//  Copyright (c) 2015 Sudobility. All rights reserved.
//

#import "DbSearchTerm.h"
#import "DbField.h"

typedef enum EDbCompare : NSUInteger
{
    kDbEqualsTo                 = 0,
    kDbNotEqualTo               = 1,
    kDbLargerThan               = 2,
    kDbSmallerThanOrEqualsTo    = 3,
    kDbSmallerThan              = 4,
    kDbLargerThanOrEqualsTo     = 5,
    kDbContains                 = 32,
    kDbNotContain               = 33,
    kDbLike                     = 64,
    kDbNotLike                  = 65,
} EDbCompare;

@interface DbOperatorSearchTerm : DbSearchTerm

@property (nonatomic, strong) NSString * field;
@property (nonatomic) EDbCompare op;
@property (nonatomic, strong) NSObject * value;

+ (DbOperatorSearchTerm *)searchWhen:(NSString *)field op:(EDbCompare)op value:(id)value;
- (id)initWithField:(NSString *)field op:(EDbCompare)op value:(id)value;

@end
