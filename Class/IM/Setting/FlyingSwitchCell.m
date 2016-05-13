//
//  FlyingSwitchCell.m
//  FlyingEnglish
//
//  Created by vincent sung on 12/4/2016.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import "FlyingSwitchCell.h"
#import "shareDefine.h"

@interface FlyingSwitchCell()

@property (strong, nonatomic) IBOutlet UILabel  *itemLabel;
@property (strong, nonatomic) IBOutlet UISwitch *switchButton;

@end

@implementation FlyingSwitchCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    self.itemLabel.font= [UIFont systemFontOfSize:KNormalFontSize];
    
    [self.switchButton addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];

}

+ (FlyingSwitchCell*) switchCell
{
    FlyingSwitchCell * cell = [[[NSBundle mainBundle] loadNibNamed:@"FlyingSwitchCell" owner:self options:nil] objectAtIndex:0];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell.switchButton setEnabled:NO];
    
    return cell;
}


-(void) setItemText:(NSString*) itemText;
{
    self.itemLabel.text = itemText;
}

-(void) setSwitchON:(BOOL) isOn
{

    self.switchButton.on = isOn;
    
}

-(void)switchAction:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(switchAction:)])
    {
        [self.delegate switchAction:sender];
    }
}


@end
