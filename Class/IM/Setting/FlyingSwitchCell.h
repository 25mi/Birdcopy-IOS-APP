//
//  FlyingSwitchCell.h
//  FlyingEnglish
//
//  Created by vincent sung on 12/4/2016.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol FlyingSwitchCellDelegate <NSObject>

@optional
- (void)switchAction:(id)sender;
@end


@interface FlyingSwitchCell : UITableViewCell


@property(nonatomic,assign) id<FlyingSwitchCellDelegate> delegate;

+ (FlyingSwitchCell*) switchCell;

-(void) setItemText:(NSString*) itemText;

-(void) setSwitchON:(BOOL) isOn;

@end
