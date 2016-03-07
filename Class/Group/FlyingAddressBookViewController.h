//
//  FlyingAddressBookViewController.h

#import <UIKit/UIKit.h>
#import "FlyingViewController.h"
//#import "RCSelectPersonViewController.h"

@interface FlyingAddressBookViewController : FlyingViewController<
                                                                    UITableViewDataSource,
                                                                    UITableViewDelegate>

@property (nonatomic, strong) NSArray *keys;
@property (nonatomic, strong) NSMutableDictionary *allFriends;
@property (nonatomic,strong) NSArray *allKeys;

@property (nonatomic,strong) NSArray *seletedUsers;

@property (nonatomic,assign) BOOL hideSectionHeader;
@end
