//
//  TheContactViewController.m
//  ColorLetter
//
//  Created by dllo on 16/10/20.
//  Copyright © 2016年 yzy. All rights reserved.
//

#import "TheContactViewController.h"
#import "FZY_SliderScrollView.h"
#import "FZY_FriendRequestViewController.h"
#import "FZY_FriendsTableViewCell.h"
#import "FZY_RequestTableViewCell.h"
#import "FZY_RequestModel.h"
#import "FZY_ChatViewController.h"
#import "FZY_CreateGroupViewController.h"
#import "FZY_GroupTableViewCell.h"

static NSString *const leftIdentifier = @"leftCell";
static NSString *const IdentifierLeft = @"requestLeftCell";
static NSString *const rightIdentifier = @"rightCell";


@interface TheContactViewController ()
<
FZY_SliderScrollViewDelegate,
UIScrollViewDelegate,
UITableViewDataSource,
UITableViewDelegate,
UISearchResultsUpdating,
EMContactManagerDelegate,
EMGroupManagerDelegate,
FZY_CreateGroupViewControllerDelegate
>

{
    CGFloat slideLength;
}

@property (nonatomic, strong) UIScrollView *downScrollView;
@property (nonatomic, strong) FZY_SliderScrollView *sliderScrollView;
@property (nonatomic, strong) UIView *upView;
@property (nonatomic, assign) CGFloat count;

@property (nonatomic, strong)UISearchController *searchController;

@property (nonatomic, strong) UITableView *leftTabeleView;
@property (nonatomic, strong) UITableView *rightTableView;

@property (nonatomic, strong) NSMutableArray *leftArray;
@property (nonatomic, retain) NSMutableArray *searchLeftArray;

@property (nonatomic, strong) NSMutableArray *rightArray;
@property (nonatomic, strong) UILabel *label;

@property (nonatomic, strong) NSMutableArray *friendRequest;

@property (nonatomic, assign) BOOL select;

@end

@implementation TheContactViewController

