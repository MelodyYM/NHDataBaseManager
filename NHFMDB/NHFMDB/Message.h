//
//  Message.h
//  NHFMDB
//
//  Created by 牛辉 on 16/4/3.
//  Copyright © 2016年 Niu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Message : NSObject


@property (nonatomic ,copy)NSString *messageID;


@property (nonatomic ,assign)NSInteger sessionID;


@property (nonatomic ,copy)NSString  * messageContent;


@property (nonatomic ,assign)NSInteger messageTime;

@end
