//
//  FZY_LoginOrRegisterViewController.m
//  ColorLetter
//
//  Created by dllo on 16/10/20.
//  Copyright © 2016年 yzy. All rights reserved.
//

#import "FZY_LoginOrRegisterViewController.h"
#import "FZY_MessageViewController.h"
#import "FZYTabBarViewController.h"
#import "DrawerViewController.h"

@interface FZY_LoginOrRegisterViewController ()
<
UIScrollViewDelegate,
UITextFieldDelegate
>

@property (nonatomic, retain) UIView *upView;
@property (nonatomic, retain) UIScrollView *downScrollView;
@property (nonatomic, retain) UIImageView *triangleImageView;
@property (nonatomic, retain) UITextField *accountTextField;
@property (nonatomic, retain) UITextField *passwordTextField;
@property (nonatomic, retain) UITextField *loginAccountTextField;
@property (nonatomic, retain) UITextField *loginPasswordTextField;

@property (nonatomic, strong) UIImageView *leftImageView;
@property (nonatomic, strong) UIImageView *myImageView;
@property (nonatomic, strong) EMError *error;

@end

@implementation FZY_LoginOrRegisterViewController

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
//    [self.delegate dismissViewController];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self creatLoginOrRegisterButton];
    [self creatDownScrollView];
    [self creatLoginView];
    self.triangleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.position, 50, 20, 20)];
    _triangleImageView.image = [UIImage imageNamed:@"zhengsanjiao.png"];
    [self.view bringSubviewToFront:_triangleImageView];
    [self.view addSubview:_triangleImageView];
    
}

#pragma mark - 创建 downScrollView
- (void)creatDownScrollView {
    self.downScrollView  = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _upView.frame.size.height, WIDTH, HEIGHT - _upView.frame.size.height)];
    _downScrollView.backgroundColor = [UIColor colorWithRed:0.15 green:0.15 blue:0.21 alpha:1];
    _downScrollView.contentSize = CGSizeMake(WIDTH * 2, 0);
    _downScrollView.contentOffset = CGPointMake(_scrollPosition, 0);
    _downScrollView.pagingEnabled = YES;
    _downScrollView.delegate = self;
    _downScrollView.bounces = NO;
    _downScrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_downScrollView];
    
    self.leftImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_header"]];
    _leftImageView.userInteractionEnabled = YES;
    [_downScrollView addSubview:_leftImageView];
    [_leftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_downScrollView.mas_left);
        make.top.equalTo(_downScrollView.mas_top);
        make.height.equalTo(@110);
        make.width.equalTo(@(WIDTH));
    }];

    
    self.accountTextField = [[UITextField alloc]init];
//    _accountTextField.keyboardType = UITextAutocapitalizationTypeWords;
    _accountTextField.textColor = [UIColor whiteColor];
    _accountTextField.placeholder = @"  Your New Username";
    [_accountTextField setValue:[UIColor colorWithRed:1 green:1 blue:1 alpha:1.000] forKeyPath:@"placeholderLabel.textColor"];
    _accountTextField.clearButtonMode = UITextFieldViewModeAlways;
    [_downScrollView addSubview:_accountTextField];
    [_accountTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_downScrollView.mas_left).offset(60);
        make.top.equalTo(_downScrollView.mas_top).offset(160);
        make.height.equalTo(@30);
        make.width.equalTo(@(WIDTH - 120));
        
    }];
   
    UIImageView *accountImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
    accountImageView.image = [UIImage imageNamed:@"field-email"];
    _accountTextField.leftViewMode = UITextFieldViewModeAlways;
    _accountTextField.leftView = accountImageView;
    [_accountTextField addSubview:accountImageView];
    
    UIView *accountLineView = [[UIView alloc]init];
    accountLineView.backgroundColor = [UIColor blackColor];
    [_accountTextField addSubview:accountLineView];
    [accountLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_accountTextField).offset(0);
        make.right.equalTo(_accountTextField).offset(0);
        make.top.equalTo(_accountTextField).offset(32);
        make.height.equalTo(@1);
    }];
   
    
    self.passwordTextField = [[UITextField alloc]init];
