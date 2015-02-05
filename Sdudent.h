//
//  Sdudent.h
//  DataStorage
//
//  Created by jamalping on 15-2-5.
//  Copyright (c) 2015年 jamalping. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Sdudent : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * age;

@end
