//
//	ReaderViewController.m
//	Reader v2.7.2
//
//	Created by Julius Oklamcak on 2011-07-01.
//	Copyright © 2011-2013 Julius Oklamcak. All rights reserved.
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights to
//	use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//	of the Software, and to permit persons to whom the Software is furnished to
//	do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//	OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//	CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#define PAGING_VIEWS 3

#define STATUS_HEIGHT 20.0f

#define TOOLBAR_HEIGHT 44.0f
#define PAGEBAR_HEIGHT 48.0f

#define PAGE_THUMB_LARGE 240
#define PAGE_THUMB_SMALL 144

#define TAP_AREA_SIZE 48.0f
#import "ReaderConstants.h"
#import "ReaderViewController.h"
#import "ReaderThumbCache.h"
#import "ReaderThumbQueue.h"
#import "FlyinglessonDAO.h"
#import "FlyingLessonData.h"
#import "SIAlertView.h"
#import "SoundPlayer.h"
#import "FlyingStatisticDAO.h"
#import "FlyingTouchDAO.h"
#import "UICKeyChainStore.h"
#import "shareDefine.h"
#import "iFlyingAppDelegate.h"
#import "FlyingTaskWordDAO.h"
#import "FlyingItemView.h"
#import "UIView+Autosizing.h"
#import "NSString+FlyingExtention.h"
#import "FlyingSysWithCenter.h"

#import "MuPageViewNormal.h"
#import "MuPageViewReflow.h"
#import "MuPageView.h"
#import "FlyingWebViewController.h"
#import "ACMagnifyingGlass.h"
#import "UIView+Toast.h"

#import "FlyingNowLessonDAO.h"

#import "AFHttpTool.h"

enum
{
    BIRDMODE_NORMAL,
    BIRDMODE_LINKVIEW,

    
	BIRDMODE_MAIN,
	BIRDMODE_SEARCH,
	BIRDMODE_MORE,
	BIRDMODE_ANNOTATION,
	BIRDMODE_HIGHLIGHT,
	BIRDMODE_UNDERLINE,
	BIRDMODE_STRIKE,
	BIRDMODE_INK,
	BIRDMODE_DELETE
};

@interface ReaderViewController ()<UIViewControllerRestoration>
{
	ReaderDocument *document;

	UIScrollView *theScrollView;

	ReaderMainToolbar *mainToolbar;

	ReaderMainPagebar *mainPagebar;

	NSMutableDictionary *contentViews;

	UIPrintInteractionController *printInteraction;

	NSInteger currentPage;

	CGSize lastAppearSize;

	//NSDate *lastHideTime;

	BOOL isVisible;
    
    NSLinguisticTagger       * _flyingNPL;
    SoundPlayer             *_speechPlayer;
    NSString                *_currentPassport;
    dispatch_queue_t         _background_queue;
    
    FlyingTouchDAO          *_touchDAO;
    
    FlyingItemView          *_aWordView;
    
    
    float       _scale; // scale applied to views (only used in reflow mode)
    BOOL        _reflowMode;
    
    NSString *  _searWord;
    
    int         _BIRDMode;

    ACMagnifyingGlass *_magiGlass;
    
    //背景音乐管理
    AVAudioPlayer               *_backgroundAudioPlayer;
    BOOL                       _isReachEnd;
}

@end

@implementation ReaderViewController

+ (UIViewController *) viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder
{
    UIViewController *retViewController = [[ReaderViewController alloc] init];
    return retViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.restorationIdentifier = @"ReaderViewController";
    self.restorationClass      = [self class];
    
	self.view.backgroundColor = [UIColor grayColor]; // Neutral gray
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self loadReaderDocument];
}

-(void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
    
    [coder encodeObject:self.lessonID forKey:@"lessonID"];
    [coder encodeBool:self.playOnline forKey:@"playOnline"];
}

-(void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
    
    self.lessonID = [coder decodeObjectForKey:@"lessonID"];
    self.playOnline = [coder decodeBoolForKey:@"playOnline"];
    
    [self loadReaderDocument];
}


