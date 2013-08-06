//
//  DHBBlog.m
//  Write
//
//  Created by David Brunow on 4/21/13.
//  Copyright (c) 2013 David Brunow. All rights reserved.
//

#import "DHBBlog.h"
#import "DHBBlogPost.h"
#import "DHBAppDelegate.h"
#import "DHBMedia.h"

@implementation DHBBlog

-(id)init
{
    return self;
}

-(id)initWithPath:(NSString *) path
{
    _posts = [[NSMutableArray alloc] init];
    [self setPath:path];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@%@", documentsPath, self.path]]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@%@%@", documentsPath, self.path, @"/drafts/"] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@%@%@", documentsPath, self.path, @"/drafts/"]]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@%@%@", documentsPath, self.path, @"/drafts/"] withIntermediateDirectories:NO attributes:nil error:nil];
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@%@%@", documentsPath, path, @"/items/2013"]]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@%@%@", documentsPath, path, @"/items/2013"] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return self;
}

-(void)insertObject:(DHBBlogPost *)object inPostsAtIndex:(NSUInteger)index
{
    [self.posts insertObject:object atIndex:index];
    
    return;
}

-(void)removeObjectFromPostsAtIndex:(NSUInteger)index
{
    [self.posts removeObjectAtIndex:index];
    return;
}

-(void)downloadDropboxFiles
{
    DHBAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

    [appDelegate.dropBox downloadFilesToPath:self.path];
}

-(DHBBlogPost *)createDraftWithTitle:(NSString *)title
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    
    NSString *draftDateString = [formatter stringFromDate:[NSDate date]];
    
    NSString *fileName = [[NSString stringWithFormat:@"%@.md", [title stringByReplacingOccurrencesOfString:@" " withString:@"-"]] lowercaseString];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    NSString *newFilePath = [NSString stringWithFormat:@"%@%@/drafts/%@", documentsPath, self.path, fileName];
    
    NSString *newFileContents = [NSString stringWithFormat:@"---\npublished: %@\ntitle: %@\n---\n", draftDateString, title];
        
    DHBBlogPost *newBlogPost = [[DHBBlogPost alloc] initWithLocalPath:newFilePath];
    [newBlogPost setTitle:fileName];
    [newBlogPost setIsDraft:YES];
    [newBlogPost setDropBoxPath:[NSString stringWithFormat:@"%@/drafts", self.path]];
    [newBlogPost setRev:nil];
    
    int postIndex = 0;
    
    if(self.posts.count > 0) {
        postIndex = self.posts.count;
    }
    
    [self.posts insertObject:newBlogPost atIndex:postIndex];
    
    [newBlogPost saveWithContents:newFileContents];
    
    return newBlogPost;
}

-(NSUInteger) hash
{
    return _path.hash;
}

- (BOOL)isEqual:(id)object
{
    if([object isKindOfClass:[DHBBlog class]]) {
        DHBBlog *tempBlog = object;
        if(tempBlog.hash == self.hash) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

@end
