//
//  DHBMedia.m
//  Write
//
//  Created by David Brunow on 6/22/13.
//  Copyright (c) 2013 David Brunow. All rights reserved.
//

#import "DHBMedia.h"
#import "DHBAppDelegate.h"
#import "DHBDropBox.h"
#import <AVFoundation/AVFoundation.h>

@implementation DHBMedia

-(id) initWithTitle:(NSString *) title andMedia:(id)media andBlog:(DHBBlog *)blog
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    
    NSString *currentYear = [formatter stringFromDate:[NSDate date]];
    
    [formatter setDateFormat:@"MM"];
    NSString *currentMonth = [formatter stringFromDate:[NSDate date]];
    
    if([media isKindOfClass:[UIImage class]]) {
        [self setMediaType:@"image"];
        self.fileName = [NSString stringWithFormat:@"%@.JPG",[title stringByReplacingOccurrencesOfString:@" " withString:@""]];
    } else if([media isKindOfClass:[NSURL class]]) {
        [self setMediaType:@"html5video"];
        self.fileName = [NSString stringWithFormat:@"%@.MP4",[title stringByReplacingOccurrencesOfString:@" " withString:@""]];
    }
    
    [self setLocalPath:[NSString stringWithFormat:@"%@%@items/media/%@/%@/", documentsPath, blog.path, currentYear, currentMonth]];
    [self setDropBoxPath:[NSString stringWithFormat:@"%@items/media/%@/%@/", blog.path, currentYear, currentMonth]];
    [self setAltText:title];
    
    [self saveWithMedia:media];
    
    return self;
}

-(id) initLocalMediaWithTitle:(NSString *)title
{
    DHBAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    
    NSString *currentYear = [formatter stringFromDate:[NSDate date]];
    
    [formatter setDateFormat:@"MM"];
    NSString *currentMonth = [formatter stringFromDate:[NSDate date]];
    
    DHBBlog *currentBlog = [appDelegate.settings.blogs objectAtIndex:appDelegate.settings.selectedBlog];
    
    [self setLocalPath:[NSString stringWithFormat:@"%@%@items/media/%@/%@/", documentsPath, currentBlog.path, currentYear, currentMonth]];
    
    return self;
}

-(void) deleteLocalMedia
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    fileManager = [NSFileManager defaultManager];
    
    [fileManager removeItemAtPath:self.localPath error:nil];
}

-(void) saveWithMedia:(id) media
{
    DHBAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    
    NSString *currentYear = [formatter stringFromDate:[NSDate date]];
    
    [formatter setDateFormat:@"MM"];
    NSString *currentMonth = [formatter stringFromDate:[NSDate date]];
    
    NSString *mediaRelativePath = [NSString stringWithFormat:@"/media/%@/%@/%@", currentYear, currentMonth, self.fileName];
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    fileManager = [NSFileManager defaultManager];
        
    if(![fileManager fileExistsAtPath:self.localPath]) {
        [fileManager createDirectoryAtPath:self.localPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    if([self.mediaType isEqualToString:@"image"]) {
        NSData *data = UIImageJPEGRepresentation(media, 10.0);
        
        if([fileManager createFileAtPath:[NSString stringWithFormat:@"%@%@", self.localPath, self.fileName] contents:data attributes:nil]) {
            
            [appDelegate.dropBox.uploadClient uploadFile:self.fileName toPath:self.dropBoxPath withParentRev:self.rev fromPath:[NSString stringWithFormat:@"%@%@", self.localPath, self.fileName]];

            [self setCodeTag:[NSString stringWithFormat:@"<%%= image '%@', :alt => '%@', :link => :self %%>", mediaRelativePath, self.altText]];
        }
    } else if([self.mediaType isEqualToString:@"html5video"]) {
        NSURL *exportURL = [[NSURL alloc] initFileURLWithPath:[NSString stringWithFormat:@"%@%@", self.localPath, self.fileName]];
        
        AVAsset *avAsset = [AVURLAsset URLAssetWithURL:media options:nil];

        AVMutableVideoComposition *videoComposition = [self getVideoComposition:avAsset];
        
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
        [exportSession setVideoComposition:videoComposition];
        [exportSession setOutputFileType:AVFileTypeMPEG4];
        [exportSession setOutputURL:exportURL];
        
        [exportSession exportAsynchronouslyWithCompletionHandler:^(void){            
            [self performSelectorOnMainThread:@selector(exportSessionCompletionHandler) withObject:self waitUntilDone:NO];
        }];
        
        [self setCodeTag:[NSString stringWithFormat:@"<%%= html5video '%@', :alt => '%@', :link => :self %%>", mediaRelativePath, self.altText]];
    }
}

-(void) exportSessionCompletionHandler
{
    DHBAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

    [appDelegate.dropBox.uploadClient uploadFile:self.fileName toPath:self.dropBoxPath withParentRev:self.rev fromPath:[NSString stringWithFormat:@"%@%@", self.localPath, self.fileName]];
}

-(AVMutableVideoComposition *) getVideoComposition:(AVAsset *)asset
{
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    AVMutableComposition *composition = [AVMutableComposition composition];
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    CGSize videoSize = videoTrack.naturalSize;
    BOOL isPortrait_ = [self isVideoPortrait:asset];
    if(isPortrait_) {
        videoSize = CGSizeMake(videoSize.height, videoSize.width);
    }
    composition.naturalSize     = videoSize;
    videoComposition.renderSize = videoSize;
    // videoComposition.renderSize = videoTrack.naturalSize; //
    videoComposition.frameDuration = CMTimeMakeWithSeconds( 1 / videoTrack.nominalFrameRate, 600);
    
    AVMutableCompositionTrack *compositionVideoTrack;
    compositionVideoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:videoTrack atTime:kCMTimeZero error:nil];
    AVMutableVideoCompositionLayerInstruction *layerInst;
    layerInst = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    [layerInst setTransform:videoTrack.preferredTransform atTime:kCMTimeZero];
    AVMutableVideoCompositionInstruction *inst = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    inst.timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
    inst.layerInstructions = [NSArray arrayWithObject:layerInst];
    videoComposition.instructions = [NSArray arrayWithObject:inst];
    return videoComposition;
}


-(BOOL) isVideoPortrait:(AVAsset *)asset
{
    BOOL isPortrait = FALSE;
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if([tracks    count] > 0) {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        
        CGAffineTransform t = videoTrack.preferredTransform;
        // Portrait
        if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0)
        {
            isPortrait = YES;
        }
        // PortraitUpsideDown
        if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0)  {
            
            isPortrait = YES;
        }
        // LandscapeRight
        if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0)
        {
            isPortrait = FALSE;
        }
        // LandscapeLeft
        if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0)
        {
            isPortrait = FALSE;
        }
    }
    return isPortrait;
}

@end