//    _passwordTextField.keyboardType = UITextAutocapitalizationTypeWords;
    _passwordTextField.delegate = self;
    _passwordTextField.clearButtonMode = UITextFieldViewModeAlways;
    _passwordTextField.secureTextEntry = YES;
    _passwordTextField.textColor = [UIColor whiteColor];
    _passwordTextField.placeholder = @"  New Password";
    [_passwordTextField setValue:[UIColor colorWithRed:1 green:1 blue:1 alpha:1.000] forKeyPath:@"placeholderLabel.textColor"];
    [_downScrollView addSubview:_passwordTextField];
    [_passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_downScrollView.mas_left).offset(60);
        make.top.equalTo(_downScrollView.mas_top).offset(220);
        make.height.equalTo(@30);
        make.width.equalTo(@(WIDTH - 120));

    }];
    
    UIImageView *passwordImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
    passwordImageView.image = [UIImage imageNamed:@"field-lock"];
    _passwordTextField.leftViewMode = UITextFieldViewModeAlways;;
    _passwordTextField.leftView = passwordImageView;
    [_passwordTextField addSubview:passwordImageView];
    
    UIView *passwordLineView = [[UIView alloc]init];
    passwordLineView.backgroundColor = [UIColor blackColor];
    [_passwordTextField addSubview:passwordLineView];
    [passwordLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_passwordTextField).offset(0);
        make.right.equalTo(_passwordTextField).offset(0);
        make.top.equalTo(_passwordTextField).offset(32);
        make.height.equalTo(@1);
        
    }];
    
}

// 隐藏键盘
-(void)resignKeyboard {
    [_passwordTextField resignFirstResponder];
}
#pragma mark - 创建上面的登录注册 Button
- (void)creatLoginOrRegisterButton {
    
    self.upView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 64)];
    
    _upView.backgroundColor = [UIColor colorWithRed:0.32 green:0.78 blue:0.48 alpha:1.0];
    [self.view addSubview:_upView];
    
    // 返回
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setBackgroundImage:[UIImage imageNamed:@"x"] forState:UIControlStateNormal];
    
    //button的 封装的block方法
    [backButton handleControlEvent:UIControlEventTouchUpInside withBlock:^{
        [self dismissViewControllerAnimated:YES completion:nil]; 
    }];
    
    [_upView addSubview:backButton];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_upView.mas_centerY).offset(10);
        make.left.equalTo(_upView).offset(10);
        make.width.equalTo(@20);
        make.height.equalTo(@20);
    }];
    
    
    UIButton *LoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [LoginButton setTitle:@"Log in" forState:UIControlStateNormal];
    [_upView addSubview:LoginButton];
    [LoginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_upView.mas_centerY).offset(10);
        make.centerX.equalTo(self.view.mas_right).offset(- WIDTH / 4 + 10);
        make.width.equalTo(@65);
        make.height.equalTo(@40);
    }];
    
    [LoginButton handleControlEvent:UIControlEventTouchUpInside withBlock:^{
        [_loginPasswordTextField resignFirstResponder];
        [_loginAccountTextField resignFirstResponder];
        [_accountTextField resignFirstResponder];
        [_passwordTextField resignFirstResponder];

        self.downScrollView.contentOffset = CGPointMake(WIDTH, 0);
        
    }];
    
    UIButton *registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [registerButton setTitle:@"Sign up" forState:UIControlStateNormal];
    [_upView addSubview:registerButton];
    [registerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_upView.mas_centerY).offset(10);
        make.centerX.equalTo(self.view.mas_left).offset(WIDTH / 4 + 10);
        make.width.equalTo(@65);
        make.height.equalTo(@40);
    }];
    
    
    [registerButton handleControlEvent:UIControlEventTouchUpInside withBlock:^{
        [_loginPasswordTextField resignFirstResponder];
        [_loginAccountTextField resignFirstResponder];
        [_accountTextField resignFirstResponder];
        [_passwordTextField resignFirstResponder];


        self.downScrollView.contentOffset = CGPointMake(0, 0);
    }];

    
}

