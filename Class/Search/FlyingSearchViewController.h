//
//  FlyingSearchViewController.h
//  FlyingEnglish
//
//  Created by BE_Air on 6/20/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "shareDefine.h"
#import "FlyingViewController.h"

@interface FlyingSearchViewController : FlyingViewController<UITableViewDataSource,
                                                        UITableViewDelegate,
                                                        UISearchBarDelegate,
                                                        UISearchDisplayDelegate>

@property (strong, nonatomic) IBOutlet UITableView         *tableView;
@property (strong, nonatomic) IBOutlet UISearchBar         *searchBar;

@property (assign, nonatomic)          BESearchType         searchType;
@property (strong, nonatomic) NSString                      *domainID;
@property (assign, nonatomic)          BC_Domain_Type       domainType;

@end
