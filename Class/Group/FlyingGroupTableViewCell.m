//
//  FlyingGroupTableViewCell.m
//  FlyingEnglish
//
//  Created by vincent sung on 2/25/16.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import "FlyingGroupTableViewCell.h"
#import "shareDefine.h"
#import "FlyingGroupData.h"
#import <UIImageView+AFNetworking.h>
#import "NSString+FlyingExtention.h"
#import "FlyingGroupUpdateData.h"
#import "FlyingMemberIconCellCollectionViewCell.h"
#import "FlyingGroupMemberData.h"
#import "FlyingHttpTool.h"
#import "FlyingGroupVC.h"
#import "FlyingDataManager.h"
#import "FlyingConversationVC.h"
#import "iFlyingAppDelegate.h"
#import <CRToastManager.h>
#import "FlyingSoundPlayer.h"

@interface FlyingGroupTableViewCell()

@property (strong, nonatomic)  NSArray *memberList;

@end

@implementation FlyingGroupTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    self.nameLabel.font= [UIFont systemFontOfSize:KLargeFontSize];
    
    self.memberCountLabel.font= [UIFont systemFontOfSize:KSmallFontSize];
    self.contentCountLabel.font= [UIFont systemFontOfSize:KSmallFontSize];
    self.dateLabel.font= [UIFont systemFontOfSize:KSmallFontSize];
    self.descriptionLabel.font= [UIFont systemFontOfSize:KNormalFontSize];
    
    [self.groupIconImageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.isPublicIcon setContentMode:UIViewContentModeScaleAspectFill];
    
    UINib *nib = [UINib nibWithNibName:@"FlyingMemberIconCellCollectionViewCell" bundle: nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"FlyingMemberIconCellCollectionViewCell"];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

+ (FlyingGroupTableViewCell*) groupCell
{
    FlyingGroupTableViewCell * cell = [[[NSBundle mainBundle] loadNibNamed:@"FlyingGroupTableViewCell" owner:self options:nil] objectAtIndex:0];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(void)settingWithGroupData:(FlyingGroupUpdateData*) groupUpdateData;
{
    self.groupUpdateData = groupUpdateData;
    
    if (groupUpdateData.groupData.is_public_access)
    {
        self.collectionHeight.constant = 40;
        
        if (!self.memberList) {
            
            [self loadMemberList];
        }
    }
    else
    {
        self.collectionHeight.constant = 0;
    }
    
    if (groupUpdateData.groupData.is_public_access) {
        
        [self.isPublicIcon setImage:[UIImage imageNamed:@"public"]];
    }
    else
    {
        [self.isPublicIcon setImage:[UIImage imageNamed:@"lock"]];
    }
    
    if (groupUpdateData.groupData.logo.length!=0) {
        
        [self.groupIconImageView setImageWithURL:[NSURL URLWithString:groupUpdateData.groupData.logo] placeholderImage:[UIImage imageNamed:@"Icon"]];
    }
    else
    {
        
        [self.groupIconImageView setImage:[UIImage imageNamed:@"Icon"]];
    }
    
    self.nameLabel.text = groupUpdateData.groupData.gp_name;
    self.memberCountLabel.text = groupUpdateData.groupData.gp_member_sum;
    self.contentCountLabel.text = groupUpdateData.groupData.gp_ln_sum;
    
    if([groupUpdateData.recentLessonData.timeLamp containsString:@"-"] &&
       [groupUpdateData.recentLessonData.timeLamp containsString:@":"])
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        NSDate *Date = [dateFormatter dateFromString:groupUpdateData.recentLessonData.timeLamp];
        
        self.dateLabel.text =[NSString stringFromTimeInterval:-[Date timeIntervalSinceNow]];
    }
    else
    {
        NSDate *now = [NSDate date];
        self.dateLabel.text = [NSString stringFromTimeInterval:-[now timeIntervalSinceNow]];
    }
    
    self.descriptionLabel.text = groupUpdateData.groupData.gp_desc;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
{
    return self.memberList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    FlyingMemberIconCellCollectionViewCell* cell = (FlyingMemberIconCellCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"FlyingMemberIconCellCollectionViewCell" forIndexPath:indexPath];
    
    if(cell == nil)
        cell = [FlyingMemberIconCellCollectionViewCell memberIconCell];
    
    FlyingGroupMemberData* memberData =(FlyingGroupMemberData*)[_memberList objectAtIndex:indexPath.row];
    
    [cell setImageIconURL:memberData.portrait_url];
    
    return cell;
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
{
    //实时检查会员资格问题
    [FlyingHttpTool checkGroupMemberInfoForAccount:[FlyingDataManager getOpenUDID]
                                           GroupID:self.groupUpdateData.groupData.gp_id
                                        Completion:^(FlyingUserRightData *userRightData)
     {
         //是否合格会员
         if ([userRightData checkRightPresent])
         {
             
             FlyingGroupMemberData * memberData = [self.memberList objectAtIndex:indexPath.row];
             
             FlyingConversationVC *chatVC = [[FlyingConversationVC alloc] init];
             
             chatVC.domainID    = self.groupUpdateData.groupData.gp_id;
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
             [CRToastManager showNotificationWithMessage:message
                                         completionBlock:^{
                                             NSLog(@"Completed");
                                         }];
         }
     }];
}

//////////////////////////////////////////////////////////////
#pragma mark - Download data from Learning center
//////////////////////////////////////////////////////////////
- (void)loadMemberList
{
    [FlyingHttpTool getMemberListForGroupID:self.groupUpdateData.groupData.gp_id
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
