//
//  DHBBlogPost.h
//  Write
//
//  Created by David Brunow on 4/21/13.
//  Copyright (c) 2013 David Brunow. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DHBBlogPost : NSObject

@property (nonatomic, retain) NSString *localPath;
@property (nonatomic, retain) NSString *dropBoxPath;
@property (nonatomic, retain) NSString *rev;
@property (nonatomic) bool isDraft;
@property (nonatomic) bool isLinkPost;
@property (nonatomic) bool isFileDownloaded;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *body;
@property (nonatomic, retain) NSDate *publishDate;
@property (nonatomic, retain) NSDate *createDate;
@property (nonatomic, retain) NSDate *lastModifiedDate;

-(id) initWithLocalPath:(NSString *) path;
-(void) saveWithContents:(NSString *) contents;
-(BOOL) saveLocallyWithContents:(NSString *) contents;
-(void) postDraftWithContents:(NSString *)contents;
-(void) downloadDropboxFile;
-(void) deleteLocalPost;

@end
