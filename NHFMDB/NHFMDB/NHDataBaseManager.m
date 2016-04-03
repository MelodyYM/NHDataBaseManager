//
//  NHDataBaseManager.m
//  NHFMDB
//
//  Created by 牛辉 on 16/4/3.
//  Copyright © 2016年 Niu. All rights reserved.
//

#import "NHDataBaseManager.h"
#import <FMDB.h>
#import <objc/runtime.h>

// 通过实体获取类名
#define TABLE_NAME(model) [NSString stringWithUTF8String:object_getClassName(model)]
// 通过实体获取属性数组数目
#define MODEL_PROPERTYS_COUNT [[self getAllProperties:model] count]
// 通过实体获取属性数组
#define MODEL_PROPERTYS [self getAllProperties:model]



// 通过实体获取类名
#define TABLE_NAME_Class(modelClass) [NSString stringWithUTF8String:object_getClassName(modelClass)]
// 通过实体获取属性数组数目
#define CLASS_PROPERTYS_COUNT [[self getAllProperties:modelClass] count]
// 通过实体获取属性数组
#define CLASS_PROPERTYS [self getAllProperties:modelClass]


@interface NHDataBaseManager ()


@property (nonatomic ,strong)FMDatabase *db;

@end
@implementation NHDataBaseManager


