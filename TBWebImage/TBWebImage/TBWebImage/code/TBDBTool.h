//
//  TBDBToll.h
//  TBCoreData8
//
//  Created by hanchuangkeji on 2017/11/7.
//  Copyright © 2017年 hanchuangkeji. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TBDBTool : NSObject

+(instancetype) shareInstance;


- (BOOL)saveImage:(NSString *)url image:(UIImage *)image;

- (UIImage *)image:(NSString *)url;


@end
