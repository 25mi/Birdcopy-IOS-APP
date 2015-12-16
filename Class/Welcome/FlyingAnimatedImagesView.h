//
//  FlyingAnimatedImagesView.h
//  FlyingEnglish
//
//  Created by vincent sung on 12/10/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kJSAnimatedImagesViewDefaultTimePerImage 20.0f

@protocol FlyingAnimatedImagesViewDelegate;

@interface FlyingAnimatedImagesView : UIView

@property (nonatomic, assign) id<FlyingAnimatedImagesViewDelegate> delegate;

@property (nonatomic, assign) NSTimeInterval timePerImage;

- (void)startAnimating;
- (void)stopAnimating;

- (void)reloadData;

@end

@protocol FlyingAnimatedImagesViewDelegate
- (NSUInteger)animatedImagesNumberOfImages:(FlyingAnimatedImagesView *)animatedImagesView;
- (UIImage *)animatedImagesView:(FlyingAnimatedImagesView *)animatedImagesView imageAtIndex:(NSUInteger)index;
@end
