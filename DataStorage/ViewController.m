//
//  ViewController.m
//  DataStorage
//
//  Created by jamalping on 15-2-4.
//  Copyright (c) 2015年 jamalping. All rights reserved.
//

#define NS_USERDEFAULTS [NSUserDefaults standardUserDefaults]

#import "ViewController.h"
#import "Person.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /*
     * 1、属性列表化
     * 2、归档
     * 3、sqlite（数据库）
     * 4、coredata
     */
//-------------------------属性列表化(支持NSArray和NSDictionary)----------------------------------
//-------------------------NSUserDefaults
    // 1、NSString、 NSNumber、NSDate、 NSArray、NSDictionary、BOOL、NSInteger、NSFloat等系统定义的数据类型，如果要存放自定义的对象（如自定义的类对象），则必须将其转换成NSData存储
    NSString *string = @"string test";
    [[NSUserDefaults standardUserDefaults] setObject:string forKey:@"string"];
    NSLog(@"NS_USERDEFAULTS string = %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"string"]);
    
    NSNumber *number = [NSNumber numberWithInteger:3];
    [[NSUserDefaults standardUserDefaults] setObject:number forKey:@"number"];
    NSLog(@"NS_USERDEFAULTS number = %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"number"]);
    
    NSArray *array = @[string,number];
    [[NSUserDefaults standardUserDefaults] setObject:array forKey:@"array"];
    NSLog(@"NS_USERDEFAULTS array = %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"array"]);
    
    // 自定义的类的存储
    Person *jack = [[Person alloc] initWithName:@"jack" age:@"22" weight:@"100" score:@"90"];
    Person *rose = [[Person alloc] initWithName:@"rose" age:@"20" weight:@"90" score:@"98"];
    NSArray *array1 = @[jack,rose];
    
    /// 不能这样保存、自定义的类需要转化成NSData存储
//    [NS_USERDEFAULTS setObject:array1 forKey:@"array1"];
//    NSLog(@"NS_USERDEFAULTS = %@",[NS_USERDEFAULTS objectForKey:@"array1"]);
    
    NSData *arrayData = [NSKeyedArchiver archivedDataWithRootObject:array1];
    [[NSUserDefaults standardUserDefaults] setObject:arrayData forKey:@"arrayData"];
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"arrayData"];
    NSArray *ary = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    for (Person *person in ary) {
        NSLog(@"--%@",person.name);
    }
    
    // 字典存储自定义的对象，（需要转成NSData）
    NSDictionary *dic = [[NSDictionary alloc] initWithObjects:@[jack,rose] forKeys:@[@"jack",@"rose"]];
    NSMutableData *dicData = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:dicData];
    [archiver encodeObject:dic forKey:@"dicData"];
    [archiver finishEncoding];
    [[NSUserDefaults standardUserDefaults] setObject:dicData forKey:@"dic"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSData *vDicData = [[NSUserDefaults standardUserDefaults] objectForKey:@"dic"];
    NSKeyedUnarchiver *unArchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:vDicData];
    NSDictionary *vDic = [unArchiver decodeObjectForKey:@"dicData"];
    [unArchiver finishDecoding];
    NSLog(@"dic = %@",vDic);
    
//----------------------------------剩余的就不一一演示了--------------------------------------------
//----------------------------------writeToFile
    [self writeToFile:array1 path:@"testFile"];
    NSArray *arry = [self readContentFromFilePath:@"testFile"];
    for (Person *person in arry) {
        NSLog(@"person.name = %@",person.name);
    }
    
    [self writeToFile:dic path:@"testFile1"];
    NSDictionary *cDic = [self readContentFromFilePath:@"testFile1"];
    Person *person = cDic[@"jack"];
    NSLog(@"person name = %@",person.name);
    
//----------------------------------归档--------------------------------------------
    // 归档是自定义的对象要实现NSCoding协议
    NSString *filePath = [self getFilePathWithFileName:@"ArchiverFile"];
    if ([NSKeyedArchiver archiveRootObject:array1 toFile:filePath]) { // 如果存进去了
        NSLog(@"archiver success!");
        // 解归档
        NSArray *archiverArray = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        for (Person *person in archiverArray) {
            NSLog(@"person.name = %@",person.name);
        }
    }
}

/**
 *  @brief  获取存储文件的路径
 *
 *  @param fileName 文件的名字
 *
 *  @return 存储文件的路径
 */
- (NSString *)getFilePathWithFileName:(NSString *)fileName {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *directoryPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [directoryPaths objectAtIndex:0];
    NSString *filePath = [documentDirectory stringByAppendingPathComponent:fileName];
    if (![fileManager fileExistsAtPath:filePath]) {
        [fileManager createFileAtPath:filePath contents:nil attributes:nil];
    }
    return filePath;
}

/**
 *  @brief  将objc写入文件
 *
 *  @param objc 要写入的对象
 *  @param path 要写入的文件的路径
 */
- (void)writeToFile:(id)objc path:(NSString *)path {
    NSString *filePath = [self getFilePathWithFileName:path];
    NSData *cData = [NSKeyedArchiver archivedDataWithRootObject:objc];
    [cData writeToFile:filePath atomically:YES];
}

/**
 *  @brief  读取文件中的数据
 *
 *  @param path 文件路径
 *
 *  @return 文件中的内容
 */
- (id)readContentFromFilePath:(NSString *)path {
    NSString *filePath = [self getFilePathWithFileName:path];
    NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
    id objc = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return objc;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
