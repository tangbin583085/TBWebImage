//
//  TBModel.m
//  02-表格图片下载
//
//  Created by apple on 15-1-16.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "TBModel.h"

@implementation TBModel

+ (instancetype)appWithDict:(NSDictionary *)dict
{
    TBModel *app = [[self alloc] init];
    
    [app setValuesForKeysWithDictionary:dict];
    
    return app;
}


@end
