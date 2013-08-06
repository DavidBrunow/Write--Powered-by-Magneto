//
//  DHBDropBox.h
//  Write
//
//  Created by David Brunow on 4/21/13.
//  Copyright (c) 2013 David Brunow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DropboxSDK/DropboxSDK.h>

@interface DHBDropBox : NSObject <DBNetworkRequestDelegate, DBRestClientDelegate, DBSessionDelegate>

@property (strong, nonatomic) DBSession *dbSession;
@property (strong, nonatomic) DBRestClient *restClient;
@property (strong, nonatomic) DBRestClient *downloadClient;
@property (strong, nonatomic) DBRestClient *uploadClient;
@property (strong, nonatomic) NSMutableArray *blogOptions;
@property (strong, nonatomic) NSMutableData *dropboxData;
@property (nonatomic) bool hasFinishedLoading;
@property (nonatomic) bool hasFinishedDownloading;

- (void) connectToDropBox;
- (void) downloadFilesToPath:(NSString *) path;
- (void) downloadFileToPath:(NSString *) path fromDropboxPath:(NSString *) dropboxPath;
- (void) uploadFilesFromPath:(NSString *) path;
- (NSString *)documentsPathForFileName:(NSString *)name;

@end
