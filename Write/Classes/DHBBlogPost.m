//
//  DHBBlogPost.m
//  Write
//
//  Created by David Brunow on 4/21/13.
//  Copyright (c) 2013 David Brunow. All rights reserved.
//

#import "DHBBlogPost.h"
#import "DHBAppDelegate.h"

@implementation DHBBlogPost

-(id) init
{
    [self setIsDraft:NO];
    return self;
}

-(id) initWithLocalPath:(NSString *) path
{
    [self setLocalPath:path];
    [self setIsDraft:NO];
    
    return self;
}

-(void) saveWithContents:(NSString *)contents
{
    DHBAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

    if([self saveLocallyWithContents:contents]) {
        [appDelegate.dropBox.uploadClient loadMetadata:[NSString stringWithFormat:@"%@/%@", self.dropBoxPath, self.title]];
    
        [appDelegate.dropBox.uploadClient uploadFile:self.title toPath:self.dropBoxPath withParentRev:self.rev fromPath:self.localPath];
    }
}

-(void) deleteLocalPost
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    fileManager = [NSFileManager defaultManager];
    
    [fileManager removeItemAtPath:self.localPath error:nil];
}

-(BOOL) saveLocallyWithContents:(NSString *)contents
{
    NSData *dataBuffer = [[NSData alloc] init];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    fileManager = [NSFileManager defaultManager];
    
    dataBuffer = [contents dataUsingEncoding:NSUTF8StringEncoding];
    return [fileManager createFileAtPath:self.localPath contents:dataBuffer attributes:nil];
}

-(void)downloadDropboxFile
{
    DHBAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    [self setIsFileDownloaded:NO];
    
    [appDelegate.dropBox downloadFileToPath:self.localPath fromDropboxPath:[NSString stringWithFormat:@"%@/%@", self.dropBoxPath, self.title]];
}

-(void) postDraftWithContents:(NSString *)contents
{
    DHBAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    int startIndex = [contents rangeOfString:@"published"].location + @"published: ".length;
    int rangeLength = [contents rangeOfString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange([contents rangeOfString:@"published"].location, contents.length - [contents rangeOfString:@"published"].location)].location - startIndex;
    
    NSRange rangeToReplace = NSMakeRange(startIndex, rangeLength);
    
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    
    NSString *publishDateString = [formatter stringFromDate:[NSDate date]];
    
    contents = [contents stringByReplacingCharactersInRange:rangeToReplace withString:publishDateString];
    
    startIndex = [contents rangeOfString:@"title"].location + @"title: ".length;
    rangeLength = [contents rangeOfString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange([contents rangeOfString:@"title"].location, contents.length - [contents rangeOfString:@"title"].location)].location - startIndex;
    
    NSRange rangeToCopy = NSMakeRange(startIndex, rangeLength);
    
    [formatter setDateFormat:@"yyyy"];
    
    NSString *currentYear = [formatter stringFromDate:[NSDate date]];
    
    [formatter setDateFormat:@"MM"];
    NSString *currentMonth = [formatter stringFromDate:[NSDate date]];
    
    [formatter setDateFormat:@"dd"];
    NSString *currentDay = [formatter stringFromDate:[NSDate date]];
    
    NSString *newTitle = [NSString stringWithFormat:@"%@-%@-%@.md", currentMonth, currentDay, [[[contents substringWithRange:rangeToCopy] stringByReplacingOccurrencesOfString:@" " withString:@"-"] lowercaseString]];
    NSString *newLocalPath = [NSString stringWithFormat:@"%@", [self.localPath stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"drafts/%@", self.title] withString:[NSString stringWithFormat:@"items/%@/%@", currentYear, newTitle]]];
    NSString *newDropboxPath = [NSString stringWithFormat:@"%@%@", [self.dropBoxPath stringByReplacingOccurrencesOfString:@"drafts" withString:@""], [NSString stringWithFormat:@"items/%@/", currentYear]];
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    fileManager = [NSFileManager defaultManager];
    
    if(![fileManager fileExistsAtPath:[newLocalPath stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"/%@", newTitle] withString:@""]]) {
        [fileManager createDirectoryAtPath:[newLocalPath stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"/%@", newTitle] withString:@""] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSData *dataBuffer = [[NSData alloc] init];
    
    dataBuffer = [contents dataUsingEncoding:NSUTF8StringEncoding];
    
    [fileManager createFileAtPath:newLocalPath contents:dataBuffer attributes:nil];
    
    [appDelegate.dropBox.uploadClient uploadFile:newTitle toPath:newDropboxPath withParentRev:nil fromPath:newLocalPath];
    
    [appDelegate.dropBox.uploadClient deletePath:[NSString stringWithFormat:@"%@/%@",self.dropBoxPath, self.title]];
    
    [self setIsDraft:NO];
    [self setTitle:newTitle];
    [self setLocalPath:newLocalPath];
    [self setDropBoxPath:newDropboxPath];

}

-(NSUInteger) hash
{
    return _localPath.hash;
}

- (BOOL)isEqual:(id)object
{
    if([object isKindOfClass:[DHBBlogPost class]]) {
        DHBBlogPost *tempPost = object;
        if(tempPost.hash == self.hash) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

@end
