//
//  DbSearchTerm.h
//  DbBridge
//
//  Created by John Huang on 3/20/14.
//  Copyright (c) 2014 John Huang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DbObject;

@interface DbSearchTerm : NSObject

- (NSString *)asString;
- (bool)satisfy:(DbObject *)obj;

@end
