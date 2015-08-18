#import <UIKit/UIKit.h>
#import "MuTapResult.h"

@protocol MuPageView
-(NSInteger) number;
-(void) willRotate;
-(void) showLinks;
-(void) hideLinks;
-(void) showSearchResults: (int)count;
-(void) clearSearchResults;
-(void) resetZoomAnimated: (BOOL)animated;
-(void) setScale:(float)scale;
-(float) getScale;
- (void) displayImage: (UIImage*)image;
-(NSString *)    selectedText;
-(MuTapResult *) handleTap:(CGPoint)pt;
-(void) textSelectModeOn;
-(void) textSelectModeOff;
-(void) deselectAnnotation;
-(void) deleteSelectedAnnotation;
-(void) inkModeOn;
-(void) inkModeOff;
-(void) saveSelectionAsMarkup:(int)type;
-(void) saveInk;
-(void) update;

-(void) setMessageDelegate:(id) delegate;
-(void) processLongTap:(CGPoint)point;
-(void) resetCurrentWord;


@end
