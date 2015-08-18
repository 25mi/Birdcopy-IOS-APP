//
//  CKTableViewCell.h
//  MBCalendarKit
//
//  Created by Rachel Hyman on 6/2/14.
//  Copyright (c) 2014 Moshe Berman. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CKCalendarEvent;

@interface CKTableViewCell : UITableViewCell

@property (nonatomic, strong) CKCalendarEvent* theEvent;

@end