-(void) doLoadView
{
	CGRect scrollViewRect = self.view.bounds; UIView *fakeStatusBar = nil;
    
	if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) // iOS 7+
	{
		if ([self prefersStatusBarHidden] == NO) // Visible status bar
		{
			CGRect statusBarRect = self.view.bounds; // Status bar frame
			statusBarRect.size.height = STATUS_HEIGHT; // Default status height
			fakeStatusBar = [[UIView alloc] initWithFrame:statusBarRect]; // UIView
			fakeStatusBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
			fakeStatusBar.backgroundColor = [UIColor blackColor];
			fakeStatusBar.contentMode = UIViewContentModeRedraw;
			fakeStatusBar.userInteractionEnabled = NO;
            
			scrollViewRect.origin.y += STATUS_HEIGHT; scrollViewRect.size.height -= STATUS_HEIGHT;
		}
	}
    
	theScrollView = [[UIScrollView alloc] initWithFrame:scrollViewRect]; // UIScrollView
	theScrollView.autoresizesSubviews = NO;
    theScrollView.contentMode = UIViewContentModeRedraw;
	theScrollView.showsHorizontalScrollIndicator = NO;
    theScrollView.showsVerticalScrollIndicator = NO;
	theScrollView.scrollsToTop = NO;
    theScrollView.delaysContentTouches = NO;
    theScrollView.pagingEnabled = YES;
	theScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	theScrollView.backgroundColor = [UIColor clearColor];
    theScrollView.delegate = self;
	[self.view addSubview:theScrollView];
    
	CGRect toolbarRect = scrollViewRect; // Toolbar frame
	toolbarRect.size.height = TOOLBAR_HEIGHT; // Default toolbar height
	mainToolbar = [[ReaderMainToolbar alloc] initWithFrame:toolbarRect document:document]; // ReaderMainToolbar
	mainToolbar.delegate = self; // ReaderMainToolbarDelegate
	[self.view addSubview:mainToolbar];
    
	CGRect pagebarRect = self.view.bounds;; // Pagebar frame
	pagebarRect.origin.y = (pagebarRect.size.height - PAGEBAR_HEIGHT);
	pagebarRect.size.height = PAGEBAR_HEIGHT; // Default pagebar height
	mainPagebar = [[ReaderMainPagebar alloc] initWithFrame:pagebarRect document:document]; // ReaderMainPagebar
	mainPagebar.delegate = self; // ReaderMainPagebarDelegate
	[self.view addSubview:mainPagebar];
    
	if (fakeStatusBar != nil) [self.view addSubview:fakeStatusBar]; // Add status bar background view
    
	UITapGestureRecognizer *singleTapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleTapOne.numberOfTouchesRequired = 1; singleTapOne.numberOfTapsRequired = 1; singleTapOne.delegate = self;
	[self.view addGestureRecognizer:singleTapOne];
    
	UITapGestureRecognizer *doubleTapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
	doubleTapOne.numberOfTouchesRequired = 1; doubleTapOne.numberOfTapsRequired = 2; doubleTapOne.delegate = self;
	[self.view addGestureRecognizer:doubleTapOne];
    
    [singleTapOne requireGestureRecognizerToFail:doubleTapOne];
    
    UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongTap:)];
	[self.view addGestureRecognizer:longTap];
            
	contentViews = [NSMutableDictionary new];
    //lastHideTime = [NSDate date];
    
    //基本辅助信息和工具准备
    iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
    _background_queue = [appDelegate getAIQueue];
    
    _currentPassport = [UICKeyChainStore keyChainStore][KOPENUDIDKEY];
    _speechPlayer = [[SoundPlayer alloc] init];
    [self autoRemoveWordView];
    
    //统计相关
    _touchDAO     = [[FlyingTouchDAO alloc] init];
    
    [self prepairNLP];
    
    [self playBackgroundIfPossible];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
    if(document){
    
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        
        [notificationCenter addObserver:self selector:@selector(applicationWill:) name:UIApplicationWillTerminateNotification object:nil];
        
        [notificationCenter addObserver:self selector:@selector(applicationWill:) name:UIApplicationWillResignActiveNotification object:nil];
        
        if (CGSizeEqualToSize(lastAppearSize, CGSizeZero) == false)
        {
            if (CGSizeEqualToSize(lastAppearSize, self.view.bounds.size) == false)
            {
                [self updateScrollViewContentViews]; // Update content views
            }
            
            lastAppearSize = CGSizeZero; // Reset view size tracking
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
    
    if(document){
    
        if (CGSizeEqualToSize(theScrollView.contentSize, CGSizeZero)) // First time
        {
            [self performSelector:@selector(showDocument:) withObject:nil afterDelay:0.02];
        }
    }
    
#if (READER_DISABLE_IDLE == TRUE) // Option
    
	[UIApplication sharedApplication].idleTimerDisabled = YES;
    
#endif // end of READER_DISABLE_IDLE Option
    
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    
	lastAppearSize = self.view.bounds.size; // Track view size
    
#if (READER_DISABLE_IDLE == TRUE) // Option
    
	[UIApplication sharedApplication].idleTimerDisabled = NO;
    
#endif // end of READER_DISABLE_IDLE Option
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidUnload
{
    
	mainToolbar = nil; mainPagebar = nil;
    
	theScrollView = nil; contentViews = nil;
    //lastHideTime = nil;
    
	lastAppearSize = CGSizeZero; currentPage = 0;
    
	[super viewDidUnload];
}

- (BOOL)prefersStatusBarHidden
{
	return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
	return UIStatusBarStyleLightContent;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	if (isVisible == NO) return; // iOS present modal bodge
    
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
	{
		if (printInteraction != nil) [printInteraction dismissAnimated:NO];
	}
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
	if (isVisible == NO) return; // iOS present modal bodge
    
	[self updateScrollViewContentViews]; // Update content views
    
	lastAppearSize = CGSizeZero; // Reset view size tracking
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

#pragma mark UIScrollViewDelegate methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	__block NSInteger page = 0;
    
	CGFloat contentOffsetX = scrollView.contentOffset.x;
    
	[contentViews enumerateKeysAndObjectsUsingBlock: // Enumerate content views
     ^(id key, id object, BOOL *stop)
     {
         UIView<MuPageView> *contentView = object;
         
         if (contentView.frame.origin.x == contentOffsetX)
         {
             page = contentView.tag; *stop = YES;
         }
     }
     ];
    
	if (page != 0) [self showDocumentPage:page]; // Show the page
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
	[self showDocumentPage:theScrollView.tag]; // Show page
    
	theScrollView.tag = 0; // Clear page number tag
}

#pragma mark Support methods

- (void)updateScrollViewContentSize
{
	NSInteger count = [document.pageCount integerValue];

	if (count > PAGING_VIEWS) count = PAGING_VIEWS; // Limit

	CGFloat contentHeight = theScrollView.bounds.size.height;

	CGFloat contentWidth = (theScrollView.bounds.size.width * count);

	theScrollView.contentSize = CGSizeMake(contentWidth, contentHeight);
}

- (void)updateScrollViewContentViews
{
	[self updateScrollViewContentSize]; // Update the content size

	NSMutableIndexSet *pageSet = [NSMutableIndexSet indexSet]; // Page set

	[contentViews enumerateKeysAndObjectsUsingBlock: // Enumerate content views
		^(id key, id object, BOOL *stop)
		{
			UIView<MuPageView> *contentView = object;
            [pageSet addIndex:contentView.tag];
		}
	];

	__block CGRect viewRect = CGRectZero; viewRect.size = theScrollView.bounds.size;

	__block CGPoint contentOffset = CGPointZero; NSInteger page = [document.pageNumber integerValue];

	[pageSet enumerateIndexesUsingBlock: // Enumerate page number set
		^(NSUInteger number, BOOL *stop)
		{
			NSNumber *key = [NSNumber numberWithInteger:number]; // # key

			UIView<MuPageView> *contentView = [contentViews objectForKey:key];

			contentView.frame = viewRect;
            if (page == number) contentOffset = viewRect.origin;

			viewRect.origin.x += viewRect.size.width; // Next view frame position
		}
	];

	if (CGPointEqualToPoint(theScrollView.contentOffset, contentOffset) == false)
	{
		theScrollView.contentOffset = contentOffset; // Update content offset
	}
}

- (void)updateToolbarBookmarkIcon
{
	//NSInteger page = [document.pageNumber integerValue];

	//BOOL bookmarked = [document.bookmarks containsIndex:page];

	//[mainToolbar setBookmarkState:bookmarked]; // Update
}

- (void)showDocumentPage:(NSInteger)page
{
    NSNumber *key = [NSNumber numberWithInteger:page]; // # key
    UIView<MuPageView> *contentView = [contentViews objectForKey:key];
    [contentView clearSearchResults];

	if (page == currentPage && contentView) // Only if different
    {
        if (_searWord)
        {
            NSNumber *key = [NSNumber numberWithInteger:page]; // # key
            UIView<MuPageView> *contentView = [contentViews objectForKey:key];
            
            dispatch_async(queue, ^{
                
                MuDocRef *docRef = document.docRef;

                int n = search_page(docRef->doc, [@(page-1) intValue], [_searWord UTF8String], NULL);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [contentView showSearchResults:n];
                    _searWord=nil;
                });
            });
        }
    }
    else
	{
		NSInteger minValue; NSInteger maxValue;
		NSInteger maxPage = [document.pageCount integerValue];
		NSInteger minPage = 1;

		if ((page < minPage) || (page > maxPage)) return;

		if (maxPage <= PAGING_VIEWS) // Few pages
		{
			minValue = minPage;
			maxValue = maxPage;
		}
		else // Handle more pages
		{
			minValue = (page - 1);
			maxValue = (page + 1);

			if (minValue < minPage)
				{minValue++; maxValue++;}
			else
				if (maxValue > maxPage)
					{minValue--; maxValue--;}
		}

		NSMutableIndexSet *newPageSet = [NSMutableIndexSet new];

		NSMutableDictionary *unusedViews = [contentViews mutableCopy];

		CGRect viewRect = CGRectZero; viewRect.size = theScrollView.bounds.size;
        
        MuDocRef *docRef = document.docRef;

		for (NSInteger number = minValue; number <= maxValue; number++)
		{
			NSNumber *key = [NSNumber numberWithInteger:number]; // # key
            UIView<MuPageView> *contentView = [contentViews objectForKey:key];
            
			if (contentView == nil) // Create a brand new document content view
			{
                contentView
                = _reflowMode
                ? [[MuPageViewReflow alloc] initWithFrame:viewRect document:docRef page:(number-1)]
                : [[MuPageViewNormal alloc] initWithFrame:viewRect dialogCreator:self updater:self document:docRef page:(number-1)];
                [contentView setTag:number];
                [contentView setScale:_scale];
                
                [theScrollView addSubview:contentView];
                [contentViews setObject:contentView forKey:key];
                
                if (number ==page && _searWord!=nil)
                {
                    dispatch_async(queue, ^{
                    
                        int n = search_page(docRef->doc, [@(number-1) intValue], [_searWord UTF8String], NULL);
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [contentView showSearchResults:n];
                            _searWord=NULL;
                        });
                    });
                }
                
                [contentView setMessageDelegate:self];
    
                [newPageSet addIndex:number];
            }
			else // Reposition the existing content view
			{
				contentView.frame = viewRect;
                [contentView resetZoomAnimated: NO];

				[unusedViews removeObjectForKey:key];
			}

			viewRect.origin.x += viewRect.size.width;
		}

		[unusedViews enumerateKeysAndObjectsUsingBlock: // Remove unused views
			^(id key, id object, BOOL *stop)
			{
				[contentViews removeObjectForKey:key];

				UIView<MuPageView> *contentView = object;

				[contentView removeFromSuperview];
			}
		];

		unusedViews = nil; // Release unused views

		CGFloat viewWidthX1 = viewRect.size.width;
		CGFloat viewWidthX2 = (viewWidthX1 * 2.0f);

		CGPoint contentOffset = CGPointZero;

		if (maxPage >= PAGING_VIEWS)
		{
			if (page == maxPage)
				contentOffset.x = viewWidthX2;
			else
				if (page != minPage)
					contentOffset.x = viewWidthX1;
		}
		else
			if (page == (PAGING_VIEWS - 1))
				contentOffset.x = viewWidthX1;

		if (CGPointEqualToPoint(theScrollView.contentOffset, contentOffset) == false)
		{
			theScrollView.contentOffset = contentOffset; // Update content offset
		}

		if ([document.pageNumber integerValue] != page) // Only if different
		{
			document.pageNumber = [NSNumber numberWithInteger:page]; // Update page number
		}

		if ([newPageSet containsIndex:page] == YES) // Preview visible page first
		{
            [self showPageThumb:page];
			[newPageSet removeIndex:page]; // Remove visible page from set
		}

		[newPageSet enumerateIndexesWithOptions:NSEnumerationReverse usingBlock: // Show previews
			^(NSUInteger number, BOOL *stop)
			{
				[self showPageThumb:number];
			}
		];

		newPageSet = nil; // Release new page set

		[mainPagebar updatePagebar]; // Update the pagebar display

		[self updateToolbarBookmarkIcon]; // Update bookmark

		currentPage = page; // Track current page number
	}
}

