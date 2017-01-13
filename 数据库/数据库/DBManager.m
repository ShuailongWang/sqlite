//
//  DBManager.m
//  数据库
//
//  Created by admin on 17/1/12.
//  Copyright © 2017年 北京奥泰瑞格科技有限公司. All rights reserved.
//

#import "DBManager.h"
#import "FMDB.h"






@interface DBManager()

@property (nonatomic, copy) NSString *dbPath;
@property (nonatomic, strong) FMDatabase *dataBase;

@end



@implementation DBManager


+ (id)sharedSqliteUtil{
    static DBManager *share_client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        share_client = [[DBManager alloc] init];
    });

    return share_client;
}

-(BOOL)CreateDataBase{
    BOOL isCreate = NO;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //
    if (![fileManager fileExistsAtPath: self.dbPath]) {
        if (self.dataBase != nil) {
            if ([self.dataBase open]) {
                NSString *sql = [NSString stringWithFormat:@"create table movies (%@ integer primary key autoincrement not null, %@ text not null, %@ text not null, %@ integer not null, %@ text, %@ text not null, %@ bool not null default 0, %@ integer not null)", field_MovieID, field_MovieTitle, field_MovieCategory, field_MovieYear, field_MovieURL, field_MovieCoverURL, field_MovieWatched, field_MovieLikes];
                
                isCreate = [self.dataBase executeUpdate:sql values:nil error:nil];
                [self.dataBase close];
            }
        }
    }
    
    return isCreate;
}

//打开数据库
-(BOOL)OpenDataBase{
    if ([self.dataBase open]) {
        return true;
    }
    
    return false;
}


//插入数据
-(void)InsertData{
    if ([self OpenDataBase]) {
        NSString *path = [[NSBundle mainBundle]pathForResource:@"movies" ofType:@"tsv"];
        NSString *moveFile = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        NSArray *movieData = [moveFile componentsSeparatedByString:@"\r\n"];
        NSMutableString *sql = [NSMutableString string];
        for (NSString *str in movieData) {
            NSArray *arr = [str componentsSeparatedByString:@"\t"];
            
            if (arr.count == 5) {
                NSString *movieTitle = arr[0];
                NSString *movieCategory = arr[1];
                NSInteger movieYear = [arr[2] integerValue];
                NSString *movieURL = arr[3];
                NSString *movieCoverURL = arr[4];
                
                [sql appendFormat: @"insert into movies (movieID, title, category, year, movieURL, coverURL, watched,likes) values (null, '%@', '%@', %zd, '%@', '%@', 0, 0);", movieTitle, movieCategory, movieYear, movieURL, movieCoverURL];
            }
        }
        if (![self.dataBase executeStatements:sql]) {
            NSLog(@"Failed to insert initial data into the database.");
            NSLog(@"%@-->%@",self.dataBase.lastError, self.dataBase.lastErrorMessage);
        }
        
        [self.dataBase close];
    }
}

//加载全部数据
-(NSMutableArray*)loadMovies{
    NSMutableArray *arrM = [NSMutableArray array];
    
    if ([self OpenDataBase]) {
        NSString *sql = [NSString stringWithFormat:@"select * from movies order by %@ asc", field_MovieYear];
        
        FMResultSet *resultSet = [self.dataBase executeQuery:sql values:nil error:nil];
        //  遍历结果集,判断是否有下一条记录
        while ([resultSet next]) {
            //获取列数
            int cols = resultSet.columnCount;
            NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
            
            //遍历列数
            for (int i = 0; i < cols; i++) {
                //获取列名
                NSString *colNmae = [resultSet columnNameForIndex:i];
                
                //获取列名对应的值
                NSString *colValue = [resultSet objectForColumnIndex:i];
                
                dictM[colNmae] = colValue;
            }
            [arrM addObject:dictM];
        }
        [self.dataBase close];
    }
    
    return arrM;
}

//根据ID 查询数据
-(NSMutableArray*)loadMovies:(int)uID{
    NSMutableArray *arrM = [NSMutableArray array];
    
    if ([self OpenDataBase]) {
        NSString *sql = [NSString stringWithFormat:@"select * from movies where movieID = %d ", uID];

        FMResultSet *resultSet = [self.dataBase executeQuery:sql values:nil error:nil];
        //  遍历结果集,判断是否有下一条记录
        while ([resultSet next]) {
            //获取列数
            int cols = resultSet.columnCount;
            NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
            
            //遍历列数
            for (int i = 0; i < cols; i++) {
                //获取列名
                NSString *colNmae = [resultSet columnNameForIndex:i];
                
                //获取列名对应的值
                NSString *colValue = [resultSet objectForColumnIndex:i];
                
                dictM[colNmae] = colValue;
            }
            [arrM addObject:dictM];
        }
        
        [self.dataBase close];
    }
    return arrM;
}

-(NSDictionary*)loadMovieDict:(int)uID{
    
    NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
    
    if ([self OpenDataBase]) {
        NSString *sql = [NSString stringWithFormat:@"select * from movies where movieID = %d ", uID];
        
        FMResultSet *resultSet = [self.dataBase executeQuery:sql values:nil error:nil];

        //  遍历结果集,判断是否有下一条记录
        while ([resultSet next]) {
            //获取列数
            int cols = resultSet.columnCount;
            
            //遍历列数
            for (int i = 0; i < cols; i++) {
                //获取列名
                NSString *colNmae = [resultSet columnNameForIndex:i];
                
                //获取列名对应的值
                NSString *colValue = [resultSet objectForColumnIndex:i];
                
                dictM[colNmae] = colValue;
            }
        }
        [self.dataBase close];
    }
    return dictM.copy;
}

//更新数据
-(void)updateMovie:(int)uID watched:(BOOL)isWatched likes:(int)likes{
    if ([self OpenDataBase]) {
        NSString *sql = [NSString stringWithFormat:@"update movies set field_MovieWatched = %d, field_MovieLikes = %d where field_MovieID = %d", uID, isWatched, likes];
        
        if(![self.dataBase executeUpdate:sql values:nil error:nil]){
            NSLog(@"跟新失败");
        }
        
        [self.dataBase close];
    }
}

//删除数据
-(BOOL)deleteMovie:(int)uID{
    BOOL deleted = NO;
    
    if ([self OpenDataBase]) {
        NSString *sql = [NSString stringWithFormat:@"delete from movies where %d ", uID];
        
        deleted = [self.dataBase executeUpdate:sql values:nil error:nil];
        
        if (!deleted) {
            NSLog(@"删除失败");
        }
        
        [self.dataBase close];
    }
    
    return deleted;
}


-(FMDatabase *)dataBase{
    if (nil == _dataBase) {
        _dataBase = [FMDatabase databaseWithPath: self.dbPath];
    }
    return _dataBase;
}
-(NSString *)dbPath{
    NSString *dbPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"DBName.sqlite"];
    return dbPath;
}


@end
