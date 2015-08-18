#include "common.h"

@class MuWord;

@interface MuTextSelectView : UIView
{
    MuWord *theWord;
}
- (id) initWithWords:(NSArray *)_words pageSize:(CGSize)_pageSize;

- (void)  redrawfor:(MuWord*) word;
- (NSArray *) selectionRects;
- (NSString *) selectedText;
@end
