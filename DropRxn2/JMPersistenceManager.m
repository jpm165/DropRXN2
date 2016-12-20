//
//  JMPersistenceManager.m
//  DropRxn2
//
//  Created by James Mundie on 12/14/16.
//  Copyright © 2016 James Mundie. All rights reserved.
//

#import "JMPersistenceManager.h"
#import "JMGameManager.h"

@implementation JMPersistenceManager

+(instancetype)sharedInstance {
    
    static dispatch_once_t once;
    static id sharedInstance;
    
    dispatch_once(&once, ^{
        sharedInstance = [self new];
    });
    
    return sharedInstance;
    
}

-(instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

#pragma mark - Convenience methods

-(NSNumber *)getHighScoreForDifficultyLevel:(NSString *)level {
    NSDictionary *dict = [self getState];
    if (dict) {
        NSDictionary *targetDict = dict[level];
        return targetDict[@"score"];
    }
    return @0;
}

-(NSNumber *)getMostChainsForDifficultyLevel:(NSString *)level {
    NSDictionary *dict = [self getState];
    if (dict) {
        NSDictionary *targetDict = dict[level];
        return targetDict[@"chains"];
    }
    return @0;
}

#pragma mark - Path Management

+(NSString *)documentsDirectoryPath {
    NSURL *docURL = [self applicationDocumentsDirectory];
    NSString *path = docURL.path;
    return path;
}

+(NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

+(NSString *)getFilePathForFile:(NSString *)filename {
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", [self documentsDirectoryPath], filename];
    return filePath;
}

+(BOOL)fileExistsAtPath:(NSString *)path {
    return ([[NSFileManager defaultManager] fileExistsAtPath:path]);
}

+(NSString *)pathForStateFile {
    NSString *stateFile = @"state.plist";
    NSString *fullPath = [[self class] getFilePathForFile:stateFile];
    return fullPath;
}

#pragma mark - State management

-(NSDictionary *)getState {
    
    NSString *fullPath = [[self class] pathForStateFile];
    if ([[self class] fileExistsAtPath:fullPath]) {
        NSError *error;
        NSData *fileData = [NSData dataWithContentsOfFile:fullPath options:NSDataReadingUncached error:&error];
        if (!error) {
            if (fileData) {
                NSError *fileError;
                NSPropertyListFormat format;
                NSDictionary *stateDict = [NSPropertyListSerialization propertyListWithData:fileData options:NSPropertyListImmutable format:&format error:&fileError];
                return stateDict;
            } else {
                NSLog(@"No data found when opening %@.", fullPath);
            }
        } else {
            NSLog(@"Error opening %@: %@", fullPath, error.localizedDescription);
        }
    }
    return nil;
}

-(void)resetState {
    NSString *fullPath = [[self class] pathForStateFile];
    if ([[self class] fileExistsAtPath:fullPath]) {
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:fullPath error:&error];
        if (error) NSLog(@"Error removing %@: %@", fullPath, error.localizedDescription);
    }
}

-(void)saveState {
    NSDictionary *highscores = [JMGameManager sharedInstance].highScores;
    if (![NSPropertyListSerialization propertyList:highscores isValidForFormat:NSPropertyListXMLFormat_v1_0]) {
        NSLog(@"Can't save plist object.");
    } else {
        NSError *error;
        NSData *filedata = [NSPropertyListSerialization dataWithPropertyList:highscores format:NSPropertyListXMLFormat_v1_0 options:NSPropertyListWriteInvalidError error:&error];
        if (filedata) {
            [filedata writeToFile:[[self class] pathForStateFile] atomically:YES];
        }
    }
}

@end
