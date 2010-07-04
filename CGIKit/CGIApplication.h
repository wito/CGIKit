/* Copyright 2009 His Exalted Highness the Lord-Emperor Wito (Williham Totland) */

#import "CGIObject.h"

@class CGIArray;
@class CGIDictionary;

@class CGIRequest;

extern id CGIApp;

/// @brief Starts a CGIApplication.
int CGIApplicationMain (int argc, const char **argv, const char **envp, CGIString *name);

@protocol CGIApplicationDelegate

- (CGIString *)applicationDidReceiveRequest:(CGIRequest *)r;

@end


/** @class CGIApplication
 *  @brief The main application class.
 *
 *  
 */
@interface CGIApplication : CGIObject {
  CGIArray *arguments;
  CGIDictionary *environment;
  CGIDictionary *applicationInfo;

  id <CGIApplicationDelegate> delegate;
}

+ (id)sharedApplication;

- (id)initWithArguments:(const char **)argv count:(int)argc environment:(const char**)envp;

- (id <CGIApplicationDelegate>)delegate;
- (void)setDelegate:(id <CGIApplicationDelegate>)anObject;

- (CGIArray *)arguments;
- (CGIDictionary *)environment;

- (CGIDictionary *)applicationInfo;
- (void)setApplicationInfo:(CGIDictionary *)infoPlist;

- (void)run;

@end

