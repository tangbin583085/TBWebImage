//
//  TBCoreWebImage.m
//  TBCoreData8
//
//  Created by hanchuangkeji on 2017/11/6.
//  Copyright © 2017年 hanchuangkeji. All rights reserved.
//

#import "TBCoreWebImage.h"
#import "UIImageView+TBWebImage.h"
#import "TBDBTool.h"


@interface TBCoreWebImage()

@property (nonatomic, strong)NSOperationQueue *opQueue;

@property (nonatomic, strong)NSMutableDictionary *operationCache;

@property (atomic, strong)NSMutableDictionary *imageCache;

@property (nonatomic, assign)NSInteger myCount;

// 注意原子性
@property (atomic, strong)NSMutableDictionary<NSString * , NSMutableArray<UIImageView *> *> *waitForImage;

@end

@implementation TBCoreWebImage

static TBCoreWebImage *coreWebImage = nil;

#pragma mark <lazy>

- (void)tb_didReceiveMemoryWarning {
    [self.imageCache removeAllObjects];
    [self.opQueue cancelAllOperations];
    [self.operationCache removeAllObjects];
    [self.waitForImage removeAllObjects];
}


- (NSMutableDictionary *)operationCache
{
    if (_operationCache == nil) {
        _operationCache = [NSMutableDictionary dictionary];
    }
    return _operationCache;
}

- (NSOperationQueue *)opQueue
{
    if (_opQueue == nil) {
        _opQueue = [[NSOperationQueue alloc]init];
    }
    return _opQueue;
}

+ (TBCoreWebImage *)sharedCoreWebImage
{
    @synchronized(self){
        if (nil == coreWebImage) {
            coreWebImage = [[TBCoreWebImage alloc] init];
            coreWebImage.imageCache = [NSMutableDictionary dictionary];
            coreWebImage.waitForImage = [NSMutableDictionary dictionary];
        }
    }
    return coreWebImage;
}

// 第二次尝试
- (void)tryWhenError:(NSURL *)url {
    NSBlockOperation *operation2 = [NSBlockOperation blockOperationWithBlock:^{
        
        [NSThread sleepForTimeInterval:2];
        NSError *error = nil;
        NSData *data = [NSData dataWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:&error];
        
        UIImage *image = [UIImage imageWithData:data];
        
        // 缓存并执行目标array所有block
        if (image) {
            self.imageCache[url.absoluteString] = image;
            
            NSMutableArray<UIImageView *> *array = self.waitForImage[url.absoluteString];
            for (UIImageView *imageView in array) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    imageView.imageBlock(image);
                });
            }
            [array removeAllObjects];
        }
        
        // 移除执行缓存
        [self.operationCache removeObjectForKey:url];
    }];
    // 保存缓存
    self.operationCache[url.absoluteString] = operation2;
    [self.opQueue addOperation:operation2];
}

- (void)url:(NSURL *)url targetView:(UIImageView *)targetView block:(void(^)(UIImage *image)) myBlock option:(TBWebImageOptions)option completedBlock:(TBExternalCompletionBlock)completionBlock{
    
    // 移除view
    [self.waitForImage enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSMutableArray<UIImageView *> * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj removeObject:targetView];
    }];
    
    // 如果缓存有，就直接返回
    if (self.imageCache[url.absoluteString]) {
        !myBlock? : myBlock(self.imageCache[url.absoluteString]);
        !completionBlock? : completionBlock(self.imageCache[url.absoluteString], nil, url);
        return;
    }else {// 去数据库获取缓存数据
        TBDBTool *tool = [TBDBTool shareInstance];
        UIImage *dbImageCache = [tool image:url.absoluteString];
        if (dbImageCache) {
            self.imageCache[url.absoluteString] = dbImageCache;
            !myBlock? : myBlock(self.imageCache[url.absoluteString]);
            !completionBlock? : completionBlock(self.imageCache[url.absoluteString], nil, url);
            return;
        }
    }
    
    // 网络数据
    if (self.operationCache[url.absoluteString]) {// 正在处理中
        
    }else {
        
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            
            int delay = arc4random() % 10;
            
            [NSThread sleepForTimeInterval:delay];
            NSError *error = nil;
            NSData *data = [NSData dataWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:&error];
            
            UIImage *image = [UIImage imageWithData:data];
            
            // 缓存并执行目标array所有block
            if (image) {
                
                // 保存到数据库
                TBDBTool *tool = [TBDBTool shareInstance];
                [tool saveImage:url.absoluteString image:image];
                
                
                [self.imageCache setValue:image forKey:url.absoluteString];
                
                NSMutableArray<UIImageView *> *array = self.waitForImage[url.absoluteString];
                for (UIImageView *imageView in array) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        !imageView.imageBlock? : imageView.imageBlock(image);
                        !imageView.completionBlock? : imageView.completionBlock(image, error, url);
                    });
                }
                [array removeAllObjects];
                
            }else if(error && (option & TBWebImageRetryFailed)) {// 发生错误就重试一次
                [self tryWhenError:url];
            }
            
            // 移除执行缓存
            [self.operationCache removeObjectForKey:url];
        }];
        
        // 保存缓存
        self.operationCache[url.absoluteString] = operation;
        [self.opQueue addOperation:operation];
    }
    
    NSMutableArray<UIImageView *> *array = self.waitForImage[url.absoluteString];
    if (array == nil) {
        array = [NSMutableArray array];
        self.waitForImage[url.absoluteString] = array;
    }
    [array addObject:targetView];
}


//- (void)saveImage:(UIImage *)image {
//
//    NSString *uuid = [[NSUUID UUID] UUIDString];
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
//    NSString *path = [paths[0] stringByAppendingString:@"/tangbin/image/cache"];
//
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    BOOL isExist = [fileManager fileExistsAtPath:path];
//    if (isExist) {
//        NSLog(@"目录已经存在");
//    }else {
//        BOOL ret = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
//        if (ret) {
//            NSLog(@"目录创建成功");
//        }else {
//            NSLog(@"目录创建失败");
//        }
//    }
//
//    NSString *filePath = [path stringByAppendingPathComponent:uuid];   // 保存文件的名称
//    BOOL result = [UIImagePNGRepresentation(image) writeToFile: filePath atomically:YES]; // 保存成功会返回YES
//    NSLog(@"result %d", result);
//
//    // 保存到数据库
//    if (result) {
//
//    }
//}

//- (UIImage *)getImageByUrl:(NSString *)filePath {
//    UIImage *image2 = [UIImage imageWithContentsOfFile:filePath];
//    return image2;
//}









@end
