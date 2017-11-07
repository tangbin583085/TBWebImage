//
//  UIImageView+TBWebImage.h
//  TBCoreData8
//
//  Created by hanchuangkeji on 2017/11/6.
//  Copyright © 2017年 hanchuangkeji. All rights reserved.
//

#import <UIKit/UIKit.h>



typedef NS_OPTIONS(NSUInteger, TBWebImageOptions) {
    TBWebImageRetryFailed = 1 << 0,
    TBWebImageLowPriority = 1 << 1,
};

typedef void(^ _Nullable ImageBlock)(UIImage * _Nullable image);
typedef void(^ _Nullable TBExternalCompletionBlock)(UIImage * _Nullable image, NSError * _Nullable error, NSURL * _Nullable url);

@interface UIImageView (TBWebImage)

@property (nonatomic, copy)ImageBlock imageBlock;

@property (nonatomic, copy)TBExternalCompletionBlock completionBlock;



- (void)tb_setImageWithURL:(nullable NSURL *)url;

- (void)tb_setImageWithURL:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder;

- (void)tb_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(TBWebImageOptions)options;

- (void)tb_setImageWithURL:(nullable NSURL *)url completed:(nullable TBExternalCompletionBlock)completedBlock;

- (void)tb_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder completed:(nullable TBExternalCompletionBlock)completedBlock;


- (void)tb_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(TBWebImageOptions)options completed:(nullable TBExternalCompletionBlock)completedBlock;
@end