- (void)showPageThumb:(NSInteger)page
{
#if (READER_ENABLE_PREVIEW == TRUE) // Option
    
#endif // end of READER_ENABLE_PREVIEW Option
}


- (void)showDocument:(NSObject*)object
{
	[self updateScrollViewContentSize]; // Set content size

	[self showDocumentPage:document.pageNumber.integerValue];

	document.lastOpen = [NSDate date]; // Update last opened date

	isVisible = YES; // iOS present modal bodge
}

#pragma mark UIViewController methods

-(void) loadReaderDocument
{
	document = [ReaderDocument withLessonID:self.lessonID];
    
	if (document != nil)
	{
        if ([document needPassword])
        {
            if (document.password==NULL)
            {
                UIAlertView *shakingAlert = [[UIAlertView alloc] initWithTitle:@"请输入文档密码"
                                                                       message:nil
                                                                      delegate:self
                                                             cancelButtonTitle:@"取消"
                                                             otherButtonTitles:@"确定", nil];
                [shakingAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
                [shakingAlert show];
            }
            else
            {
                [self reloadReaderDocument:document.password];
            }
        }
        else
        {
            [document updateProperties];
            
            [ReaderThumbCache touchThumbCacheWithGUID:document.guid]; // Touch the document thumb cache directory
            
            [self doLoadView];
        }
	}
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)reloadReaderDocument:(NSString *) phrase
{
    if (document)
    {
        if ([document loadWithPassword:phrase])
        {
            FlyingLessonData * lesson = [[[FlyingLessonDAO alloc] init] selectWithLessonID:self.lessonID];
                       
            [document updateProperties];
            [document setDisplayName:lesson.BETITLE];
            [document setPassword:phrase];
            
            [ReaderThumbCache touchThumbCacheWithGUID:document.guid]; // Touch the document thumb cache directory
            
            [self doLoadView];
            
            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
            
            [notificationCenter addObserver:self selector:@selector(applicationWill:) name:UIApplicationWillTerminateNotification object:nil];
            [notificationCenter addObserver:self selector:@selector(applicationWill:) name:UIApplicationWillResignActiveNotification object:nil];
            
            [self performSelector:@selector(showDocument:) withObject:nil afterDelay:0.02];
            
            if(!lesson.BEOFFICIAL){
                
                
                dispatch_async(dispatch_get_main_queue(), ^
                               {
                                   NSString* lessontitle =lesson.BETITLE;
                                   NSString * localCoverPath = [lessontitle localCoverURL];
                                   
                                   if (![[NSFileManager defaultManager] fileExistsAtPath:localCoverPath]){
                                       
                                       UIImage * coverImage=
                                       [iFlyingAppDelegate thumbnailImageForPDF:[NSURL fileURLWithPath:lesson.localURLOfContent]
                                                                                  passWord:phrase];
                                       
                                       if (coverImage) {
                                           
                                           [UIImagePNGRepresentation(coverImage) writeToFile:localCoverPath atomically:YES];
                                       }
                                   }
                               });
            }

        }
        else
        {
            UIAlertView *shakingAlert = [[UIAlertView alloc] initWithTitle:@"密码错误，请重新输入！"
                                                                   message:nil
                                                                  delegate:self
                                                         cancelButtonTitle:@"取消"
                                                         otherButtonTitles:@"确定", nil];
            [shakingAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
            [shakingAlert show];
        }
    }
    else
    {
        [self.view makeToast:@"无法打开，请重试或者重新下载!" duration:3 position:CSToastPositionCenter];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"确定"]){
        UITextField *tf=[alertView textFieldAtIndex:0];//获得输入框
        NSString * resultStr=tf.text;//获得值
        
        if (resultStr) {
            
            [self reloadReaderDocument:resultStr];
        }
    }
    else{
    
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)recognizer shouldReceiveTouch:(UITouch *)touch
{
	if ([touch.view isKindOfClass:[UIScrollView class]]) return YES;

	return NO;
}

#pragma mark UIGestureRecognizer action methods

- (void)decrementPageNumber
{
	if (theScrollView.tag == 0) // Scroll view did end
	{
		NSInteger page = [document.pageNumber integerValue];
		NSInteger maxPage = [document.pageCount integerValue];
		NSInteger minPage = 1; // Minimum

		if ((maxPage > minPage) && (page != minPage))
		{
			CGPoint contentOffset = theScrollView.contentOffset;

			contentOffset.x -= theScrollView.bounds.size.width; // -= 1

			[theScrollView setContentOffset:contentOffset animated:YES];

			theScrollView.tag = (page - 1); // Decrement page number
		}
	}
}

- (void)incrementPageNumber
{
	if (theScrollView.tag == 0) // Scroll view did end
	{
		NSInteger page = [document.pageNumber integerValue];
		NSInteger maxPage = [document.pageCount integerValue];
		NSInteger minPage = 1; // Minimum

		if ((maxPage > minPage) && (page != maxPage))
		{
			CGPoint contentOffset = theScrollView.contentOffset;

			contentOffset.x += theScrollView.bounds.size.width; // += 1

			[theScrollView setContentOffset:contentOffset animated:YES];

			theScrollView.tag = (page + 1); // Increment page number
		}
	}
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
	{
        [self autoRemoveWordView];
        
		CGRect viewRect = recognizer.view.bounds; // View bounds
        
		CGPoint point = [recognizer locationInView:recognizer.view];
        
		CGRect areaRect = CGRectInset(viewRect, TAP_AREA_SIZE, 0.0f); // Area
        
		if (CGRectContainsPoint(areaRect, point)) // Single tap is inside the area
		{
			UIView<MuPageView> * targetView = [contentViews objectForKey:document.pageNumber];
            
            MuTapResult * tapResult =[targetView handleTap:point];
			if (tapResult != nil) // Handle the returned target object
			{
            }
			else // Nothing active tapped in the target content view
			{
                if ((mainToolbar.hidden == YES) || (mainPagebar.hidden == YES))
                {
                    [mainToolbar showToolbar]; [mainPagebar showPagebar]; // Show
                }
                else
                {
                    [mainToolbar hideToolbar]; [mainPagebar hidePagebar]; // hide
                }
			}
			return;
		}

		CGRect nextPageRect = viewRect;
		nextPageRect.size.width = TAP_AREA_SIZE;
		nextPageRect.origin.x = (viewRect.size.width - TAP_AREA_SIZE);

		if (CGRectContainsPoint(nextPageRect, point)) // page++ area
		{
			[self incrementPageNumber]; return;
		}

		CGRect prevPageRect = viewRect;
		prevPageRect.size.width = TAP_AREA_SIZE;

		if (CGRectContainsPoint(prevPageRect, point)) // page-- area
		{
			[self decrementPageNumber]; return;
		}
	}
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer
{
    if ((mainToolbar.hidden == NO) || (mainPagebar.hidden == NO))
    {
        [mainToolbar hideToolbar]; [mainPagebar hidePagebar]; // hide
    }
    
    [self autoRemoveWordView];
    _reflowMode=!_reflowMode;
    
    NSMutableDictionary *unusedViews = [contentViews mutableCopy];
    [unusedViews enumerateKeysAndObjectsUsingBlock: // Remove unused views
     ^(id key, id object, BOOL *stop)
     {
         [contentViews removeObjectForKey:key];
         
         UIView<MuPageView> *contentView = object;
         
         [contentView removeFromSuperview];
     }
     ];
    unusedViews = nil; // Release unused views
    
    [self showDocument:nil];
}

- (void)handleLongTap:(UILongPressGestureRecognizer *)recognizer
{
    if (_reflowMode) {
        return;
    }
    
    UIView<MuPageView> * targetView = [contentViews objectForKey:document.pageNumber];
    CGPoint point = [recognizer locationInView:self.view];
    
    [self addOrUpdateMagGlassAtPoint:point];
    
    [targetView processLongTap:point]; // Target
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            [self autoRemoveWordView];
            [targetView resetCurrentWord];

            [targetView textSelectModeOn];

            break;
        }

        case UIGestureRecognizerStateEnded:
        {
            
            NSString* selectString = [targetView selectedText]; // Target
            
            [self removeMagnifyingGlass];
            [targetView textSelectModeOff];
            
            if (selectString != nil) // Handle the returned target object
            {
                [self willShowWordView:selectString]; // Show the page
            }

            break;
        }
            
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            [targetView textSelectModeOff];
            [self removeMagnifyingGlass];
        }

        default:
        {
            break;
        }
    }
}

