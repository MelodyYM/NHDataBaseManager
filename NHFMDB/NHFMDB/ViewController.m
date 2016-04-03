//
//  ViewController.m
//  NHFMDB
//
//  Created by 牛辉 on 16/4/3.
//  Copyright © 2016年 Niu. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"
#import "NHDataBaseManager.h"
#import "Message.h"
//重写NSLog,Debug模式下打印日志和当前行数
#if DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr,"\nfunction: %s 【line:%d】\n%s\n", __FUNCTION__, __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(FORMAT, ...) nil
#endif

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    [self Person];
    [self message];
    
}
- (void)message
{
    //如果要建立多个主键约束条件 要先创建表
    [[NHDataBaseManager defaultManager] creatTable:[Message class] primaryKey:@"%@,%@",@"messageID",@"sessionID"];
    for (int i = 0; i <100; i++) {
        Message *message = [[Message alloc] init];
        if (i < 50) {
            message.messageID = [NSString stringWithFormat:@"%d",i];
            message.sessionID = 10;
            message.messageTime = [[NSDate date] timeIntervalSince1970] +i;
            message.messageContent = [NSString stringWithFormat:@"你是谁-%d",i];
        } else {
            message.messageID = [NSString stringWithFormat:@"%d",i-50];
            message.sessionID = 8;
            message.messageTime = [[NSDate date] timeIntervalSince1970] +i;
            message.messageContent = [NSString stringWithFormat:@"我是谁-%d",i];
        }
        [[NHDataBaseManager defaultManager] insertAndUpdateModelToDatabase:message];
    }
    //取出message的所有数据
    NSArray *all =  [[NHDataBaseManager defaultManager] selectAllModelInDatabase:[Person class]];
    //或者多参数
    Message *message_sessionID =[[Message alloc] init];
    message_sessionID.sessionID = 8;
    NSArray *sessionID_Arr = [[NHDataBaseManager defaultManager] selectModelArrayInDatabase:message_sessionID byKey:@"%@",@"sessionID"];
    
}
- (void)Person
{
    for (int i = 0; i < 10; i++) {
        Person *son = [[Person alloc] init];
        son.userid = i+1;
        if (i<6) {
            son.name   = @"小明";
        } else {
            son.name   = [NSString stringWithFormat:@"小明%d",i];
        }
        if (i<3) {
            son.age    = @"岁数-0";
        } else {
            son.age    = [NSString stringWithFormat:@"岁数-%d",i+10];
        }
        [[NHDataBaseManager defaultManager] insertAndUpdateModelToDatabase:son];
    }
    
    //取出person的所有数据
    [[NHDataBaseManager defaultManager] selectAllModelInDatabase:[Person class]];
    //根据约束条件取出数据
    //第一种情况
    Person *son = [[Person alloc] init];
    son.userid = 9;
    //如果key不传  是根据默认约束主键查询的  默认约束是类的第一个属性  请注意
    NSArray *personArr = [[NHDataBaseManager defaultManager] selectModelArrayInDatabase:son byKey:nil];
    
    //第二种情况
    Person *son_name =[[Person alloc] init];
    son_name.name = @"小明";
    NSArray *son_name_Arr = [[NHDataBaseManager defaultManager] selectModelArrayInDatabase:son_name byKey:@"%@",@"name"];
    //或者多参数
    Person *son_more =[[Person alloc] init];
    son_more.name = @"小明";
    son_more.age  = @"岁数-0";
    NSArray *son_more_Arr = [[NHDataBaseManager defaultManager] selectModelArrayInDatabase:son_more byKey:@"%@,%@",@"name",@"age"];
}
@end
