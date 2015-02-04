//
//  Person.m
//  DataStorage
//
//  Created by jamalping on 15-2-4.
//  Copyright (c) 2015年 jamalping. All rights reserved.
//

#import "Person.h"

@implementation Person

- (id)initWithName:(NSString *)name age:(NSString *)age weight:(NSString *)weight score:(NSString *)score {
    self = [super init];
    if (self) {
        self.name = name;
        self.age = age;
        self.weight = weight;
        self.score = score;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.age forKey:@"age"];
    [aCoder encodeObject:self.weight forKey:@"weight"];
    [aCoder encodeObject:self.score forKey:@"score"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.age = [aDecoder decodeObjectForKey:@"age"];
        self.weight = [aDecoder decodeObjectForKey:@"weight"];
        self.score = [aDecoder decodeObjectForKey:@"score"];
    }
    return self;
}

@end
