//
//  TBCoreWebImage.h
//  TBCoreData8
//
//  Created by hanchuangkeji on 2017/11/6.
//  Copyright © 2017年 hanchuangkeji. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UIImageView+TBWebImage.h"

@interface TBCoreWebImage : NSObject

+ (TBCoreWebImage *)sharedCoreWebImage;

- (void)url:(NSURL *)url targetView:(UIView *)targetView block:(void(^)(UIImage *image)) myBlock option:(TBWebImageOptions)option completedBlock:(TBExternalCompletionBlock)completionBlock;


- (void)tb_didReceiveMemoryWarning;

@end
