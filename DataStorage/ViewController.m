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
#import "FMDB.h"

@interface ViewController ()

@end
@implementation ViewController
@synthesize manageObjectContent = _manageObjectContent;
@synthesize manageObjectModel = _manageObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


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
    
    [self dataSrorageWithUserDefaultAndWriteToFile];
    
//----------------------------------writeToFile
    
    Person *jack = [[Person alloc] initWithName:@"jack" age:@"22" weight:@"100" score:@"90"];
    Person *rose = [[Person alloc] initWithName:@"rose" age:@"20" weight:@"90" score:@"98"];
    NSArray *array1 = @[jack,rose];
    // 字典存储自定义的对象，（需要转成NSData）
    NSDictionary *dic = [[NSDictionary alloc] initWithObjects:@[jack,rose] forKeys:@[@"jack",@"rose"]];
    
    [self writeToFile:array1 path:@"testFile"];
    NSArray *arry = [self readContentFromFilePath:@"testFile"];
    for (Person *person in arry) {
        NSLog(@"person.name = %@",person.name);
    }
    
    [self writeToFile:dic path:@"testFile1"];
    NSDictionary *cDic = [self readContentFromFilePath:@"testFile1"];
    Person *person = cDic[@"jack"];
    NSLog(@"person name = %@",person.name);
    
//------------------------------归档----------------------------------------
    // 归档是自定义的对象要实现NSCoding协议
    NSString *filePath = [self getFilePathWithFileName:@"ArchiverArray"];
    if ([NSKeyedArchiver archiveRootObject:array1 toFile:filePath]) { // 如果存进去了
        NSLog(@"archiver success!");
        // 解归档
        NSArray *archiverArray = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        for (Person *person in archiverArray) {
            NSLog(@"person.name = %@",person.name);
        }
    }
    
    NSString *filePathDic = [self getFilePathWithFileName:@"ArchiverDic"];
    if ([NSKeyedArchiver archiveRootObject:dic toFile:filePathDic]) { // 如果存进去了
        NSLog(@"archiver success!");
        // 解归档
        NSDictionary *archiverDic = [NSKeyedUnarchiver unarchiveObjectWithFile:filePathDic];
        Person *person = archiverDic[@"jack"];
        NSLog(@"archiver dic person name = %@",person.name);
    }
//-------------------------------SQLite（这里我们使用FMDB）---------------------------------------
    [self dataStorageWithFMDB];
    
//-------------------------------core data---------------------------------------
    [self dataStorageWithCoreData];
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
#pragma mark ------------core data
- (void)dataStorageWithCoreData {
    // 新建一个被管理的对象
    Sdudent *sdudent;
    for (int i = 0; i < 5; i++) {
        sdudent = (Sdudent *)[self newAndSaveEntity];
    }
    [self deleteEntity:sdudent];
    NSArray *ary = [self getEntity];
    for (Sdudent *sdudent in ary) {
        NSLog(@"--%@",sdudent.age);
    }
}

#pragma mark ------------core data 基本方法
- (void)saveContext {
    NSError *error = nil;
    if (self.manageObjectContent != nil) {
        if ([self.manageObjectContent hasChanges] && ![self.manageObjectContent save:&error]) {
            NSLog(@"Unresolved error %@,%@",error,[error userInfo]);
            abort();
        }
    }
}

- (NSManagedObjectModel *)manageObjectModel { // 实例化模型
    if (_manageObjectContent != nil) {
        return _manageObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"test" withExtension:@"momd"];
    _manageObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _manageObjectModel;
}

- (NSManagedObjectContext *)manageObjectContent { // 实例化操作数据对象
    if (_manageObjectContent != nil) {
        return _manageObjectContent;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _manageObjectContent = [[NSManagedObjectContext alloc] init];
        [_manageObjectContent setPersistentStoreCoordinator:coordinator];
    }
    return _manageObjectContent;
}

-(NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"test.sqlite"];
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.manageObjectModel];
    if (![self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
        configuration:nil
        URL:storeURL
        options:nil
        error:&error]) {
        NSLog(@"Unresolved error %@,%@",error,[error userInfo]);
        abort();
    }
    return self.persistentStoreCoordinator;
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

/**
 *  @brief  新建被管理的对象实例并保存
 */