- (void)addOrUpdateMagGlassAtPoint:(CGPoint)point
{    
    if (!_magiGlass) {
        
        _magiGlass = [[ACMagnifyingGlass alloc] init];
        _magiGlass.viewToMagnify = self.view;
	}
    else{
        
        [_magiGlass removeFromSuperview];
        _magiGlass = [[ACMagnifyingGlass alloc] init];
        
        _magiGlass.viewToMagnify = self.view;
    }
    
	_magiGlass.touchPoint = point;
    
	[self.view  addSubview:_magiGlass];
	[_magiGlass setNeedsDisplay];
}

- (void)removeMagnifyingGlass
{
    if (_magiGlass) {
        
        [_magiGlass removeFromSuperview];
    }
}

//////////////////////////////////////////////////////////////
#pragma mark AI Word view
//////////////////////////////////////////////////////////////
- (void) willShowWordView:(NSString*) word
{
    if (word) {
        
        NSArray *times = [word componentsSeparatedByString:@" "];
        
        if (times.count>2)
        {
            [SoundPlayer soundSentence:word];
        }
        else {
            
            NSString * newWord = [self NLPTheString:word];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //更新课程相关记录
                NSString * currentLessonID = self.lessonID;
                if(!currentLessonID){
                    
                    currentLessonID =@"BirdEnglishCommonID";
                }
                
                [_touchDAO countPlusWithUserID:_currentPassport LessonID:currentLessonID];
                
                //纪录点击单词
                [self addToucLammaRecord:newWord];
            });
            
            [self showWordView:newWord];
        }
    }
}

