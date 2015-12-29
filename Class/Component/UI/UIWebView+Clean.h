

#import <Foundation/Foundation.h>

@interface UIWebView (clean)

// performs various cleanup activities recommended for UIWebView before dealloc.
// see comments in implementation for usage examples
- (void) cleanForDealloc;

@end
