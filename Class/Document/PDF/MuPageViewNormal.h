#import <UIKit/UIKit.h>

#undef ABS
#undef MIN
#undef MAX

#include "mupdf/fitz.h"

#import "MuHitView.h"
#import "MuPageView.h"
#import "MuDocRef.h"
#import "MuDialogCreator.h"
#import "MuTextSelectView.h"
#import "MuInkView.h"
#import "MuAnnotSelectView.h"
#import "MuUpdater.h"
#import "MuWord.h"

@interface MuPageViewNormal : UIScrollView <UIScrollViewDelegate,MuPageView>
{
    NSString   *wholeText;
    NSArray    *wordsArray;
    
    MuWord     *currentWord;
    
    UITapGestureRecognizer *singleTapOne;
    UITapGestureRecognizer *doubleTapOne;
}

@property(nonatomic,assign) id  messagerDelegate;

- (id) initWithFrame: (CGRect)frame dialogCreator:(id<MuDialogCreator>)dia updater:(id<MuUpdater>)upd document: (MuDocRef *)aDoc page: (NSInteger)aNumber;
- (void) displayImage: (UIImage*)image;
- (void) resizeImage;
- (void) loadPage;
- (void) loadTile;
@end