- (void)dealloc {
    //移除好友回调
    [[EMClient sharedClient].contactManager removeDelegate:self];
    [[EMClient sharedClient].groupManager removeDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BackToTabBarViewController" object:nil];
    [self getFriendList];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = YES;
    
    if (self.searchController.active) {
        self.searchController.active = NO;
        [self.searchController.searchBar removeFromSuperview];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    slideLength = (WIDTH - 120) / 2;
    self.leftArray = [NSMutableArray array];
    self.rightArray = [NSMutableArray array];
    self.searchLeftArray = [NSMutableArray array];
    self.friendRequest = [NSMutableArray array];
    _select = 1;
    [self creatDownScrollView];
    [self ChooseSingleOrGroup];
    
    //注册好友回调
    [[EMClient sharedClient].contactManager addDelegate:self delegateQueue:nil];
    
    // 注册群组回调
    [[EMClient sharedClient].groupManager addDelegate:self delegateQueue:nil];
    
    [self create];
}

#pragma mark - 获取群, 好友列表
- (void)getFriendList {
    EMError *error = nil;
    if (_leftArray.count > 0) {
        [_leftArray removeAllObjects];
    }
    NSArray *userlist = [[EMClient sharedClient].contactManager getContactsFromServerWithError:&error];
    if (!error) {
        [_leftArray addObjectsFromArray:userlist];
    }
    
    EMError *groupError = nil;
    NSArray *myGroups = [[EMClient sharedClient].groupManager getMyGroupsFromServerWithError:&groupError];
    if (!groupError) {
        NSLog(@"获取群列表成功 -- %@",myGroups);

        [_rightArray addObjectsFromArray:myGroups];

    }
}

#pragma mark - 收到进群申请
// 用户A向群组G发送入群申请，群组G的群主会接收到该回调
- (void)didReceiveJoinGroupApplication:(EMGroup *)aGroup
                             applicant:(NSString *)aApplicant
                                reason:(NSString *)aReason {
    NSLog(@"%@", aApplicant);
}

#pragma mark - 收到群组邀请回调
- (void)didJoinGroup:(EMGroup *)aGroup inviter:(NSString *)aInviter message:(NSString *)aMessage {
    NSLog(@"----- %@", aMessage);
}

#pragma mark - 收到好友邀请回调
- (void)didReceiveFriendInvitationFromUsername:(NSString *)aUsername
                                       message:(NSString *)aMessage {
    NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:0];
    if (_leftArray.count > 0) {
        for (NSString *str in _leftArray) {
            if ([str isEqualToString:aUsername]) {
                return;
            }
        }
    }
    NSDictionary *dic = @{@"aUsername" : [NSString stringWithFormat:@"%@", aUsername], @"aMessage" : [NSString stringWithFormat:@"%@", aMessage]};
    FZY_RequestModel *fzy = [FZY_RequestModel modelWithDic:dic];
    [_friendRequest insertObject:fzy atIndex:0];
    [_leftTabeleView insertRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationRight];
    [_leftTabeleView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    
}

/*!
 @method
 @brief 用户A发送加用户B为好友的申请，用户B同意后，用户A会收到这个回调
 */
- (void)didReceiveAgreedFromUsername:(NSString *)aUsername {
    UIAlertController *alert=[UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@已同意你的请求", aUsername] message:nil preferredStyle:UIAlertControllerStyleAlert];
    //创建一个取消和一个确定按钮
    UIAlertAction *actionCancle=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
    //将取消和确定按钮添加进弹框控制器
    [alert addAction:actionCancle];
    //显示弹框控制器
    [self presentViewController:alert animated:YES completion:nil];
    [_leftTabeleView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
}

/*!
 @method
 @brief 用户A发送加用户B为好友的申请，用户B拒绝后，用户A会收到这个回调
 */
- (void)didReceiveDeclinedFromUsername:(NSString *)aUsername{
    UIAlertController *alert=[UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@拒绝添加您为好友", aUsername] message:nil preferredStyle:UIAlertControllerStyleAlert];
    //创建一个取消和一个确定按钮
    UIAlertAction *actionCancle=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
       //将取消和确定按钮添加进弹框控制器
    [alert addAction:actionCancle];
    //显示弹框控制器
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 创建滑块
- (void)ChooseSingleOrGroup {

    self.upView = [[UIView alloc] initWithFrame:CGRectMake(60, 25, WIDTH - 120, 30)];
    _upView.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    _upView.layer.cornerRadius = 15;
    [self.view addSubview:_upView];
    
    self.sliderScrollView = [[FZY_SliderScrollView alloc] initWithFrame:CGRectMake(3, 2, _upView.frame.size.width / 2, 26)];
    _sliderScrollView.showsHorizontalScrollIndicator = YES  ;
    _sliderScrollView.showsVerticalScrollIndicator = YES;
    _sliderScrollView.backgroundColor = [UIColor colorWithRed:0.15 green:0.15 blue:0.21 alpha:1];
    _sliderScrollView.sliderDelegate = self;
    _sliderScrollView.layer.cornerRadius = 13;
    _sliderScrollView.clipsToBounds = YES;
    [_upView addSubview:_sliderScrollView];
    
    UIButton *friendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [friendsButton setTitle:@"Friends" forState:UIControlStateNormal];
    [friendsButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1] forState:UIControlStateNormal];
    [friendsButton handleControlEvent:UIControlEventTouchUpInside withBlock:^{
        [UIView animateWithDuration:0.2 animations:^{
            _downScrollView.contentOffset = CGPointMake(0, 0);
        }];
    }];
    [_upView addSubview:friendsButton];
    [friendsButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_upView).offset(30);
        make.width.equalTo(@70);
        make.top.equalTo(_upView).offset(5);
        make.bottom.equalTo(_upView.mas_bottom).offset(-5);
    }];
    
    UIButton *groudButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [groudButton setTitle:@"Group" forState:UIControlStateNormal];
    [groudButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1] forState:UIControlStateNormal];
    [groudButton handleControlEvent:UIControlEventTouchUpInside withBlock:^{
        [UIView animateWithDuration:0.2 animations:^{
            _downScrollView.contentOffset = CGPointMake(WIDTH, 0);
        }];
    }];
    [_upView addSubview:groudButton];
    [groudButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_upView).offset(-30);
        make.width.equalTo(@70);
        make.top.equalTo(_upView).offset(5);
        make.bottom.equalTo(_upView.mas_bottom).offset(-5);
    }];
    
}

#pragma mark - 实现自定义协议 获取滑块位置
- (void)getSliderPostionX:(CGFloat)x {
    NSLog(@"%f, %f",x, slideLength);
    if (x > (slideLength / 2)) {
        [UIView animateWithDuration:0.2 animations:^{
            _downScrollView.contentOffset = CGPointMake(WIDTH , 0);
        }];
    }else if (x < (slideLength / 2)){
        [UIView animateWithDuration:0.2 animations:^{
            _downScrollView.contentOffset = CGPointMake(0 , 0);
        }];
    }
//    [UIView animateWithDuration:0.1 animations:^{
//        _downScrollView.contentOffset = CGPointMake(x * WIDTH / slideLength, 0);
//    }];
//    
}

#pragma mark - scrollView 关联滑块
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
        
            if ([scrollView isEqual:_downScrollView]) {
                if (scrollView.contentOffset.y == 0) {
                    NSInteger i = 0;
                    if (scrollView.contentOffset.x > _count) {
                        i = -3;
                    } else {
                        i = 3;
                    }
                    _sliderScrollView.frame = CGRectMake(scrollView.contentOffset.x * (slideLength / WIDTH) + i, 2, _upView.frame.size.width / 2, 26);
                    self.count = scrollView.contentOffset.x ;
                }
                
        }
    

            
        //}

