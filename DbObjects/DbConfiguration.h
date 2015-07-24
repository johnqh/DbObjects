//
//  DbConfiguration.h
//  DbObjects
//
//  Created by Qiang Huang on 12/18/14.
//  Copyright (c) 2014 Sudobility. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DbConfiguration : NSObject

@property (nonatomic, strong) NSString * platform;

+ (DbConfiguration *)singleton;

@end
