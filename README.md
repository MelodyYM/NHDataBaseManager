# NHDataBaseManager
 ->  ios移动端的数据库用到的很多 ，但是大家对于写sql语句很烦，这个项目主要依赖于FMDB的开源框架，用oc的runtime 实现model -> sql语句的封装,
每次用到的时候  直接拉过去 就能用 不用改东西
# 第一种默认类的第一个属性为约束
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
        //这里直接根据类名创建表了  注意  默认类的第一个属性为 约束  所以注意类 属性的顺序
        [[NHDataBaseManager defaultManager] insertAndUpdateModelToDatabase:son];
    }
    
    //取出person的所有数据
    [[NHDataBaseManager defaultManager] selectAllModelInDatabase:[Person class]];
    //根据约束条件取出数据
   ## //第一种情况
    Person *son = [[Person alloc] init];
    son.userid = 9;
    //如果key不传  是根据默认约束主键查询的  默认约束是类的第一个属性  请注意
    NSArray *personArr = [[NHDataBaseManager defaultManager] selectModelArrayInDatabase:son byKey:nil];
    
   ## //第二种情况
    Person *son_name =[[Person alloc] init];
    son_name.name = @"小明";
    NSArray *son_name_Arr = [[NHDataBaseManager defaultManager] selectModelArrayInDatabase:son_name byKey:@"%@",@"name"];
    ## //或者多参数
    Person *son_more =[[Person alloc] init];
    son_more.name = @"小明";
    son_more.age  = @"岁数-0";
    NSArray *son_more_Arr = [[NHDataBaseManager defaultManager] selectModelArrayInDatabase:son_more byKey:@"%@,%@",@"name",@"age"];
# 第二种多个约束条件保持唯一性     这个用到很少  IM数据库会用到很多，因为 要分会话ID和信息ID    2个约束来控制数据库
## 比如  小明和小白聊天    sessionID 是唯一的   但是messageID会从0 到 max
小明和小红聊天    sessionID 是唯一的    messageID 也会是从 0 到 max
			这种情况就要用到多个约束条件了
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


