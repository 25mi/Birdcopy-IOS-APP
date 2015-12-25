//
//	ReaderMainToolbar.m
//	Reader v2.6.2
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

#import "ReaderConstants.h"
#import "ReaderMainToolbar.h"
#import "ReaderDocument.h"

#import <MessageUI/MessageUI.h>

@interface ReaderMainToolbar()

@property (nonatomic, strong) UIButton *playButton;

@property (nonatomic, strong) UIImage* buttonImageN;
@property (nonatomic, strong) UIImage* buttonImageH;


@end


@implementation ReaderMainToolbar

#pragma mark Constants

#define BUTTON_X 8.0f
#define BUTTON_Y 8.0f
#define BUTTON_SPACE 8.0f
#define BUTTON_HEIGHT 30.0f
#define BUTTON_WIDTH 40.0f

//#define DONE_BUTTON_WIDTH   56.0f

#define TITLE_HEIGHT 28.0f

#pragma mark Properties

@synthesize delegate;

#pragma mark ReaderMainToolbar instance methods

- (id)initWithFrame:(CGRect)frame
{
	return [self initWithFrame:frame document:nil];
}

- (id)initWithFrame:(CGRect)frame document:(ReaderDocument *)object
{
	assert(object != nil); // Must have a valid ReaderDocument

	if ((self = [super initWithFrame:frame]))
	{
		CGFloat viewWidth = self.bounds.size.width;

		//CGFloat titleX = BUTTON_X+(BUTTON_WIDTH + BUTTON_SPACE);;
        //CGFloat titleWidth = (viewWidth - (titleX + titleX));

		CGFloat leftButtonX = BUTTON_X; // Left button start X position
        CGFloat rightButtonX = viewWidth-(BUTTON_WIDTH + BUTTON_SPACE);// Right button start X position

        //退出按钮
        UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
		doneButton.frame = CGRectMake(leftButtonX, BUTTON_Y, BUTTON_WIDTH/1.5, BUTTON_WIDTH/1.5);
        [doneButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
		[doneButton addTarget:self action:@selector(doneButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		doneButton.autoresizingMask = UIViewAutoresizingNone;
		doneButton.exclusiveTouch = YES;

		[self addSubview:doneButton];
        //leftButtonX += (DONE_BUTTON_WIDTH + BUTTON_SPACE);
        //titleWidth -= (BUTTON_WIDTH + BUTTON_SPACE);
        
        //搜索按钮
        UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        searchButton.frame = CGRectMake(rightButtonX, BUTTON_Y, BUTTON_WIDTH, BUTTON_HEIGHT);
		[searchButton setImage:[UIImage imageNamed:@"readersearch"] forState:UIControlStateNormal];
		[searchButton addTarget:self action:@selector(searchButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		//[searchButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
		//[searchButton setBackgroundImage:buttonN forState:UIControlStateNormal];
		searchButton.autoresizingMask = UIViewAutoresizingNone;
		searchButton.exclusiveTouch = YES;
        
        [self addSubview:searchButton];
        //titleWidth -= (BUTTON_WIDTH + BUTTON_SPACE);
        rightButtonX -= (BUTTON_WIDTH + BUTTON_SPACE);
        //titleWidth -= (BUTTON_WIDTH + BUTTON_SPACE);
        
        //播放按钮
		UIButton *flagButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
		flagButton.frame = CGRectMake(rightButtonX, BUTTON_Y, BUTTON_HEIGHT, BUTTON_HEIGHT);
		[flagButton addTarget:self action:@selector(playButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		//[flagButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
		//[flagButton setBackgroundImage:buttonN forState:UIControlStateNormal];
		flagButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
		flagButton.exclusiveTouch = YES;
        
		[self addSubview:flagButton];
        rightButtonX -= (BUTTON_WIDTH + BUTTON_SPACE);
        //titleWidth -= (BUTTON_WIDTH + BUTTON_SPACE);
        
		self.playButton = flagButton; self.playButton.enabled = YES; self.playButton.tag = NSIntegerMin;
        
        self.buttonImageN= [UIImage imageNamed:@"PlayAudio"];
        self.buttonImageH= [UIImage imageNamed:@"Pause"];

        
        Class printInteractionController = NSClassFromString(@"UIPrintInteractionController");
        
        if ((printInteractionController != nil) && [printInteractionController isPrintingAvailable])
        {
            UIButton *printButton = [UIButton buttonWithType:UIButtonTypeCustom];
            
            printButton.frame = CGRectMake(rightButtonX, BUTTON_Y, BUTTON_WIDTH, BUTTON_HEIGHT);
            [printButton setImage:[UIImage imageNamed:@"Reader-Print"] forState:UIControlStateNormal];
            [printButton addTarget:self action:@selector(printButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            //[printButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
            //[printButton setBackgroundImage:buttonN forState:UIControlStateNormal];
            printButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            printButton.exclusiveTouch = YES;
            
            [self addSubview:printButton];
            
            //rightButtonX -= (BUTTON_WIDTH + BUTTON_SPACE);
            //titleWidth -= (BUTTON_WIDTH + BUTTON_SPACE);
        }
    }

	return self;
}

- (void)setPlayState:(BOOL)state
{
	if (state != self.playButton.tag) // Only if different state
	{
		if (self.hidden == NO) // Only if toolbar is visible
		{
			UIImage *image = (state ? self.buttonImageH : self.buttonImageN);
            
            self.playButton.tag = state; // Update bookmarked state tag
			[self.playButton setImage:image forState:UIControlStateNormal];
		}
	}
}

- (void)updatePlayImage
{
	if (self.playButton.tag != NSIntegerMin) // Valid tag
	{
		BOOL state = self.playButton.tag; // Bookmarked state

		UIImage *image = (state ? self.buttonImageH : self.buttonImageN);

		[self.playButton setImage:image forState:UIControlStateNormal];
	}
}

- (void)showPlayButton
{
    [self.playButton setHidden:NO];
}

- (void)hidePlayButton;
{
    [self.playButton setHidden:YES];
}

- (void)hideToolbar
{
	if (self.hidden == NO)
	{
		[UIView animateWithDuration:0.25 delay:0.0
			options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
			animations:^(void)
			{
				self.alpha = 0.0f;
			}
			completion:^(BOOL finished)
			{
				self.hidden = YES;
			}
		];
	}
}

- (void)showToolbar
{
	if (self.hidden == YES)
	{
		[self updatePlayImage]; // First

		[UIView animateWithDuration:0.25 delay:0.0
			options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
			animations:^(void)
			{
				self.hidden = NO;
				self.alpha = 1.0f;
			}
			completion:NULL
		];
	}
}

#pragma mark UIButton action methods

- (void)doneButtonTapped:(UIButton *)button
{
	[delegate tappedInToolbar:self doneButton:button];
}

- (void)searchButtonTapped:(UIButton *)button
{
	[delegate tappedInToolbar:self searchButton:button];
}

- (void)printButtonTapped:(UIButton *)button
{
	[delegate tappedInToolbar:self printButton:button];
}

- (void)playButtonTapped:(UIButton *)button
{
	[delegate tappedInToolbar:self playButton:button];
}

@end
