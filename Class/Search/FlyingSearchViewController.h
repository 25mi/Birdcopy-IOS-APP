//
//  FlyingSearchViewController.h
//  FlyingEnglish
//
//  Created by BE_Air on 6/20/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "shareDefine.h"
@class FlyingFakeHUD;
@class FlyingSearchBar;

@interface FlyingSearchViewController : UIViewController<UITableViewDataSource,
                                                        UITableViewDelegate,
                                                        UISearchBarDelegate,
                                                        UISearchDisplayDelegate>

@property (strong, nonatomic) IBOutlet UITableView         *tableView;
@property (strong, nonatomic) IBOutlet FlyingSearchBar     *searchBar;

@property (assign, nonatomic)          BESearchType         searchType;

@property (strong, nonatomic)  NSString                    *author;

@end