+ (instancetype)defaultManager
{
    static NHDataBaseManager *manager = nil;
    @synchronized(self) {
        if (!manager) {
            manager = [[NHDataBaseManager alloc]init];
        }
    }
    return manager;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self creatDatabase];
    }
    return self;
}
// 创建数据库
- (void)creatDatabase
{
    self.db = [FMDatabase databaseWithPath:[self databaseFilePath]];
}
// 获取沙盒路径
- (NSString *)databaseFilePath
{
    
    NSArray *filePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [filePath objectAtIndex:0];
    NSLog(@"%@",filePath);
    NSString *dbFilePath = [documentPath stringByAppendingPathComponent:@"hahahahaha.sqlite"];
    return dbFilePath;

}
- (void)creatTable:(id)model
{
    //先判断数据库是否存在，如果不存在，创建数据库
    if (!self.db) {
        [self creatDatabase];
    }
    //判断数据库是否已经打开，如果没有打开，提示失败
    if (![self.db open]) {
        NSLog(@"数据库打开失败");
        return;
    }
    //为数据库设置缓存，提高查询效率
    [self.db setShouldCacheStatements:YES];
//    
    //判断数据库中是否已经存在这个表，如果不存在则创建该表
    if (![self.db tableExists:TABLE_NAME(model)]) {
        //（1）获取类名作为数据库表名
        //（2）获取类的属性作为数据表字段
        
        // 1.创建表语句头部拼接
        NSString *creatTableStrHeader = [NSString stringWithFormat:@"create table %@",TABLE_NAME(model)];
        
        // 2.创建表语句中部拼接
        NSString *creatTableStrMiddle =@"";
        for (int i = 0; i < MODEL_PROPERTYS_COUNT; i++) {
            if ([creatTableStrMiddle isEqualToString:@""]) {
                //UNIQUE 独一无二的
//                UNIQUE 约束唯一标识数据库表中的每条记录。
//                UNIQUE 和 PRIMARY KEY 约束均为列或列集合提供了唯一性的保证。
//                PRIMARY KEY 拥有自动定义的 UNIQUE 约束。
//                请注意，每个表可以有多个 UNIQUE 约束，但是每个表只能有一个 PRIMARY KEY 约束
                creatTableStrMiddle = [creatTableStrMiddle stringByAppendingFormat:@"(%@ TEXT UNIQUE",[MODEL_PROPERTYS objectAtIndex:i]];
            } else {
                creatTableStrMiddle = [creatTableStrMiddle stringByAppendingFormat:@",%@ TEXT",[MODEL_PROPERTYS objectAtIndex:i]];
            }

        }
        // 3.创建表语句尾部拼接
        NSString *creatTableStrTail =[NSString stringWithFormat:@")"];
        // 4.整句创建表语句拼接
        NSString *creatTableStr = [NSString string];
        creatTableStr = [creatTableStr stringByAppendingFormat:@"%@%@%@",creatTableStrHeader,creatTableStrMiddle,creatTableStrTail];
        [self.db executeUpdate:creatTableStr];
        
        NSLog(@"创建完成");
    }
    //    关闭数据库
    [self.db close];
}
-(void)creatTable:(Class)modelClass primaryKey:(NSString *)primaryKey, ...
{
    if (primaryKey == nil) {
        [self creatTable:modelClass];
        return;
    }
    va_list arglist;
    va_start(arglist, primaryKey);
    NSString  * outstring = [[NSString alloc] initWithFormat:primaryKey arguments:arglist];
    va_end(arglist);
    //先判断数据库是否存在，如果不存在，创建数据库
    if (!self.db) {
        [self creatDatabase];
    }
    //判断数据库是否已经打开，如果没有打开，提示失败
    if (![self.db open]) {
        NSLog(@"数据库打开失败");
        return;
    }
    //为数据库设置缓存，提高查询效率
    [self.db setShouldCacheStatements:YES];
    //
    //判断数据库中是否已经存在这个表，如果不存在则创建该表
    if (![self.db tableExists:TABLE_NAME_Class(modelClass)]) {
        //（1）获取类名作为数据库表名
        //（2）获取类的属性作为数据表字段
        
        // 1.创建表语句头部拼接
        NSString *creatTableStrHeader = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS  %@",TABLE_NAME_Class(modelClass)];
        NSLog(@"");
        // 2.创建表语句中部拼接
        NSString *creatTableStrMiddle =@"";
        for (int i = 0; i < CLASS_PROPERTYS_COUNT; i++) {
            if ([creatTableStrMiddle isEqualToString:@""]) {
                creatTableStrMiddle = [creatTableStrMiddle stringByAppendingFormat:@"(%@ TEXT",[CLASS_PROPERTYS objectAtIndex:i]];
            } else {
                creatTableStrMiddle = [creatTableStrMiddle stringByAppendingFormat:@",%@ TEXT",[CLASS_PROPERTYS objectAtIndex:i]];
            }
        }
        creatTableStrMiddle = [creatTableStrMiddle stringByAppendingFormat:@",primary key(%@)",outstring];
        // 3.创建表语句尾部拼接
        NSString *creatTableStrTail =[NSString stringWithFormat:@")"];
        // 4.整句创建表语句拼接
        NSString *creatTableStr = [NSString string];
        creatTableStr = [creatTableStr stringByAppendingFormat:@"%@%@%@",creatTableStrHeader,creatTableStrMiddle,creatTableStrTail];
        [self.db executeUpdate:creatTableStr];
        
        NSLog(@"创建完成");
    }
    //    关闭数据库
    [self.db close];

}
-(void)insertAndUpdateModelToDatabase:(id)model
{
    // 判断数据库是否存在
    if (!self.db) {
        [self creatDatabase];
    }
    // 判断数据库能否打开
    if (![self.db open]) {
        NSLog(@"数据库打开失败");
        return;
    }
    // 设置数据库缓存
    [self.db setShouldCacheStatements:YES];
    
    // 判断是否存在对应的userModel表
    if(![self.db tableExists:TABLE_NAME(model)])
    {
        [self creatTable:model];
        // 判断数据库能否打开
        if (![self.db open]) {
            NSLog(@"数据库打开失败");
            return;
        }
    }
    // 拼接插入语句的头部
    // insert or replace into 如果有数据  复盖  没有就插入
    //  @"INSERT OR REPLACE INTO %@ VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?)",TABLE];
    
    NSString *insertStrHeader = [NSString stringWithFormat:@"INSERT OR REPLACE INTO  %@ (",TABLE_NAME(model)];
    // 拼接插入语句的中部1
    NSString *insertStrMiddleOne = [NSString string];
    for (int i = 0; i < MODEL_PROPERTYS_COUNT; i++) {
        insertStrMiddleOne = [insertStrMiddleOne stringByAppendingFormat:@"%@",[MODEL_PROPERTYS objectAtIndex:i]];
        if (i != MODEL_PROPERTYS_COUNT -1) {
            insertStrMiddleOne = [insertStrMiddleOne stringByAppendingFormat:@","];
        }
    }
    // 拼接插入语句的中部2
    NSString *insertStrMiddleTwo = [NSString stringWithFormat:@") VALUES ("];
    // 拼接插入语句的中部3
    NSString *insertStrMiddleThree = [NSString string];
    for (int i = 0; i < MODEL_PROPERTYS_COUNT; i++) {
        insertStrMiddleThree = [insertStrMiddleThree stringByAppendingFormat:@"?"];
        if (i != MODEL_PROPERTYS_COUNT-1) {
            insertStrMiddleThree = [insertStrMiddleThree stringByAppendingFormat:@","];
        }
    }
    // 拼接插入语句的尾部
    NSString *insertStrTail = [NSString stringWithFormat:@")"];
    // 整句插入语句拼接
    NSString *insertStr = [NSString string];
    insertStr = [insertStr stringByAppendingFormat:@"%@%@%@%@%@",insertStrHeader,insertStrMiddleOne,insertStrMiddleTwo,insertStrMiddleThree,insertStrTail];
    NSMutableArray *modelPropertyArray = [NSMutableArray array];
    for (int i = 0; i < MODEL_PROPERTYS_COUNT; i++) {
        NSString *str = [model valueForKey:[MODEL_PROPERTYS objectAtIndex:i]];
        if (str == nil) {
            str = @"none";
        }
        [modelPropertyArray addObject: str];
    }
    
    [self.db executeUpdate:insertStr withArgumentsInArray:modelPropertyArray];
    //    关闭数据库
    [self.db close];
}
-(BOOL)deleteModelInDatabase:(id)model
{
    // 判断是否创建数据库
    if (!self.db) {
        [self creatDatabase];
    }
    // 判断数据是否已经打开
    if (![self.db open]) {
        NSLog(@"数据库打开失败");
        return NO;
    }
    // 设置数据库缓存，优点：高效
    [self.db setShouldCacheStatements:YES];
    
    // 判断是否有该表
    if(![self.db tableExists:TABLE_NAME(model)])
    {
        return NO;
    }
    // 删除操作
    // 拼接删除语句
    // delete from tableName where userId = ?
    NSString *deletStr = [NSString stringWithFormat:@"delete from %@ where %@ = '?' ",TABLE_NAME(model),[MODEL_PROPERTYS objectAtIndex:0]];
   BOOL isCorrect = [self.db executeUpdate:deletStr, [model valueForKey:[MODEL_PROPERTYS objectAtIndex:0]]];
    // 关闭数据库
    [self.db close];
    return isCorrect;
}
- (NSArray *)selectAllModelInDatabase:(id)model
{
    //    select * from tableName
    if (!self.db) {
        [self creatDatabase];
    }
    
    if (![self.db open]) {
        NSLog(@"数据库打开失败");
        return nil;
    }
    
    [self.db setShouldCacheStatements:YES];
    
    if(![self.db tableExists:TABLE_NAME(model)])
    {
        [self creatTable:model];
    }
    //定义一个可变数组，用来存放查询的结果，返回给调用者
    NSMutableArray *userModelArray = [NSMutableArray array];
    //定义一个结果集，存放查询的数据
    //拼接查询语句
    NSString *selectStr = [NSString stringWithFormat:@"select * from %@",TABLE_NAME(model)];
    FMResultSet *resultSet = [self.db executeQuery:selectStr];
    //判断结果集中是否有数据，如果有则取出数据
    while ([resultSet next]) {
        // 用id类型变量的类去创建对象
        id modelResult = [[[model class]alloc] init];
        for (int i = 0; i < MODEL_PROPERTYS_COUNT; i++) {
            [modelResult setValue:[resultSet stringForColumn:[MODEL_PROPERTYS objectAtIndex:i]] forKey:[MODEL_PROPERTYS objectAtIndex:i]];
        }
        //将查询到的数据放入数组中。
        [userModelArray addObject:modelResult];
    }
    // 关闭数据库
    [self.db close];
    
    return userModelArray;
}
/**
 *  肯据条件查询数据
 */
