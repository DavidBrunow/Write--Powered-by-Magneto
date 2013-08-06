//
//  DHBMedia.h
//  Write
//
//  Created by David Brunow on 6/22/13.
//  Copyright (c) 2013 David Brunow. All rights reserved.
//

#import "DHBBlog.h"
#import <Foundation/Foundation.h>

@interface DHBMedia : NSObject

@property (nonatomic, retain) NSString *fileName;
@property (nonatomic, retain) NSString *localPath;
@property (nonatomic, retain) NSString *dropBoxPath;
@property (nonatomic, retain) NSString *rev;
@property (nonatomic, retain) NSString *mediaType;
@property (nonatomic, retain) NSString *codeTag;
@property (nonatomic, retain) NSString *altText;
@property (nonatomic) bool isUploaded;

-(id) initWithTitle:(NSString *) title andMedia:(id) media andBlog:(DHBBlog *) blog;
-(id) initLocalMediaWithTitle:(NSString *) title;
-(void) saveWithMedia:(id) media;
-(void) deleteLocalMedia;

@end
