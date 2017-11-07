//
//  TBWebImageViewVC.m
//  TBCoreData8
//
//  Created by hanchuangkeji on 2017/11/6.
//  Copyright © 2017年 hanchuangkeji. All rights reserved.
//

#import "TBWebImageViewVC.h"
#import "UIImageView+TBWebImage.h"
#import "TBModel.h"
#import "TBCoreWebImage.h"

@interface TBWebImageViewVC ()
@property (nonatomic, strong)NSMutableArray *dataSource;
@end

@implementation TBWebImageViewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
}

- (NSArray *)dataSource {
    if (_dataSource == nil) {
        _dataSource = [NSMutableArray array];
        
        NSArray *dictArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"apps.plist" ofType:nil]];
        
        // 字典转模型
        for (NSDictionary *dict in dictArray) {
            TBModel *app = [TBModel appWithDict:dict];
            [_dataSource addObject:app.icon];
        }
        [_dataSource addObjectsFromArray:_dataSource];
        [_dataSource addObjectsFromArray:_dataSource];
        [_dataSource addObjectsFromArray:_dataSource];
        [_dataSource addObjectsFromArray:_dataSource];
    }
    return _dataSource;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row];
    cell.imageView.image = nil;
    [cell.imageView tb_setImageWithURL:[NSURL URLWithString:self.dataSource[indexPath.row]] placeholderImage:[UIImage imageNamed:@"user_default"]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[TBCoreWebImage sharedCoreWebImage] tb_didReceiveMemoryWarning];
//    [self.tableView reloadData];
}



@end
