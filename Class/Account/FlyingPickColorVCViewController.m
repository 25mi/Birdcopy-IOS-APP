//
//  FlyingPickColorVCViewController.m
//  FlyingEnglish
//
//  Created by vincent on 6/2/15.
//  Copyright (c) 2015 BirdEngish. All rights reserved.
//

#import "FlyingPickColorVCViewController.h"
#import "iFlyingAppDelegate.h"
#import "FlyingSearchViewController.h"
#import "FlyingConversationListVC.h"
#import <CRToastManager.h>
#import "FlyingNavigationController.h"
#import "UIColor+RCColor.h"

@interface FlyingPickColorVCViewController ()<UIViewControllerRestoration>

@property (nonatomic, strong) UIImageView *cPicker;

@end

@implementation FlyingPickColorVCViewController

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents
                                                            coder:(NSCoder *)coder
{
    UIViewController *vc = [self new];
    return vc;
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
}

- (id)init
{
    if ((self = [super init]))
    {
        // Custom initialization
        self.restorationIdentifier = NSStringFromClass([self class]);
        self.restorationClass = [self class];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    //更新欢迎语言
    self.title = NSLocalizedString(@"Style Setting",nil);
    
    //顶部导航
    UIButton* resetButton= [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [resetButton setBackgroundImage:[UIImage imageNamed:@"refresh"] forState:UIControlStateNormal];
    [resetButton addTarget:self action:@selector(doReset) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* doResetButtonItem= [[UIBarButtonItem alloc] initWithCustomView:resetButton];
    
    self.navigationItem.rightBarButtonItem = doResetButtonItem;
    
    if (self.cPicker == nil) {
        
        self.cPicker = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 202, 202)];
        self.cPicker.image = [UIImage imageNamed:@"colorWheel"];
        [self.cPicker setUserInteractionEnabled:YES];
        [_cPicker setCenter:self.view.center];
        [self.view addSubview:_cPicker];
        
        // 单击的 Recognizer
        UITapGestureRecognizer *singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapFrom:)];
        singleRecognizer.numberOfTapsRequired = 1; // 单击
        [self.view addGestureRecognizer:singleRecognizer];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void) willDismiss
{
}

- (void) doReset
{
    iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setNavigationBarWithLogoStyle:YES];
}

- (void)handleSingleTapFrom: (UITapGestureRecognizer *)recognizer
{
    CGPoint touchPoint = [recognizer locationInView:self.cPicker];

    CGRect r = self.cPicker.frame;
    r.origin = CGPointZero;
    
    //更改导航条样式
    UIFont* font = [UIFont systemFontOfSize:19.f];
    
    UIColor *backgroundColor = [UIColor colorWithWhite:0.94 alpha:1.000];
    UIColor *textColor= [UIColor blackColor];
    
    if (CGRectContainsPoint(r, touchPoint)) {
        backgroundColor = [self getPixelColorAtLocation:touchPoint];
        const CGFloat *components = CGColorGetComponents(backgroundColor.CGColor);
        if (components[3] != 0) {
            
            textColor = [UIColor readableForegroundColorForBackgroundColor:backgroundColor];
            
            NSDictionary* textAttributes = @{NSFontAttributeName:font,
                                             NSForegroundColorAttributeName:textColor};
            [[UINavigationBar appearance] setTitleTextAttributes:textAttributes];
            [[UINavigationBar appearance] setTintColor:textColor];
            [[UINavigationBar appearance] setBarTintColor:backgroundColor];
            
            self.navigationController.navigationBar.barTintColor = [UINavigationBar appearance].barTintColor;
            self.navigationController.navigationBar.backgroundColor = [UINavigationBar appearance].backgroundColor;
        }
    }
    else
    {
        NSDictionary* textAttributes = @{NSFontAttributeName:font,
                                         NSForegroundColorAttributeName:textColor};
        [[UINavigationBar appearance] setTitleTextAttributes:textAttributes];
        [[UINavigationBar appearance] setTintColor:textColor];
        [[UINavigationBar appearance] setBarTintColor:backgroundColor];
        
        self.navigationController.navigationBar.barTintColor = [UINavigationBar appearance].barTintColor;
        self.navigationController.navigationBar.backgroundColor = [UINavigationBar appearance].backgroundColor;
    }
    
    NSData *textColorData = [NSKeyedArchiver archivedDataWithRootObject:textColor];
    NSData *backgroundColorData = [NSKeyedArchiver archivedDataWithRootObject:backgroundColor];
    
    [[NSUserDefaults standardUserDefaults] setObject:textColorData forKey:kNavigationTextColor];
    [[NSUserDefaults standardUserDefaults] setObject:backgroundColorData forKey:kNavigationBackColor];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (UIColor*) getPixelColorAtLocation:(CGPoint)point {
    UIColor* color = nil;
    
    
    CGImageRef inImage = [[self.cPicker image] CGImage];
    // Create off screen bitmap context to draw the image into. Format ARGB is 4 bytes for each pixel: Alpa, Red, Green, Blue
    CGContextRef cgctx = [self createARGBBitmapContextFromImage:inImage];
    if (cgctx == NULL) { return nil; /* error */ }
    
    size_t w = CGImageGetWidth(inImage);
    size_t h = CGImageGetHeight(inImage);
    CGRect rect = {{0,0},{w,h}};
    
    // Draw the image to the bitmap context. Once we draw, the memory
    // allocated for the context for rendering will then contain the
    // raw image data in the specified color space.
    CGContextDrawImage(cgctx, rect, inImage);
    
    // Now we can get a pointer to the image data associated with the bitmap
    // context.
    unsigned char* data = CGBitmapContextGetData (cgctx);
    if (data != NULL && data != 0) {
        //offset locates the pixel in the data from x,y.
        //4 for 4 bytes of data per pixel, w is width of one row of data.
        int offset = 4*((w*round(point.y))+round(point.x));
        int alpha =  data[offset];
        int red = data[offset+1];
        int green = data[offset+2];
        int blue = data[offset+3];
        NSLog(@"offset: %i colors: RGB A %i %i %i  %i",offset,red,green,blue,alpha);
        color = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha/255.0f)];
    }
    
    // When finished, release the context
    CGContextRelease(cgctx); 
    // Free image data memory for the context
    if (data) { free(data); }
    
    return color;
}


- (CGContextRef) createARGBBitmapContextFromImage:(CGImageRef) inImage {
    
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    unsigned long   bitmapByteCount;
    unsigned long   bitmapBytesPerRow;
    
    // Get image width, height. We'll use the entire image.
    size_t pixelsWide = CGImageGetWidth(inImage);
    size_t pixelsHigh = CGImageGetHeight(inImage);
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow   = (pixelsWide * 4);
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
    
    // Use the generic RGB color space.
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    if (colorSpace == NULL)
    {
        fprintf(stderr, "Error allocating color space\n");
        return NULL;
    }
    
    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL)
    {
        fprintf (stderr, "Memory not allocated!");
        CGColorSpaceRelease( colorSpace );
        return NULL;
    }
    
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    // per component. Regardless of what the source image format is
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    context = CGBitmapContextCreate (bitmapData,
                                     pixelsWide,
                                     pixelsHigh,
                                     8,      // bits per component
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedFirst);
    if (context == NULL)
    {
        free (bitmapData);
        fprintf (stderr, "Context not created!");
    }
    
    // Make sure and release colorspace before returning
    CGColorSpaceRelease( colorSpace );
    
    return context;
}

@end
