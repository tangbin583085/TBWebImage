//
//  TBDBTool.m
//  TBCoreData8
//
//  Created by hanchuangkeji on 2017/11/7.
//  Copyright © 2017年 hanchuangkeji. All rights reserved.
//

#import "TBDBTool.h"
#import "FMDB.h"

@interface TBDBTool()

@property (nonatomic, strong) FMDatabase *db;
@end

@implementation TBDBTool

static TBDBTool *_instance = nil;

+(instancetype) shareInstance
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init] ;
        
        // 初始化数据库
        [_instance initDB];
    }) ;
    
    return _instance ;
}




- (void)initDB {
    
    // Do any additional setup after loading the view, typically from a nib.
    NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    // 拼接文件名
    NSString *file_path = [cachePath stringByAppendingPathComponent:@"tangbin_image_cache.sqlite"];
    // 创建一个数据库的实例,仅仅在创建一个实例，并会打开数据库
    FMDatabase *db = [FMDatabase databaseWithPath:file_path];
    _db = db;
    // 打开数据库
    BOOL flag = [db open];
    if (flag) {
        NSLog(@"打开成功");
    }else{
        NSLog(@"打开失败");
    }
    
    // 创建数据库表
    // 数据库操作：插入，更新，删除都属于update
    // 参数：sqlite语句
    BOOL flag1 = [db executeUpdate:@"create table if not exists t_image (id integer primary key autoincrement, url text,uuid text, file_path text);"];
    if (flag1) {
        NSLog(@"创建成功");
    }else{
        NSLog(@"创建失败");
        
    }
}

- (BOOL)saveImage:(NSString *)url image:(UIImage *)image {
    
    
    NSString *uuid = [[NSUUID UUID] UUIDString];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *path = [paths[0] stringByAppendingString:@"/tangbin/image/cache"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExist = [fileManager fileExistsAtPath:path];
    if (isExist) {
        NSLog(@"目录已经存在");
    }else {
        BOOL ret = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        if (ret) {
            NSLog(@"目录创建成功");
        }else {
            NSLog(@"目录创建失败");
        }
    }
    
    NSString *file_path = [path stringByAppendingPathComponent:uuid];   // 保存文件的名称
    BOOL result = [UIImagePNGRepresentation(image) writeToFile: file_path atomically:YES]; // 保存成功会返回YES
    NSLog(@"result %d", result);
    
    
    FMResultSet *resultSet =  [_db executeQuery:@"select * from t_image where url = ?", url];
    
    // 数据库已经存在
    while ([resultSet next]) {
        return YES;
    }
    
    // 保存到数据库
    BOOL flag = [_db executeUpdate:@"insert into t_image (url, uuid, file_path) values (?, ?, ?)", url, uuid, file_path];
    if (flag) {
        NSLog(@"success");
    }else{
        NSLog(@"failure");
    }
    return flag;
}

- (UIImage *)image:(NSString *)url {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *path = [paths[0] stringByAppendingString:@"/tangbin/image/cache/"];
    
    FMResultSet *resultSet =  [_db executeQuery:@"select * from t_image where url = ?", url];
    UIImage *image = nil;
    // 从结果集里面往下找
    while ([resultSet next]) {
        NSString *file_path = [resultSet stringForColumn:@"uuid"];
        file_path = [path stringByAppendingString:file_path];
        image = [UIImage imageWithContentsOfFile:file_path];
        break;
    }
    
    return image;
}


@end
