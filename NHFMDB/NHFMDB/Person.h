//
//  Person.h
//  NHFMDB
//
//  Created by 牛辉 on 16/4/3.
//  Copyright © 2016年 Niu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject
@property(nonatomic ,assign)NSInteger userid;

@property(nonatomic ,assign)NSInteger name;

@property(nonatomic ,copy)NSString *age;
@end
