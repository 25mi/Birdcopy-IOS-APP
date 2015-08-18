//
//  DSBarChart.m
//  DSBarChart
//
//  Created by DhilipSiva Bijju on 31/10/12.
//  Copyright (c) 2012 Tataatsu IdeaLabs. All rights reserved.
//

#import "DSBarChart.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@implementation DSBarChart
@synthesize color, numberOfBars, maxLen, refs, vals;

-(DSBarChart *)initWithFrame:(CGRect)frame
                       color:(UIColor *)theColor
                  references:(NSArray *)references
                   andValues:(NSArray *)values
{
    self = [super initWithFrame:frame];
    if (self) {
        self.color = theColor;
        self.vals = values;
        self.refs = references;
    }
    return self;
}

-(void)calculate{
    self.numberOfBars = [self.vals count];
    for (NSNumber *val in vals) {
        float iLen = [val floatValue];
        if (iLen > self.maxLen) {
            self.maxLen = iLen;
        }
    }
}

- (void)drawRect:(CGRect)rect
{
    /// Drawing code
    [self calculate];
    float rectWidth = (float)(rect.size.width-(self.numberOfBars)) / (float)self.numberOfBars;
    CGContextRef context = UIGraphicsGetCurrentContext();
    float LBL_HEIGHT = 20.0f, iLen, x, heightRatio, height, y;
    UIColor *iColor ;
    
    /// Draw Bars
    BOOL colorOK=YES;
    for (int barCount = 0; barCount < self.numberOfBars; barCount++) {
        
        /// Calculate dimensions
        iLen = [[vals objectAtIndex:barCount] floatValue];
        x = barCount * (rectWidth);
        heightRatio = iLen / self.maxLen;
        height = heightRatio * rect.size.height;
        if (height < 0.1f) height = 1.0f;
        y = rect.size.height - height - LBL_HEIGHT;
        
        /// Reference Label.
        UILabel *lblRef = [[UILabel alloc] initWithFrame:CGRectMake(barCount + x, rect.size.height - LBL_HEIGHT, rectWidth, LBL_HEIGHT)];
        lblRef.text = [refs objectAtIndex:barCount];
        //lblRef.adjustsFontSizeToFitWidth = TRUE;
        lblRef.font= [UIFont boldSystemFontOfSize:12.0];

        if (INTERFACE_IS_PAD ) {
            lblRef.font= [UIFont boldSystemFontOfSize:20.0];
        }

        lblRef.textColor = self.color;
        //lblRef.adjustsLetterSpacingToFitWidth = TRUE;
        [lblRef setTextAlignment:NSTextAlignmentCenter];
        lblRef.backgroundColor = [UIColor clearColor];
        [self addSubview:lblRef];
        
        /// Set color and draw the bar
        if (colorOK) {
            
            iColor=self.color;
            colorOK=NO;
        }
        else{
            
            iColor = [UIColor colorWithRed:0.6 green:0.4 blue:0.2 alpha:0.9];
            colorOK=YES;
        }
        
        CGContextSetFillColorWithColor(context, iColor.CGColor);
        CGRect barRect = CGRectMake(barCount + x, y, rectWidth, height);
        CGContextFillRect(context, barRect);
    }
    
    float alpha=0.2;
    if (INTERFACE_IS_PAD) {
        
        alpha=1;
    }
    
    /// pivot
    CGRect frame = CGRectZero;
    frame.origin.x = rect.origin.x;
    frame.origin.y = rect.origin.y + LBL_HEIGHT*alpha;
    frame.size.height = LBL_HEIGHT;
    frame.size.width = rect.size.width - LBL_HEIGHT*alpha;

    //标题
    UILabel *pivotLabel = [[UILabel alloc] initWithFrame:frame];
    pivotLabel.text = @"[单词分布]";
    pivotLabel.font= [UIFont systemFontOfSize:10.0];
    if (INTERFACE_IS_PAD ) {
        pivotLabel.font= [UIFont systemFontOfSize:16.0];
    }

    pivotLabel.textAlignment=NSTextAlignmentRight;

    pivotLabel.backgroundColor = [UIColor clearColor];
    pivotLabel.textColor = [UIColor whiteColor];
    [self addSubview:pivotLabel];
}


@end
