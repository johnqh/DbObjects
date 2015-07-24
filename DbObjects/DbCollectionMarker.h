//
//  DbCollectionMarker.h
//  DbObjects
//
//  Created by John Huang on 3/9/15.
//  Copyright (c) 2015 Sudobility. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DbCollection;
@class DbObject;

@interface DbCollectionMarker : NSObject

@property (nonatomic, strong) DbObject * entry;
@property (nonatomic) NSUInteger index;

- (id)initWithCollection:(DbCollection *)collection object:(DbObject *)entry;
- (id)initWithCollectionWithoutLooking:(DbCollection *)collection object:(DbObject *)entry;
- (void)commit;

@end
