//
//  ViewController.m
//  数据库
//
//  Created by admin on 17/1/12.
//  Copyright © 2017年 北京奥泰瑞格科技有限公司. All rights reserved.
//

#import "ViewController.h"
#import "DBManager.h"
#import "DemoController.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) NSMutableArray *myData;

@end

static NSString *UITableViewCellID = @"UITableViewCellID";

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setupUI];
}

-(void)setupUI{
    if (nil == _myTableView) {
        _myTableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _myTableView.delegate = self;
        _myTableView.dataSource = self;
        [_myTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:UITableViewCellID];
        [self.view addSubview:_myTableView];
    }
}


#pragma mark - UItableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.myData.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:UITableViewCellID forIndexPath:indexPath];
    
    NSDictionary *dict = self.myData[indexPath.row];
    
    cell.textLabel.text = dict[field_MovieTitle];
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    DemoController *demoVC = [[DemoController alloc]init];
    
    NSDictionary *dict = self.myData[indexPath.row];
    demoVC.uID = [dict[field_MovieID] intValue];
    
    [self.navigationController pushViewController:demoVC animated:YES];
}
//左滑删除
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSDictionary *dict = self.myData[indexPath.row];
        
        if ([[DBManager sharedSqliteUtil] deleteMovie: [dict[field_MovieID] intValue]]) {
            [self.myData removeObjectAtIndex:indexPath.row];
            [self.myTableView reloadData];
        }
    }
}


#pragma mark - 懒加载
-(NSMutableArray *)myData{
    if (nil == _myData) {
        _myData = [[DBManager sharedSqliteUtil] loadMovies];
    }
    return _myData;
}

@end