- (NSArray *)selectModelArrayInDatabase:(id)model
{
    if (!self.db) {
        [self creatDatabase];
    }
    
    if (![self.db open]) {
        NSLog(@"数据库打开失败");
        return nil;
    }
    
    [self.db setShouldCacheStatements:YES];
    
    if(![self.db tableExists:TABLE_NAME(model)])
    {
        [self creatTable:model];
    }
    //定义一个可变数组，用来存放查询的结果，返回给调用者
    NSMutableArray *userModelArray = [NSMutableArray array];
    //定义一个结果集，存放查询的数据
    //拼接查询语句
    NSString *selectStr = [NSString stringWithFormat:@"select * from %@ where %@ = '%@'",TABLE_NAME(model),[MODEL_PROPERTYS objectAtIndex:0],[model valueForKey:[MODEL_PROPERTYS objectAtIndex:0]]];
    FMResultSet *resultSet = [self.db executeQuery:selectStr];
    //判断结果集中是否有数据，如果有则取出数据
    while ([resultSet next]) {
        // 用id类型变量的类去创建对象
        id modelResult = [[[model class]alloc] init];
        for (int i = 0; i < MODEL_PROPERTYS_COUNT; i++) {
            [modelResult setValue:[resultSet stringForColumn:[MODEL_PROPERTYS objectAtIndex:i]] forKey:[MODEL_PROPERTYS objectAtIndex:i]];
        }
        //将查询到的数据放入数组中。
        [userModelArray addObject:modelResult];
    }
    // 关闭数据库
    [self.db close];
    
    return userModelArray;
}
/**
 *  肯据条件查询数据
 */