#pragma mark - 登录的downScrollView
-(void)creatLoginView {

    
    self.myImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_header"]];
    _myImageView.userInteractionEnabled = YES;
    [_downScrollView addSubview:_myImageView];
    [_myImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_leftImageView.mas_right);
        make.top.equalTo(_downScrollView.mas_top);
        make.height.equalTo(@110);
        make.width.equalTo(@(WIDTH));
    }];
    
    self.loginAccountTextField = [[UITextField alloc]init];
//    _loginAccountTextField.keyboardType = UITextAutocapitalizationTypeWords;
    _loginAccountTextField.clearButtonMode = UITextFieldViewModeAlways;
    _loginAccountTextField.textColor = [UIColor whiteColor];
    _loginAccountTextField.placeholder = @"  Username";
    [_loginAccountTextField setValue:[UIColor colorWithRed:1 green:1 blue:1 alpha:1.000] forKeyPath:@"placeholderLabel.textColor"];
    [_downScrollView addSubview:_loginAccountTextField];
    [_loginAccountTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_downScrollView.mas_left).offset(WIDTH + 60);
        make.top.equalTo(_downScrollView.mas_top).offset(160);
        make.height.equalTo(@30);
        make.width.equalTo(@(WIDTH - 120));
        
    }];
    
    UIImageView *accountImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
    accountImageView.image = [UIImage imageNamed:@"field-email"];
    _loginAccountTextField.leftViewMode = UITextFieldViewModeAlways;
    _loginAccountTextField.leftView = accountImageView;
    [_loginAccountTextField addSubview:accountImageView];
    
    UIView *accountLineView = [[UIView alloc]init];
    accountLineView.backgroundColor = [UIColor blackColor];
    [_loginAccountTextField addSubview:accountLineView];
    [accountLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_loginAccountTextField).offset(0);
        make.right.equalTo(_loginAccountTextField).offset(0);
        make.top.equalTo(_loginAccountTextField).offset(32);
        make.height.equalTo(@1);
    }];
    
    
   self.loginPasswordTextField = [[UITextField alloc]init];
//    _loginPasswordTextField.keyboardType = UITextAutocapitalizationTypeWords;
    _loginPasswordTextField.delegate = self;
    _loginPasswordTextField.clearButtonMode = UITextFieldViewModeAlways;
    _loginPasswordTextField.secureTextEntry = YES;
    _loginPasswordTextField.textColor = [UIColor whiteColor];
    _loginPasswordTextField.placeholder = @"  Password";
    [_loginPasswordTextField setValue:[UIColor colorWithRed:1 green:1 blue:1 alpha:1.000] forKeyPath:@"placeholderLabel.textColor"];
    [_downScrollView addSubview:_loginPasswordTextField];
    [_loginPasswordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_downScrollView.mas_left).offset(WIDTH + 60);
        make.top.equalTo(_downScrollView.mas_top).offset(220);
        make.height.equalTo(@30);
        make.width.equalTo(@(WIDTH - 120));
        
    }];
    
    UIImageView *passwordImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
    passwordImageView.image = [UIImage imageNamed:@"field-lock"];
    _loginPasswordTextField.leftViewMode = UITextFieldViewModeAlways;;
    _loginPasswordTextField.leftView = passwordImageView;
    [_loginPasswordTextField addSubview:passwordImageView];
    
    UIView *passwordLineView = [[UIView alloc]init];
    passwordLineView.backgroundColor = [UIColor blackColor];
    [_loginPasswordTextField addSubview:passwordLineView];
    [passwordLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_loginPasswordTextField).offset(0);
        make.right.equalTo(_loginPasswordTextField).offset(0);
        make.top.equalTo(_loginPasswordTextField).offset(32);
        make.height.equalTo(@1);
        
    }];
    
  
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat value = scrollView.contentOffset.x;
    
    _upView.backgroundColor = [UIColor colorWithRed:0.32 + value / (WIDTH * 2) green:0.78 blue:0.48 - (WIDTH * 2) / value alpha:1.0];

    
    if (self.position == WIDTH / 4 * 3) {
        
        value = value - WIDTH;
        
        [UIView animateWithDuration:0.1 animations:^{
            _triangleImageView.transform = CGAffineTransformMakeTranslation(value / 2, 0);
        }];
    } else {
        [UIView animateWithDuration:0.1 animations:^{
            _triangleImageView.transform = CGAffineTransformMakeTranslation(value / 2, 0);
        }];
    }
    
}

