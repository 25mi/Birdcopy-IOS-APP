//
//  FlyingMemberTableViewCell.h
//  FlyingEnglish
//
//  Created by vincent sung on 4/4/2016.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlyingMemberTableViewCell : UITableViewCell

+ (FlyingMemberTableViewCell*) memberTableCell;

-(void) setPortraitURL:(NSString*) portraitURL;
-(void) setStart:(NSDate*) start;
-(void) setEnd:(NSDate*) end;

@end
