//
//  UIImageView+TBWebImage.m
//  TBCoreData8
//
//  Created by hanchuangkeji on 2017/11/6.
//  Copyright © 2017年 hanchuangkeji. All rights reserved.
//

#import "UIImageView+TBWebImage.h"
#import "TBCoreWebImage.h"
#import <objc/runtime.h>

static const char TBImageBlockKey = '\0';
static const char TBCompeleteBlockKey = '\0';

@implementation UIImageView (TBWebImage)

- (TBExternalCompletionBlock)completionBlock {
    return objc_getAssociatedObject(self, &TBCompeleteBlockKey);
}

- (void)setCompletionBlock:(TBExternalCompletionBlock)completionBlock {
    objc_setAssociatedObject(self, &TBCompeleteBlockKey, completionBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setImageBlock:(ImageBlock)imageBlock {
    
    objc_setAssociatedObject(self, &TBImageBlockKey, imageBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (ImageBlock)imageBlock {
    return objc_getAssociatedObject(self, &TBImageBlockKey);
}

- (void)setCoreImage:(UIImage * _Nullable)placeholder url:(NSURL * _Nullable)url option:(TBWebImageOptions)option completeBlock:(TBExternalCompletionBlock)completeBlock {
    
    self.image = placeholder;
    
    // 设置block
    __weak typeof(self) weakSelf = self;
    self.imageBlock = ^(UIImage * _Nullable image) {
        weakSelf.image = image;
    };
    self.completionBlock = completeBlock;
    
    TBCoreWebImage *coreWebImage = [TBCoreWebImage sharedCoreWebImage];
    [coreWebImage url:url targetView:self block:self.imageBlock option:option completedBlock:completeBlock];
}



#pragma mark 设置信息
- (void)tb_setImageWithURL:(nullable NSURL *)url {
    // 设置占位符 等信息
    [self setCoreImage:nil url:url option:0 completeBlock:nil];
}


- (void)tb_setImageWithURL:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder {
    
    // 设置占位符 等信息
    [self setCoreImage:placeholder url:url option:0 completeBlock:nil];
}

- (void)tb_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(TBWebImageOptions)options {
    // 设置占位符 等信息
    [self setCoreImage:placeholder url:url option:0 completeBlock:nil];
}

- (void)tb_setImageWithURL:(nullable NSURL *)url completed:(nullable TBExternalCompletionBlock)completedBlock {
    // 设置占位符 等信息
    [self setCoreImage:nil url:url option:0 completeBlock:completedBlock];
}

- (void)tb_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder completed:(nullable TBExternalCompletionBlock)completedBlock {
    // 设置占位符 等信息
    [self setCoreImage:placeholder url:url option:0 completeBlock:completedBlock];
}

- (void)tb_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(TBWebImageOptions)options completed:(nullable TBExternalCompletionBlock)completedBlock {
    // 设置占位符 等信息
    [self setCoreImage:placeholder url:url option:options completeBlock:completedBlock];
}



@end
