//
//  Person.h
//  DataStorage
//
//  Created by jamalping on 15-2-4.
//  Copyright (c) 2015年 jamalping. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject <NSCoding>

@property (nonatomic)NSString *name;

@property (nonatomic)NSString *age;

@property (nonatomic)NSString *weight;

@property (nonatomic)NSString *score;

- (id)initWithName:(NSString *)name age:(NSString *)age weight:(NSString *)weight score:(NSString *)score;

@end
