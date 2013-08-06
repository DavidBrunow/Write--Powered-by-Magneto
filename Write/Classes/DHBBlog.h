//
//  DHBBlog.h
//  Write
//
//  Created by David Brunow on 4/21/13.
//  Copyright (c) 2013 David Brunow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DHBBlogPost.h"

@interface DHBBlog : NSObject

@property (nonatomic, retain) NSString *path;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSMutableArray *posts;

-(id) initWithPath: (NSString *) path;
-(DHBBlogPost *)createDraftWithTitle:(NSString *)title;
-(void)downloadDropboxFiles;

@end
