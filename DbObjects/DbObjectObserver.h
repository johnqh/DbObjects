//
//  DbObjectObserver.h
//  DbBridge
//
//  Created by John Huang on 5/19/14.
//  Copyright (c) 2014 John Huang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DbObject;

@protocol DbObjectObserver <NSObject>

- (bool)handleChange:(DbObject *)object field:(NSString *)fieldName;

@end
