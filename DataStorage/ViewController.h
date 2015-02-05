//
//  ViewController.h
//  DataStorage
//
//  Created by jamalping on 15-2-4.
//  Copyright (c) 2015年 jamalping. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Sdudent.h"

@interface ViewController : UIViewController

/// 用来操作数据对象
@property (nonatomic,retain,readonly)NSManagedObjectContext *manageObjectContent;

/// 用来加载数据模型文件
@property (nonatomic,retain,readonly)NSManagedObjectModel *manageObjectModel;

/// 用来将数据写入文件持久化存储
@property (nonatomic,retain,readonly)NSPersistentStoreCoordinator *persistentStoreCoordinator;

/**
 *  @brief  保存数据
 */
- (void)saveContext;
/**
 *  @brief  获取document文件的路径地址
 *
 *  @return document文件的路径地址
 */
- (NSURL *)applicationDocumentsDirectory;

@end