//    [UIView animateWithDuration:0.1 animations:^{
//        _sliderScrollView.transform = CGAffineTransformMakeTranslation(scrollView.contentOffset.x * (slideLength / WIDTH) + i, 0);
//    }];
}

#pragma mark - 创建 downScrollView, tableView
- (void)creatDownScrollView {
    
    self.downScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64 + 40, WIDTH, HEIGHT - 64 - 49 - 40)];
    _downScrollView.bounces = NO;
    _downScrollView.scrollEnabled = YES;
    _downScrollView.contentSize = CGSizeMake(WIDTH * 2, 0);
    _downScrollView.showsHorizontalScrollIndicator = NO;
    _downScrollView.pagingEnabled = YES;
    _downScrollView.delegate = self;
    [self.view addSubview:_downScrollView];
    
    self.leftTabeleView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT - 64 - 49 - 50 ) style:UITableViewStylePlain];
    _leftTabeleView.delegate = self;
    _leftTabeleView.dataSource = self;
    _leftTabeleView.separatorStyle = UITableViewCellAccessoryNone;
    [_downScrollView addSubview:_leftTabeleView];
    [_leftTabeleView registerClass:[FZY_FriendsTableViewCell class] forCellReuseIdentifier:leftIdentifier];
    [_leftTabeleView registerClass:[FZY_RequestTableViewCell class] forCellReuseIdentifier:IdentifierLeft];
    
    self.rightTableView = [[UITableView alloc] initWithFrame:CGRectMake(WIDTH, 0, WIDTH, HEIGHT - 64 - 49 - 50) style:UITableViewStylePlain];
    _rightTableView.delegate = self;
    _rightTableView.dataSource = self;
    _rightTableView.separatorStyle = UITableViewCellAccessoryNone;
    [_downScrollView addSubview:_rightTableView];
    [_rightTableView registerClass:[FZY_GroupTableViewCell class] forCellReuseIdentifier:rightIdentifier];
    
    UIView *myView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, WIDTH, 50)];
    [self.view addSubview:myView];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    _searchController.searchResultsUpdater = self;
    _searchController.dimsBackgroundDuringPresentation = false;
    [_searchController.searchBar sizeToFit];
    _searchController.hidesNavigationBarDuringPresentation = NO;
    _searchController.dimsBackgroundDuringPresentation = NO;
    _searchController.obscuresBackgroundDuringPresentation = NO;
    [myView addSubview:_searchController.searchBar];
    
}

#pragma mark - tableView 协议
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:_leftTabeleView]) {
                if (0 == section) {
                    return _friendRequest.count;
                }else {
                    if (1 == _select) {
                        if (_searchController.active) {
                            return _searchLeftArray.count;
                        }return _leftArray.count;
                    }
                    return 0;
            }
    } else {
        if (2 == section) {
            return _rightArray.count;
        }
        return 0;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([tableView isEqual:_leftTabeleView]) {
        
        if (0 == indexPath.section) {
            FZY_RequestTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:IdentifierLeft];
            cell.fzy = _friendRequest[indexPath.row];
            return cell;
        }else {
            FZY_FriendsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:leftIdentifier];
            if (_searchController.active) {
                cell.nameLabel.text = _searchLeftArray[indexPath.row];
            }
            else {
                cell.nameLabel.text = _leftArray[indexPath.row];
            }
            return cell;
        }
    }
    FZY_GroupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:rightIdentifier];
    cell.nameLabel.text = [NSString stringWithFormat:@"%@", _rightArray[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:_leftTabeleView]) {
        if (0 == indexPath.section) {
            FZY_RequestModel *fzy = _friendRequest[indexPath.row];
            UIAlertController *alert=[UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"是否添加%@为好友?", fzy.aUsername] message:nil preferredStyle:UIAlertControllerStyleAlert];
            //创建一个取消和一个确定按钮
            UIAlertAction *actionCancle=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                EMError *error = [[EMClient sharedClient].contactManager declineInvitationForUsername:[NSString stringWithFormat:@"%@", fzy.aUsername]];
                if (!error) {
                    NSLog(@"拒绝成功");
                    [_friendRequest removeObjectAtIndex:indexPath.row];
                    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
                    [_leftTabeleView reloadData];
                }
            }];
            //因为需要点击确定按钮后改变文字的值，所以需要在确定按钮这个block里面进行相应的操作
            UIAlertAction *actionOk=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                EMError *error = [[EMClient sharedClient].contactManager acceptInvitationForUsername:[NSString stringWithFormat:@"%@", fzy.aUsername]];
                if (!error) {
                    [UIView showMessage:@"添加成功"];
                    [_friendRequest removeObjectAtIndex:indexPath.row];
                    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
//                    [_leftArray addObject:fzy.aUsername];
                    [self getFriendList];
                    [_leftTabeleView reloadData];
                }
            }];
            //将取消和确定按钮添加进弹框控制器
            [alert addAction:actionCancle];
            [alert addAction:actionOk];
            //显示弹框控制器
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            FZY_ChatViewController *chat = [[FZY_ChatViewController alloc] init];
            if (_leftArray.count > 0) {
                chat.friendName = _leftArray[indexPath.row];
                [self.navigationController pushViewController:chat animated:YES];
            }else {
                chat.friendName = _searchLeftArray[indexPath.row];
                [self.navigationController pushViewController:chat animated:YES];
            }
            
        }
    } else {
        if (2 == indexPath.section) {
            NSLog(@"群");
        }
    }
}

