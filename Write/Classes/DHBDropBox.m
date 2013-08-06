//
//  DHBDropBox.m
//  Write
//
//  Created by David Brunow on 4/21/13.
//  Copyright (c) 2013 David Brunow. All rights reserved.
//

#import "DHBDropBox.h"
#import "DHBAppDelegate.h"
#import "DHBCredentials.h"
#import "SimpleKeychain.h"
#import "DHBBlog.h"
#import "DHBBlogPost.h"
#import "DHBMedia.h"
#import "DHBNotificationView.h"

@implementation DHBDropBox 

- (id)init
{
    
    self.dbSession = [[DBSession alloc] initWithAppKey:CONSUMER_KEY appSecret:CONSUMER_SECRET root:kDBRootDropbox]; // either kDBRootAppFolder or kDBRootDropbox
    [self.dbSession setDelegate:self];
    [DBSession setSharedSession:self.dbSession];
    
    [DBRequest setNetworkRequestDelegate:self];
    
    self.blogOptions = [[NSMutableArray alloc] init];
    [self setHasFinishedLoading:NO];
    [self setHasFinishedDownloading:NO];
    self.dropboxData = [[NSMutableData alloc] init];
    
    return self;
}

- (void) connectToDropBox
{
    DHBAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSString *oAuthToken = [SFHFKeychainUtils getPasswordForUsername:USER_NAME_TOKEN andServiceName:SERVICE_NAME error:nil];
    NSString *oAuthTokenSecret = [SFHFKeychainUtils getPasswordForUsername:USER_NAME_TOKEN_SECRET andServiceName:SERVICE_NAME error:nil];
    NSString *userID = [SFHFKeychainUtils getPasswordForUsername:USER_NAME_USER_NAME andServiceName:SERVICE_NAME error:nil];

    if(oAuthToken != nil && oAuthTokenSecret != nil && userID != nil) {
        [self.dbSession updateAccessToken:oAuthToken accessTokenSecret:oAuthTokenSecret forUserId:userID];
    }
    
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:appDelegate.window.rootViewController];
    } else {
        [self.restClient searchPath:@"/" forKeyword:@"config.yaml"];
    }
}

- (void) downloadFilesToPath:(NSString *) path
{
    [self setHasFinishedDownloading:NO];
    [self.downloadClient loadMetadata:path];
}

- (void) downloadFileToPath:(NSString *) path fromDropboxPath:(NSString *) dropboxPath
{
    [self setHasFinishedDownloading:NO];
    [self.downloadClient loadFile:[NSString stringWithFormat:@"%@", dropboxPath] intoPath:path];
}

- (void) uploadFilesFromPath:(NSString *)path
{
    [self.uploadClient uploadFile:@"" toPath:@"" withParentRev:@"" fromPath:path];
}

- (DBRestClient *)restClient {
    if (!_restClient) {
        _restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        _restClient.delegate = self;
    }
    return _restClient;
}

- (DBRestClient *)downloadClient {
    if (!_downloadClient) {
        _downloadClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        _downloadClient.delegate = self;
    }
    return _downloadClient;
}

- (DBRestClient *)uploadClient {
    if (!_uploadClient) {
        _uploadClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        _uploadClient.delegate = self;
    }
    return _uploadClient;
}

- (NSString *)documentsPathForFileName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    return [documentsPath stringByAppendingPathComponent:name];
}

- (void)restClient:(DBRestClient *)client loadedFile:(NSString *)destPath contentType:(NSString *)contentType metadata:(DBMetadata *)metadata
{
    DHBAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    DHBBlog *thisBlog = [appDelegate.settings.blogs objectAtIndex:appDelegate.settings.selectedBlog];

    for(DHBBlogPost *post in thisBlog.posts) {
        if([post.localPath isEqualToString:destPath]) {
            [post setIsFileDownloaded:YES];
        }
    }
}

- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath from:(NSString *)srcPath metadata:(DBMetadata *)metadata
{
    DHBAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

    for (DHBBlog *blog in appDelegate.settings.blogs) {
        for (DHBBlogPost *post in blog.posts) {
            if([post.title isEqualToString:metadata.filename]) {
                if([post.rev isEqualToString:metadata.rev]) {
                    //If I'm thinking about this correctly, then this should only happen when the uploaded file is the same as the local file. Otherwise, there would be a new rev
                    [post deleteLocalPost];
                } else {
                    [post setRev:metadata.rev];
                }
            } else {
            }
        }
    }
    
    if([metadata.filename rangeOfString:@"md"].location == NSNotFound) {
        DHBNotificationView *uploadNotification = [[DHBNotificationView alloc] initWithFrame:CGRectZero];
        [uploadNotification.notificationLabel setText:@"Media Uploaded!"];
        uploadNotification.screen = [UIScreen mainScreen];
        
        [uploadNotification displayNotification];
        
        DHBMedia *mediaToDeleteLocally = [[DHBMedia alloc] initLocalMediaWithTitle:metadata.filename];
        
        [mediaToDeleteLocally deleteLocalMedia];
    }
    
    NSLog(@"The file %@ has been uploaded", metadata.filename);
}

- (void)restClient:(DBRestClient *)client uploadProgress:(CGFloat)progress forFile:(NSString *)destPath from:(NSString *)srcPath
{
    NSLog(@"The file %@ is %f%% uploaded", destPath, progress * 100);
}

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error
{
    NSLog(@"You had an error in uploading the file: %@", error);
}

-(void) restClient:(DBRestClient *)restClient loadedSearchResults:(NSArray *)results forPath:(NSString *)path keyword:(NSString *)keyword
{
    DHBAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

    for(DBMetadata *result in results) {
        DHBBlog *tempBlog = [[DHBBlog alloc] initWithPath:[result.path stringByReplacingOccurrencesOfString:@"config.yaml" withString:@""]];

        if((self.blogOptions.count == 0 || ![self.blogOptions containsObject:result]) && ![appDelegate.settings.blogs containsObject:tempBlog]) {
            [self.blogOptions addObject:tempBlog];
        } else {
        }
    }
    
    [self setHasFinishedLoading:YES];
}