- (void) showWordView:(NSString*) word
{
    if(word){
        
        [_speechPlayer speechWord:word LessonID:self.lessonID];
        
        if(![_aWordView.word isEqualToString:word]){
            
            CGRect frame=CGRectMake(0, 0, 200, 200);
            if (INTERFACE_IS_PAD ) {
                
                frame=CGRectMake(0, 0, 400, 400);
            }
            
            _aWordView =[[FlyingItemView alloc] initWithFrame:frame];
            [_aWordView setFullScreenModle:YES];
            [_aWordView setLessonID:self.lessonID];
            [_aWordView setWord:word];
            [_aWordView  drawWithLemma:[word lowercaseString] AppTag:nil];
            
            //随机散开磁贴的显示位置
            srand((unsigned int)_aWordView.lemma.hash);
            
            CGFloat x = (self.view.frame.size.width-_aWordView.frame.size.width)*rand()/(RAND_MAX+1.0);
            CGFloat y=  (self.view.frame.size.height-_aWordView.frame.size.height)*rand()/(RAND_MAX+1.0);
            
            _aWordView.frame =CGRectMake(x, y, _aWordView.frame.size.width, _aWordView.frame.size.height) ;
            
            [_aWordView adjustForAutosizing];
            [self.view addSubview:_aWordView];
            
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                
                _aWordView.alpha=1;
                
            } completion:^(BOOL finished) {}];
        }
        else{
            
            [_aWordView bringSubviewToFront:_aWordView];
        }
    }
    else{
        
        [_aWordView dismissViewAnimated:YES];
    }
}