#pragma mark - 分区数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([tableView isEqual: _leftTabeleView]) {
        return 2;
    } else {
        return 3;
    }
}

#pragma mark - 改变分区头标题高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

#pragma mark - 自定义的分区头标题: 有图标或需要跳转时用
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *sectionView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 40)];
    
    if ([tableView isEqual: _leftTabeleView]) {
        UIButton *sectionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        sectionButton.frame = sectionView.bounds;
        if (0 == section) {
            [sectionButton setTitle:@"Requests" forState:UIControlStateNormal];
        }else {
            [sectionButton setTitle:@"List" forState:UIControlStateNormal];
            [sectionButton addTarget:self action:@selector(LeftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        sectionButton.backgroundColor = [UIColor colorWithRed:0.15 green:0.15 blue:0.21 alpha:1];
        [sectionButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [sectionView addSubview:sectionButton];
                return sectionView;
    } if ([tableView isEqual: _rightTableView]) {
        UIButton *sectionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        sectionButton.frame = sectionView.bounds;
        if (0 == section) {
            [sectionButton setTitle:@"Create" forState:UIControlStateNormal];
            [sectionButton addTarget:self action:@selector(creatGroupButton:) forControlEvents:UIControlEventTouchUpInside];
        }else if (1 == section) {
            [sectionButton setTitle:@"Requests" forState:UIControlStateNormal];
        } else {
            [sectionButton setTitle:@"List" forState:UIControlStateNormal];
            [sectionButton addTarget:self action:@selector(groupListButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        sectionButton.backgroundColor = [UIColor colorWithRed:0.15 green:0.15 blue:0.21 alpha:1];
        [sectionButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [sectionView addSubview:sectionButton];
        return sectionView;
    }

    return sectionView;
}

-(void)LeftButtonAction:(UIButton *)button {
    if (0 == _select) {
        _select = 1;
    } else {
        _select = 0;
    }
    [_leftTabeleView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - 创建群组
- (void)creatGroupButton:(UIButton *)button {
    FZY_CreateGroupViewController *createGroupVC = [[FZY_CreateGroupViewController alloc] init];
    createGroupVC.delegate = self;
    [self presentViewController:createGroupVC animated:YES completion:nil];
}

#pragma mark - 实现自定义协议
- (void)insertNewGroupToTableViewWithName:(NSString *)groupName description:(NSString *)groupDescription {
    
    [_rightArray addObject:groupName];
    [_rightTableView reloadData];
    
}

#pragma mark - 群组列表
-(void)groupListButtonAction:(UIButton *)button {
    NSLog(@"点击了群组列表");
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    NSString *searchString = _searchController.searchBar.text;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[c] %@", searchString];
    // 清空原数组
    if (nil != _searchLeftArray) {
        [_searchLeftArray removeAllObjects];
    }
    // 筛选数据
    _searchLeftArray = [NSMutableArray arrayWithArray:[_leftArray filteredArrayUsingPredicate:predicate]];
    // 重载 tableView
    [_leftTabeleView reloadData];
    
}

#pragma mark - delete 

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [_leftTabeleView setEditing:editing animated:animated];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _leftTabeleView) {
        NSString *name = _leftArray[indexPath.row];
        // 删除好友
        EMError *error = [[EMClient sharedClient].contactManager deleteContact:name];
        if (!error) {
            NSLog(@"删除成功");
        }
        [_leftArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
    }
   
}

#pragma mark - 重写父类方法传值

- (void)create {
    [super create];
    [self.searchButton  handleControlEvent:UIControlEventTouchUpInside withBlock:^{
        FZY_FriendRequestViewController *friend = [[FZY_FriendRequestViewController alloc] init];
        friend.array = [NSMutableArray arrayWithArray:_leftArray];
        [self presentViewController:friend animated:YES completion:nil];
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