- (NSManagedObject *)newAndSaveEntity {
    // 创建sdudent 被管理对象实例
    Sdudent *sdudent = [NSEntityDescription insertNewObjectForEntityForName:@"Sdudent" inManagedObjectContext:self.manageObjectContent];
    //属性赋值
    sdudent.name = @"jack";
    sdudent.age = [NSNumber numberWithInteger:arc4random()/9];
    // 标记为添加
    [_manageObjectContent insertObject:sdudent];
    // 保存
    NSError *error = nil;
    if (![_manageObjectContent save:&error]) {
        NSLog(@"Unserved error %@,%@",error ,[error userInfo]);
    }
    return sdudent;
}

/**
 *  @brief  删除实体
 *
 *  @param aEntity 要被删除的实体
 */
- (void)deleteEntity:(NSManagedObject *)aEntity {
    [self.manageObjectContent deleteObject:aEntity];
    NSError *error = nil;
    if (![self.manageObjectContent save:&error]) {
        NSLog(@"delete fail!");
    }
}

/**
 *  @brief  查询
 *
 *  @return 数据结果
 */
- (NSArray *)getEntity {
    // NSFetchRequest对象，用来检索数据
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    // NSEntityDescription 创建一个描述
    NSEntityDescription *myEntityQuery = [NSEntityDescription entityForName:@"Sdudent" inManagedObjectContext:_manageObjectContent];
    // 指定实体
    [request setEntity:myEntityQuery];
    // 排序，按照年龄排序
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"age" ascending:YES];
    NSArray *sortDescriptor = [NSArray arrayWithObject:descriptor];
    [request setSortDescriptors:sortDescriptor];
    NSArray *personAry = [_manageObjectContent executeFetchRequest:request error:nil];
    return personAry;
}

#pragma mark ------------FMDB(SQLite)
/**
 *  @brief  使用FMDB做数据存储
 */
- (void)dataStorageWithFMDB {
    // 创建数据库
    NSString *databasePath = [self getFilePathWithFileName:@"test.db"];
    FMDatabase *db = [FMDatabase databaseWithPath:databasePath];
    /// 保证数据库是打开的
    if (![db open]) {
        NSLog(@"cann't open the database!");
        return;
    }
    /// 建表
    [db executeUpdate:@"CREATE TABLE PersonList (Name text, Age integer, Sex integer, Phone text, Address text, Photo blob)"];
    // 插入数据
    // NSString，integer对应NSNumber，blob则是NSData
    [db executeUpdate:@"INSERT INTO PersonList(Name,Age,Sex,Phone,Address,Photo) VALUES(?,?,?,?,?,?)",@"jack",[NSNumber numberWithInt:23],[NSNumber numberWithInt:1],@"135657",@"深圳福田",[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Whiteball@2x" ofType:@"png"]]];
    // 更新
    [db executeUpdate:@"UPDATE PersonList SET Age = ? WHERE Name = ?",[NSNumber numberWithInt:30],@"jack"];
    //取得资料
    //取得特定的资料，则需使用FMResultSet物件接收传回的内容
    //用[rs next]可以轮询query回来的资料，每一次的next可以得到一个row裡对应的数值，并用[rs stringForColumn:]或[rs intForColumn:]等方法把值转成Object-C的型态。取用完资料后则用[rs close]把结果关闭。
    FMResultSet *rs = [db executeQuery:@"SELECT Name,Age,Sex,Address FROM PersonList"];
    while ([rs next]) {
        NSString *name = [rs stringForColumn:@"Name"];
        NSString *Address = [rs stringForColumn:@"Address"];
        int age = [rs intForColumn:@"Age"];
        int sex = [rs intForColumn:@"Sex"];
        NSLog(@"Name = %@,address = %@,age = %d, Sex = %d",name,Address,age,sex);
    }
    [rs close];
    
    //    －快速取得资料
    //    在有些时候，只会query某一个row裡特定的一个数值（比方只是要找John的年龄），FMDB提供了几个比较简便的方法。这些方法定义在FMDatabaseAdditions.h，如果要使用，记得先import进来。
    NSInteger age = [db intForQuery:@"SELECT Age FROM PersonList where Name = ?",@"jack"];
    NSLog(@"jack's age = %ld",(long)age);
}

#pragma mark ------------归档
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

/**
 *  @brief  属性列表化存储数据
 */
- (void)dataSrorageWithUserDefaultAndWriteToFile {
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
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
