//
//  FlyingtAuthorCell.h
//  FlyingEnglish
//
//  Created by vincent sung on 20/4/2016.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FlyingtAuthorCell : UITableViewCell

+ (FlyingtAuthorCell*) authorCell;

-(void) setAuthorText:(NSString*) author;
-(void) setAuthorIcon:(UIImage*) icon;
-(void) setAuthorIconWithURL:(NSString*) iconURL;

-(void) setHelpText:(NSString*) helpText;

@end
