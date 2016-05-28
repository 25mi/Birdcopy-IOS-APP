//
//  FlyingGroupMembersCell.m
//  FlyingEnglish
//
//  Created by vincent sung on 1/5/2016.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import "FlyingGroupMembersCell.h"
#import "FlyingAuthorCollectionViewCell.h"
#import "FlyingGroupMemberData.h"
#import "FlyingHttpTool.h"
#import "FlyingDataManager.h"
#import "FlyingConversationVC.h"
#import "NSString+FlyingExtention.h"
#import "iFlyingAppDelegate.h"

@interface FlyingGroupMembersCell()

@property (strong, atomic)  NSArray *memberList;

@end

@implementation FlyingGroupMembersCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    
    UINib *nib = [UINib nibWithNibName:@"FlyingAuthorCollectionViewCell" bundle: nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"FlyingAuthorCollectionViewCell"];
    self.collectionView.dataSource      = self;
    self.collectionView.delegate        = self;
    self.collectionView.supportTouch    = YES;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (FlyingGroupMembersCell*) groupMembersCell
{
    FlyingGroupMembersCell * cell = [[[NSBundle mainBundle] loadNibNamed:@"FlyingGroupMembersCell" owner:self options:nil] objectAtIndex:0];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(void)settingWithGroupData:(FlyingGroupData*) groupData
{
    self.groupData = groupData;
    
    if (groupData.gp_member_sum>0)
    {
        self.collectionHeight.constant = 64;
        
        if (!self.memberList)
        {
            
            [self loadMemberList];
        }
    }
    else
    {
        self.collectionHeight.constant = 0;
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
{
    return self.memberList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    FlyingAuthorCollectionViewCell* cell = (FlyingAuthorCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"FlyingAuthorCollectionViewCell" forIndexPath:indexPath];
    
    if(cell == nil)
        cell = [FlyingAuthorCollectionViewCell authorCollectionViewCell];
    
    FlyingGroupMemberData* memberData =(FlyingGroupMemberData*)[_memberList objectAtIndex:indexPath.row];
    
    [cell setImageIconURL:memberData.portrait_url];
    [cell setItemText:memberData.name];
    
    return cell;
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
{
    
    FlyingGroupMemberData * memberData = [self.memberList objectAtIndex:indexPath.row];
    
    //实时检查会员资格问题
    [FlyingHttpTool checkGroupMemberInfoForAccount:[FlyingDataManager getOpenUDID]
                                           GroupID:self.groupData.gp_id
                                        Completion:^(FlyingUserRightData *userRightData)
     {
         //是否合格会员
         if ([userRightData checkRightPresent])
         {
             
             FlyingConversationVC *chatVC = [[FlyingConversationVC alloc] init];
             
             chatVC.domainID    = self.groupData.gp_id;
             chatVC.domainType  = BC_Domain_Group;
             
             chatVC.targetId            = [memberData.openUDID MD5];
             chatVC.conversationType    = ConversationType_PRIVATE;
             chatVC.title               = memberData.name;
             
             iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
             [appDelegate pushViewController:chatVC animated:YES];
         }
         else
         {
             //显示会员状态信息
             NSString* message = [userRightData getMemberStateInfo];
             iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
             [appDelegate makeToast:message];
         }
     }];
}

//////////////////////////////////////////////////////////////
#pragma mark - Download data from Learning center
//////////////////////////////////////////////////////////////
- (void)loadMemberList
{
    [FlyingHttpTool getMemberListForGroupID:self.groupData.gp_id
                                 Completion:^(NSArray *memberList, NSInteger allRecordCount)
     {
         //
         if (memberList.count>20)
         {
             NSRange range;
             range.length=20;
             range.location=0;
             
             self.memberList = [memberList subarrayWithRange:range];
         }
         else
         {
             self.memberList = memberList;
         }
         
         if (self.memberList.count!=0)
         {
             
             NSArray *sortedArray = [self.memberList sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                 
                 NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                 [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                 
                 NSDate *first = [dateFormatter dateFromString: [(FlyingGroupMemberData *)a ayJoinTime]];
                 
                 NSDate *second = [dateFormatter dateFromString: [(FlyingGroupMemberData *)b ayJoinTime]];
                 
                 return [second compare:first];
             }];
             
             self.memberList =sortedArray;
             [self.collectionView reloadData];
         }
     }];
}

@end
