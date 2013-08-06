//
//  DHBSettings.m
//  Write
//
//  Created by David Brunow on 4/21/13.
//  Copyright (c) 2013 David Brunow. All rights reserved.
//

#import "DHBSettings.h"
#import "DHBBlog.h"

@implementation DHBSettings

- (id)init
{
    [self moveSettingsToDocumentsDir];
    
    NSPropertyListFormat format;
    NSString *errorDesc = nil;
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:self.settingsPath];
    self.settings = (NSDictionary *)[NSPropertyListSerialization
                                     propertyListFromData:plistXML
                                     mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                     format:&format
                                     errorDescription:&errorDesc];
    if (!self.settings) {
        NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
    }

    self.blogs = [[NSMutableArray alloc] init];
    NSMutableArray *blogPaths = [self.settings valueForKey:@"Blog Paths"];

    for(NSString *blogPath in blogPaths) {
        DHBBlog *blog = [[DHBBlog alloc] initWithPath:blogPath];
        [_blogs addObject:blog];
    }
    
    self.selectedBlog = [[self.settings valueForKey:@"Selected Blog Index"] integerValue];
    NSLog(@"Selected Blog Index: %d", self.selectedBlog);
    
    [self setIsInitialLaunch:YES];
    
    return self;
}

-(void)setSelectedBlog:(int)selectedBlog
{
    _selectedBlog = selectedBlog;
        
    [self.settings setValue:[NSString stringWithFormat:@"%d", selectedBlog] forKey:@"Selected Blog Index"];
    [self writeSettings];
}

-(void)saveBlogs
{
    NSMutableArray *blogPaths = [[NSMutableArray alloc] init];
    
    for(DHBBlog *blog in _blogs) {
        [blogPaths addObject:blog.path];
    }
    
    [self.settings setValue:blogPaths forKey:@"Blog Paths"];

    [self writeSettings];
}

- (void)moveSettingsToDocumentsDir
{
    self.settingsPath = [self currentSettingsPath];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if(![fileManager fileExistsAtPath:self.settingsPath]) {
        //if there are no other settings files - so this is a clean installation
        NSString *path = [[NSBundle mainBundle] pathForResource:@"settings_v1" ofType:@"plist"];

        [[NSFileManager defaultManager]copyItemAtPath:path toPath:self.settingsPath error:nil];
    }
}

- (NSString *)currentSettingsPath
{
    /* get the path for the Documents directory */
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    /* append the path component for the FavoriteUsers.plist */
    NSString *settingsPath = [documentsPath stringByAppendingPathComponent:@"settings_v1.plist"];
    
    return settingsPath;
}

-(void)writeSettings
{
    if([self.settings writeToFile:self.settingsPath atomically: YES]){
    } else {
        //#TODO: Handle error
    }
}

@end
