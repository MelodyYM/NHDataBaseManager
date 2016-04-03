//
//  NHDataBaseManager.h
//  NHFMDB
//
//  Created by 牛辉 on 16/4/3.
//  Copyright © 2016年 Niu. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSUInteger , orderType){
    orderTypeReverse = 1,
};
@interface NHDataBaseManager : NSObject


/**
 *  单利初始化数据库  这里就不用真单利了   想改自己改
 */
+ (instancetype)defaultManager;
/**
 *  创建表（表明是model的类名）
 */
- (void)creatTable:(Class )modelClass primaryKey:(NSString *)primaryKey, ...;
/**
 *  增加或更新 数据库数据
 *  1.如果没有创表，自动创表（表明是model的类名）
 *  2.创表的时候，是自定根据模型类的第一个属性当约束 保持唯一性的，所以 注意模型类的属性顺序
 *  3.如果数据库存在这条数据 更新数据 
 *  4.根据runtime 自动写sql语句  实现增加更新
 */
- (void)insertAndUpdateModelToDatabase:(id)model;
/**
 *  数据库删除元素
 */
-(BOOL)deleteModelInDatabase:(Class)model;
/**
 *  查询一张表的所有数据
 *  因为创建表的时候是根据类名创建的
 */
- (NSArray *)selectAllModelInDatabase:(Class)modelClass;
/**
 *  根据约束索引查询数据
 *  @param model  所以要先传入相关的model 如果format为nil 就是默认查询model的第一个属性
 *  @param format 查询条件  可以根据你的约束条件查询  也可以查询别的mode调教
 *  @return 返回想要的数据
 */
- (NSArray *)selectModelArrayInDatabase:(id)model byKey:(NSString *)format, ...;


@end