- (void) autoRemoveWordView
{
    if(_aWordView){
        
        [_aWordView dismissViewAnimated:YES];
        _aWordView =nil;
    }
}

//把点击单词纪录下来
-(void) addToucLammaRecord:(NSString *) touchWord
{
    
    dispatch_async(_background_queue, ^{
        
        FlyingTaskWordDAO * taskWordDAO   = [[FlyingTaskWordDAO alloc] init];
        [taskWordDAO setUserModle:NO];
        
        [taskWordDAO insertWithUesrID:_currentPassport
                                 Word:[touchWord lowercaseString]
                           Sentence:nil
                             LessonID:self.lessonID];
    });
}

-(void) prepairNLP
{
    
    if (_flyingNPL==nil) {
        
        //忽略空格、符号和连接词
        NSLinguisticTaggerOptions options = NSLinguisticTaggerOmitWhitespace |NSLinguisticTaggerOmitPunctuation |
        NSLinguisticTaggerOmitOther | NSLinguisticTaggerJoinNames;
        
        //只需要词性和名称
        NSArray * tagSchemes = [NSArray arrayWithObjects:NSLinguisticTagSchemeNameTypeOrLexicalClass,NSLinguisticTagSchemeLemma,nil];
        
        _flyingNPL = [[NSLinguisticTagger alloc] initWithTagSchemes:tagSchemes options:options];
    }
}