// 开始编辑
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if ([textField isEqual:_passwordTextField]) {
        _leftImageView.image = [UIImage imageNamed:@"login_header_cover_eyes"];
    }else if ([textField isEqual:_loginPasswordTextField]) {
        _myImageView.image = [UIImage imageNamed:@"login_header_cover_eyes"];
    }else if ([textField isEqual:_loginAccountTextField]) {
         _myImageView.image = [UIImage imageNamed:@"login_header"];
    }else {
        _leftImageView.image = [UIImage imageNamed:@"login_header"];

    }
    return YES;
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
        _leftImageView.image = [UIImage imageNamed:@"login_header"];
    _myImageView.image = [UIImage imageNamed:@"login_header"];
    
}

// 点击return
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:_passwordTextField]) {
        EMError *error = [[EMClient sharedClient] registerWithUsername:_accountTextField.text password:_passwordTextField.text];
#pragma mark - 注册
        if (error == nil) {
            [TSMessage showNotificationWithTitle:@"Success" subtitle:@"注册成功" type:TSMessageNotificationTypeSuccess];
            [_passwordTextField resignFirstResponder];
            self.loginAccountTextField.text = _accountTextField.text;
            self.loginPasswordTextField.text = _passwordTextField.text;
            self.downScrollView.contentOffset = CGPointMake(WIDTH, 0);

        }else {
            [TSMessage showNotificationWithTitle:@"Error" subtitle:@"注册失败" type:TSMessageNotificationTypeError];

        }
        
    }else if ([textField isEqual:_loginPasswordTextField]) {
        _error = [[EMClient sharedClient] loginWithUsername:_loginAccountTextField.text password:_loginPasswordTextField.text];
        
#pragma mark - 登录
        if (!_error) {
            AVQuery *userPhoto = [AVQuery queryWithClassName:@"userAvatar"];
            [userPhoto findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    [[FZY_DataHandle shareDatahandle] open];
                    [[FZY_DataHandle shareDatahandle] deleteAll];
                    for (AVObject *userPhoto in objects) {
                        AVObject *user = [userPhoto objectForKey:@"userName"];
                        FZY_User *use = [[FZY_User alloc] init];
                        AVFile *file = [userPhoto objectForKey:@"image"];
                        use.name = [NSString stringWithFormat:@"%@", user];
                        use.imageUrl = file.url;
                        use.userId = userPhoto.objectId;
                        [[FZY_DataHandle shareDatahandle] insert:use];
                    }
                }
            }];
            [TSMessage showNotificationWithTitle:@"Success" subtitle:@"登录成功" type:TSMessageNotificationTypeSuccess];
            [_loginPasswordTextField endEditing:YES];
            [self dismissViewControllerAnimated:NO completion:^{
                [_VC dismissViewControllerAnimated:YES completion:nil];
            }];

            
            if (!_error) {
                [[EMClient sharedClient].options setIsAutoLogin:YES];
            }
            
            self.view.window.rootViewController = [[FZYTabBarViewController alloc] init];
                        
        }else {
            [TSMessage showNotificationWithTitle:@"Error" subtitle:@"登录失败" type:TSMessageNotificationTypeError];
        }
        
    }
   
    return YES;
    
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
