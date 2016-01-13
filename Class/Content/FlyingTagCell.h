//
//  FlyingTagCell.h
//  FlyingEnglish
//
//  Created by vincent sung on 11/20/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TLTagsControl.h"

@interface FlyingTagCell : UITableViewCell
@property (strong, nonatomic) IBOutlet TLTagsControl *contentTagList;

+ (FlyingTagCell*) tagCell;

-(void)setTagList:(NSString*)tagList DataSourceDelegate:(id<TLTagsControlDelegate>)dataSourceDelegate;

@end
