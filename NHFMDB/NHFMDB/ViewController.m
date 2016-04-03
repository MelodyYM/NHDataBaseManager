//
//  ViewController.m
//  NHFMDB
//
//  Created by 牛辉 on 16/4/3.
//  Copyright © 2016年 Niu. All rights reserved.
//

#import "ViewController.h"
#import "FMDBManager.h"
#import "Person.h"
#import "NHDataBaseManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    Person *niu = [[Person alloc] init];
//    niu.name = @"牛辉123123123123";
//    niu.age  = @"haha";
    niu.userid = 6;
//    
//    [[FMDBManager sharedInstace] insertAndUpdateModelToDatabase:niu];
    
    [[NHDataBaseManager defaultManager] selectModelArrayInDatabase:niu byKey:@"%@,%@",@"name",@"age"];
    
//    NSArray *arr = [[FMDBManager sharedInstace] selectModelArrayInDatabase:niu];
    
}

@end
