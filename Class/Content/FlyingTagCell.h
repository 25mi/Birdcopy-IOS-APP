//
//  FlyingTagCell.h
//  FlyingEnglish
//
//  Created by vincent sung on 11/20/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DWTagList.h"

@interface FlyingTagCell : UITableViewCell
@property (strong, nonatomic) IBOutlet DWTagList *contentTagList;

+ (FlyingTagCell*) tagCell;

-(void)setTagList:(NSString*)tagList DataSourceDelegate:(id<DWTagListDelegate>)dataSourceDelegate;

@end
