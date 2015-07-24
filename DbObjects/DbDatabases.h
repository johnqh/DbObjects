//
//  SqliteDatabases.h
//  SqliteTest
//
//  Created by Libriance on 4/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DbDatabase.h"


@interface DbDatabases : NSObject
{
}

@property (nonatomic, retain) NSMutableDictionary * databases;

+ (DbDatabases *)databases;
+ (DbDatabase *)singleton;
+ (DbDatabase *)openSingleton:(DbDatabase *)database;
+ (DbDatabase *)openDatabase:(DbDatabase *)database tag:(NSString *)tag;
+ (void)shutdown;
- (DbDatabase *)database:(NSString *)tag;
- (DbDatabase *)openDatabase:(DbDatabase *)database tag:(NSString *)tag;
- (void)suspend;
- (void)resume;

@end