-(NSString*) NLPTheString:(NSString *) string
{
    
    //如果没有学习字幕，返回
    if (string==nil) {
        return nil;
    }
    
    // This range contains the entire string, since we want to parse it completely
    NSRange stringRange = NSMakeRange(0, string.length);
    
    if (stringRange.length==0) {
        return nil;
    }
    
    //忽略空格、符号和连接词
    NSLinguisticTaggerOptions options = NSLinguisticTaggerOmitWhitespace |NSLinguisticTaggerOmitPunctuation |
    NSLinguisticTaggerOmitOther | NSLinguisticTaggerJoinNames;
    
    // Dictionary with a language map
    NSArray *language = [NSArray arrayWithObjects:@"en",nil];
    NSDictionary* languageMap = [NSDictionary dictionaryWithObject:language forKey:@"Latn"];
    NSOrthography * orthograsphy = [NSOrthography orthographyWithDominantScript:@"Latn" languageMap:languageMap];
    
    __block NSString * result;
    
    if (_flyingNPL==nil) {
        
        //忽略空格、符号和连接词
        NSLinguisticTaggerOptions options = NSLinguisticTaggerOmitWhitespace |NSLinguisticTaggerOmitPunctuation |
        NSLinguisticTaggerOmitOther | NSLinguisticTaggerJoinNames;
        
        //只需要词性和名称
        NSArray * tagSchemes = [NSArray arrayWithObjects:NSLinguisticTagSchemeNameTypeOrLexicalClass,NSLinguisticTagSchemeLemma,nil];
        
        _flyingNPL = [[NSLinguisticTagger alloc] initWithTagSchemes:tagSchemes options:options];
    }
    
    [_flyingNPL setString:string];
    [_flyingNPL setOrthography:orthograsphy range:stringRange];
    [_flyingNPL enumerateTagsInRange:stringRange
                              scheme:NSLinguisticTagSchemeLemma
                             options:options
                          usingBlock:^(NSString *tag, NSRange tokenRange, NSRange sentenceRange, BOOL *stop) {
                              
                              if (tag) {
                                  
                                  result = tag;
                              }
                              else{
                                  
                                  result = [string substringWithRange:tokenRange];
                              }
                          }];
    
    return result;
}

#pragma mark ReaderMainToolbarDelegate methods

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar doneButton:(UIButton *)button
{
	[document saveReaderDocument]; // Save any ReaderDocument object changes

	[[ReaderThumbQueue sharedInstance] cancelOperationsWithGUID:document.guid];

	[[ReaderThumbCache sharedInstance] removeAllObjects]; // Empty the thumb cache

	if (printInteraction != nil) [printInteraction dismissAnimated:NO]; // Dismiss

    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (self.playOnline) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[[FlyingNowLessonDAO alloc] init] deleteWithUserID:_currentPassport LessonID:self.lessonID];
        });
    }
}

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar printButton:(UIButton *)button
{

	Class printInteractionController = NSClassFromString(@"UIPrintInteractionController");

	if ((printInteractionController != nil) && [printInteractionController isPrintingAvailable])
	{
		NSURL *fileURL = document.fileURL; // Document file URL

		printInteraction = [printInteractionController sharedPrintController];

		if ([printInteractionController canPrintURL:fileURL] == YES) // Check first
		{
			UIPrintInfo *printInfo = [NSClassFromString(@"UIPrintInfo") printInfo];

			printInfo.duplex = UIPrintInfoDuplexLongEdge;
			printInfo.outputType = UIPrintInfoOutputGeneral;
			printInfo.jobName = document.fileName;

			printInteraction.printInfo = printInfo;
			printInteraction.printingItem = fileURL;
			printInteraction.showsPageRange = YES;

			if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
			{
				[printInteraction presentFromRect:button.bounds inView:button animated:YES completionHandler:
					^(UIPrintInteractionController *pic, BOOL completed, NSError *error)
					{
						#ifdef DEBUG
							if ((completed == NO) && (error != nil)) NSLog(@"%s %@", __FUNCTION__, error);
						#endif
					}
				];
			}
			else // Presume UIUserInterfaceIdiomPhone
			{
				[printInteraction presentAnimated:YES completionHandler:
					^(UIPrintInteractionController *pic, BOOL completed, NSError *error)
					{
						#ifdef DEBUG
							if ((completed == NO) && (error != nil)) NSLog(@"%s %@", __FUNCTION__, error);
						#endif
					}
				];
			}
		}
	}
}

/*

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar markButton:(UIButton *)button
{
	if (printInteraction != nil) [printInteraction dismissAnimated:YES];
    
	NSInteger page = [document.pageNumber integerValue];
    
	if ([document.bookmarks containsIndex:page]) // Remove bookmark
	{
		[mainToolbar setBookmarkState:NO]; [document.bookmarks removeIndex:page];
	}
	else // Add the bookmarked page index to the bookmarks set
	{
		[mainToolbar setBookmarkState:YES]; [document.bookmarks addIndex:page];
	}
}
 */

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar playButton:(UIButton *)button
{
    if (printInteraction != nil) [printInteraction dismissAnimated:YES];
    
    [self toggleButton];
}

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar searchButton:(UIButton *)button
{
    if (printInteraction != nil) [printInteraction dismissAnimated:NO]; // Dismiss
    
	ThumbsViewController *thumbsViewController = [[ThumbsViewController alloc] initWithReaderDocument:document];
    
	thumbsViewController.delegate = self; thumbsViewController.title = self.title;
    
	thumbsViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	thumbsViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    
	[self presentViewController:thumbsViewController animated:NO completion:NULL];
}

#pragma mark playground methods

