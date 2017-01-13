//
//  DBManager.h
//  数据库
//
//  Created by admin on 17/1/12.
//  Copyright © 2017年 北京奥泰瑞格科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

#define field_MovieID           @"movieID"
#define field_MovieTitle        @"title"
#define field_MovieCategory     @"category"
#define field_MovieYear         @"year"
#define field_MovieURL          @"movieURL"
#define field_MovieCoverURL     @"coverURL"
#define field_MovieWatched      @"watched"
#define field_MovieLikes        @"likes"

@interface DBManager : NSObject

+ (id)sharedSqliteUtil;

-(BOOL)CreateDataBase;
-(void)InsertData;

-(NSMutableArray*)loadMovies;
-(NSMutableArray*)loadMovies:(int)uID;
-(NSDictionary*)loadMovieDict:(int)uID;

-(void)updateMovie:(int)uID watched:(BOOL)isWatched likes:(int)likes;
-(BOOL)deleteMovie:(int)uID;

@end
