//
//  DemoController.m
//  数据库
//
//  Created by admin on 17/1/13.
//  Copyright © 2017年 北京奥泰瑞格科技有限公司. All rights reserved.
//

#import "DemoController.h"
#import "DBManager.h"

@interface DemoController ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) NSDictionary *myDict;

@end

static NSString *UITableViewCellID = @"UITableViewCellID";

@implementation DemoController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setValuesToViews];
}

-(void)setUID:(int)uID{
    _uID = uID;
    self.myDict = [[DBManager sharedSqliteUtil] loadMovieDict:uID];

}

-(void)setValuesToViews{
    if (nil == _titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 64, 300, 30)];
        _titleLabel.text = self.myDict[field_MovieTitle];
        [self.view addSubview:_titleLabel];
    }
    
}



@end