-(void) restClient:(DBRestClient *)restClient searchFailedWithError:(NSError *)error
{
    NSLog(@"You had a fucking search error! %@", error);
}

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata
{
    DHBAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

    if(client == self.downloadClient) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex:0];
        int numberOfPosts = -1;
        
        if (metadata.isDirectory) {
            
            NSArray *sortedMetadataContents = [[NSArray alloc] initWithArray:metadata.contents];
            
            sortedMetadataContents = [sortedMetadataContents sortedArrayUsingComparator: ^(DBMetadata *obj1, DBMetadata *obj2) {
                if([obj1.clientMtime earlierDate:obj2.clientMtime] == obj2.clientMtime) {
                    return (NSComparisonResult) NSOrderedAscending;
                } else if ([obj1.clientMtime isEqualToDate:obj2.clientMtime]) {
                    return (NSComparisonResult) NSOrderedSame;
                } else {
                    return (NSComparisonResult) NSOrderedDescending;
                }
            }];
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            
            [formatter setDateFormat:@"yyyy"];
            NSString *thisYear = [formatter stringFromDate:[NSDate date]];
            
            for (DBMetadata *file in sortedMetadataContents) {
                if([file isDirectory]) {
                    //Show everything in the drafts folder, but only the posts from this year
                    if([file.filename isEqualToString:@"drafts"] || [file.filename isEqualToString:@"items"] || [file.filename isEqualToString:thisYear]) {
                        [self.downloadClient loadMetadata:file.path];
                    }
                } else {
                    if([[file.filename substringFromIndex:file.filename.length - 2] isEqualToString:@"md"] && ([metadata.path rangeOfString:@"items/"].length > 0 || [metadata.path rangeOfString:@"drafts"].length > 0)) {
                        NSString *localPath = [NSString stringWithFormat:@"%@%@", documentsPath, file.path];
                        
                        //[self.downloadClient loadFile:[NSString stringWithFormat:@"%@", file.path] intoPath:localPath];
                        
                        DHBBlogPost *post = [[DHBBlogPost alloc] initWithLocalPath:localPath];
                        [post setDropBoxPath:metadata.path];
                        [post setRev:file.rev];
                        [post setTitle:file.filename];
                        [post setLastModifiedDate:file.lastModifiedDate];
                        
                        if([metadata.path rangeOfString:@"drafts"].length > 0) {
                            [post setIsDraft:YES];
                        } else {
                            [post setIsDraft:NO];
                            numberOfPosts++;
                        }
                        
                        NSFileManager *fileManager = [NSFileManager defaultManager];
                        
                        //if post exists locally, check to see if the file modified date is more recent than dropbox's version
                        if([fileManager fileExistsAtPath:post.localPath]) {
                            NSDate *localModifiedDate = [[fileManager attributesOfItemAtPath:post.localPath error:nil] objectForKey:NSFileModificationDate];
                            
                            if([localModifiedDate earlierDate:file.clientMtime] == file.clientMtime) {
                                //if the file modified date is more recent, then update the dropbox copy with the new rev
                                NSLog(@"File: %@; Local Modified Date: %@, Dropbox Modified Date: %@", post.title, localModifiedDate, file.clientMtime);
                                [self.uploadClient uploadFile:post.title toPath:post.dropBoxPath withParentRev:post.rev fromPath:post.localPath];
                            } else if([localModifiedDate isEqualToDate:file.clientMtime]) {
                                //delete the local copies of ones that match so the local filesystem doesnt get out of control
                                [fileManager removeItemAtPath:post.localPath error:nil];
                            } else {
                                //otherwise, change the filename and upload to Dropbox as a conflicted copy
                                NSString *newTitle = [post.title stringByReplacingOccurrencesOfString:@".md" withString:[NSString stringWithFormat:@"%@_Conflicted_by_Write_%@.md", post.title, [NSDate date]]];
                                NSString *newLocalPath = [post.localPath stringByReplacingOccurrencesOfString:post.title withString:newTitle];

                                [fileManager moveItemAtPath:post.localPath toPath:newLocalPath error:nil];
                                
                                [post setLocalPath:newLocalPath];
                                [post setTitle:newTitle];
                                
                                [self.uploadClient uploadFile:post.title toPath:post.dropBoxPath withParentRev:nil fromPath:post.localPath];
                            }
                        }
                        
                        NSMutableArray *blogArray = appDelegate.settings.blogs;
                        int blogIndex = 0;
                        
                        for (DHBBlog *thisBlog in blogArray) {
                            if([post.dropBoxPath rangeOfString:thisBlog.path].location != NSNotFound) {
                                blogIndex = [blogArray indexOfObject:thisBlog];
                            }
                        }
                        
                        DHBBlog *blog = [appDelegate.settings.blogs objectAtIndex:blogIndex];
                        //Don't duplicate posts, and don't allow more than 10 posts
                        if(![blog.posts containsObject:post] && ((post.isDraft == NO && numberOfPosts < 10) || post.isDraft == YES)) {
                            [blog.posts insertObject:post atIndex:blog.posts.count];
                        }
                    }
                }
            }
        }
        [self setHasFinishedDownloading:YES];
    }
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error
{
    NSLog(@"Error loading metadata: %@", error);
}

- (void)sessionDidReceiveAuthorizationFailure:(DBSession *)session userId:(NSString *)userId
{
    NSLog(@"Error: %@", userId);
}


- (void)networkRequestStarted
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)networkRequestStopped
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

@end