- (NSArray *)selectModelArrayInDatabase:(id)model byKey:(NSString *)format, ...
{
    if (format == nil) {
        return  [self selectModelArrayInDatabase:model];
    }
    va_list arglist;
    va_start(arglist, format);
    NSString  * outstring = [[NSString alloc] initWithFormat:format arguments:arglist];
    va_end(arglist);
    NSLog(@"%@",outstring);
    NSArray *keyArr = [outstring componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"，,"]];
    if (!self.db) {
        [self creatDatabase];
    }
    
    if (![self.db open]) {
        NSLog(@"数据库打开失败");
        return nil;
    }
    
    [self.db setShouldCacheStatements:YES];
    
    if(![self.db tableExists:TABLE_NAME(model)])
    {
        [self creatTable:model];
    }
    //定义一个可变数组，用来存放查询的结果，返回给调用者
    NSMutableArray *userModelArray = [NSMutableArray array];
    //定义一个结果集，存放查询的数据
    //拼接查询语句
    NSString *selectStr = [NSString stringWithFormat:@"select * from %@ where ",TABLE_NAME(model)];
    //拼接查询条件的语句
    NSString *selsctFactor = @"";
    for (int i = 0; i < keyArr.count; i++) {
        selsctFactor = [selsctFactor stringByAppendingFormat:@"%@ = '%@'",keyArr[i],[model valueForKey:keyArr[i]]];
        if (i != keyArr.count-1) {
            selsctFactor = [selsctFactor stringByAppendingFormat:@" and "];
        }
    }
    selectStr = [selectStr stringByAppendingFormat:@"%@",selsctFactor];
    FMResultSet *resultSet = [self.db executeQuery:selectStr];
    //判断结果集中是否有数据，如果有则取出数据
    while ([resultSet next]) {
        // 用id类型变量的类去创建对象
        id modelResult = [[[model class]alloc] init];
        for (int i = 0; i < MODEL_PROPERTYS_COUNT; i++) {
            [modelResult setValue:[resultSet stringForColumn:[MODEL_PROPERTYS objectAtIndex:i]] forKey:[MODEL_PROPERTYS objectAtIndex:i]];
        }
        //将查询到的数据放入数组中。
        [userModelArray addObject:modelResult];
    }
    // 关闭数据库
    [self.db close];
    return userModelArray;

}
/**
 *  传递一个model实体
 */
- (NSArray *)getAllProperties:(id)model
{
    u_int count;
    
    objc_property_t *properties  = class_copyPropertyList([model class], &count);
    
    NSMutableArray *propertiesArray = [NSMutableArray array];
    
    for (int i = 0; i < count ; i++)
    {
        const char* propertyName = property_getName(properties[i]);
        [propertiesArray addObject: [NSString stringWithUTF8String: propertyName]];
    }
    
    free(properties);
    return propertiesArray;
}
@end