- (void) playBackgroundIfPossible
{
    _isReachEnd=NO;
    
    if (_backgroundAudioPlayer) {
        
        [_backgroundAudioPlayer stop];
    }
    
    //获取本地数据或者把网络数据存到本地
    NSString  *fileName =kResource_Background_filenmae;
    
    //课程内容所在文件夹，本地课程文件夹是documents
    NSString * localPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    if ([(FlyingLessonData*)[[FlyingLessonDAO alloc] selectWithLessonID:self.lessonID] BEOFFICIAL]) {
        
        localPath = [iFlyingAppDelegate getLessonDir:self.lessonID];
    }
    
    NSString *filePath = [localPath stringByAppendingPathComponent:fileName];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if([fm fileExistsAtPath:filePath])
    {
        if (!_backgroundAudioPlayer)
        {
            // 创建播放器
            NSURL *fileURL = [NSURL fileURLWithPath:filePath];
            _backgroundAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
            _backgroundAudioPlayer.delegate=self;
            [_backgroundAudioPlayer prepareToPlay];
            _backgroundAudioPlayer.numberOfLoops = -1; //设置音乐播放次数  -1为一直循环
        }

        [_backgroundAudioPlayer play]; //播放
        
        [mainToolbar showPlayButton];
        [mainToolbar setPlayState:YES];

    }
    else
    {
        [mainToolbar hidePlayButton];
        
        [AFHttpTool lessonResourceType:kResource_Background
                              lessonID:self.lessonID
                            contentURL:nil
                                 isURL:YES
                               success:^(id response) {
                                   //
                                   if (response) {
                                       
                                       NSString * tempStr =[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
                                       NSData * audioData = [NSData dataWithContentsOfURL:[NSURL URLWithString:tempStr]];
                                       //将数据保存到本地指定位置
                                       [audioData writeToFile:filePath atomically:YES];
                                       
                                       [mainToolbar showPlayButton];
                                       [mainToolbar setPlayState:YES];
                                   }

                                   
                               } failure:^(NSError *err) {
                                   //
                                   NSLog(@"lessonResourceType:%@", err.description);
                               }];
    }
}


- (void)toggleButton
{
    if (_backgroundAudioPlayer) {
        
        if(_backgroundAudioPlayer.playing)
        {
            [_backgroundAudioPlayer pause];
            [mainToolbar setPlayState:NO];
        }
        else
        {
            if(_isReachEnd)
            {
                [_backgroundAudioPlayer playAtTime:0];
            }
            else
            {
                [_backgroundAudioPlayer play];
            }
            
            _isReachEnd=NO;
            [mainToolbar setPlayState:YES];
        }
    }
}

// 自然结束播放后，退回原先的界面
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag;
{
    //
    _isReachEnd=YES;
    
    [mainToolbar setPlayState:NO];
}

#pragma mark MFMailComposeViewControllerDelegate methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
	#ifdef DEBUG
		if ((result == MFMailComposeResultFailed) && (error != NULL)) NSLog(@"%@", error);
	#endif

	[self dismissViewControllerAnimated:YES completion:NULL]; // Dismiss
}

#pragma mark ThumbsViewControllerDelegate methods

- (void)dismissThumbsViewController:(ThumbsViewController *)viewController
{
	[self updateToolbarBookmarkIcon]; // Update bookmark icon

	[self dismissViewControllerAnimated:YES completion:NULL]; // Dismiss
}

- (void)thumbsViewController:(ThumbsViewController *)viewController gotoPage:(NSInteger)page showResult:(NSString*)keyword
{
    _searWord = keyword;
    _reflowMode=NO;
    
    NSMutableDictionary *unusedViews = [contentViews mutableCopy];
    [unusedViews enumerateKeysAndObjectsUsingBlock: // Remove unused views
     ^(id key, id object, BOOL *stop)
     {
         [contentViews removeObjectForKey:key];
         
         UIView<MuPageView> *contentView = object;
         
         [contentView removeFromSuperview];
     }
     ];
    unusedViews = nil; // Release unused views
    
    [self updateScrollViewContentSize]; // Set content size
	[self showDocumentPage:page];
    
	document.lastOpen = [NSDate date]; // Update last opened date
	isVisible = YES; // iOS present modal bodge
}

#pragma mark ReaderMainPagebarDelegate methods

- (void)pagebar:(ReaderMainPagebar *)pagebar gotoPage:(NSInteger)page
{
	[self showDocumentPage:page]; // Show the page
}

#pragma mark UIApplication notification methods

- (void)applicationWill:(NSNotification *)notification
{
	[document saveReaderDocument]; // Save any ReaderDocument object changes

	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
	{
		if (printInteraction != nil) [printInteraction dismissAnimated:NO];
	}
}

#pragma mark MuDialogCreator methods

- (void) invokeTextDialog:(NSString *)aString okayAction:(void (^)(NSString *))block
{
    /*
	MuTextFieldController *tf = [[MuTextFieldController alloc] initWithText:aString okayAction:block];
	tf.modalPresentationStyle = UIModalPresentationFormSheet;
	[self presentViewController:tf animated:YES completion:nil];
	[tf release];
     */
}

- (void) invokeChoiceDialog:(NSArray *)anArray okayAction:(void (^)(NSArray *))block
{
    /*
	MuChoiceFieldController *cf = [[MuChoiceFieldController alloc] initWithChoices:anArray okayAction:block];
	cf.modalPresentationStyle = UIModalPresentationFormSheet;
	[self presentViewController:cf animated:YES completion:nil];
	[cf release];
     */
}

#pragma mark MuUpdater methods

- (void) update
{
    /*
	for (UIView<MuPageView> *view in [canvas subviews])
		[view update];
     */
}


-(ReaderDocument *) getDocument
{
    return document;
}

@end
