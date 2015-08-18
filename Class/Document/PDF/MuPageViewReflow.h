#import <UIKit/UIKit.h>
#import "MuDocRef.h"
#import "MuPageView.h"

#import "FlyingUIWebView.h"

@interface MuPageViewReflow : FlyingUIWebView <UIWebViewDelegate,MuPageView>

-(id) initWithFrame:(CGRect)frame document:(MuDocRef *)aDoc page:(NSInteger)aNumber;

@end
