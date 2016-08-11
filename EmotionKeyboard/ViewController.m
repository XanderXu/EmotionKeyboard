//
//  ViewController.m
//  EmotionKeyboard
//
//  Created by CoderXu on 16/7/12.
//  Copyright © 2016年 CoderXu. All rights reserved.
//

#import "ViewController.h"
#import "GrowingInputView.h"

#import "MessageTableViewController.h"



@interface ViewController ()<GrowingInputViewDelegate>
{
    GrowingInputView *_growingInputView;//输入框
    BOOL _showKeyBoard;
    NSInteger _keyboardHeight;
    BOOL _keyboardVisible;
    
    BOOL _canResetGrowingInputView;
}
@property(nonatomic,strong) MessageTableViewController *messageVC;
@property(nonatomic, strong) NSMutableArray *msgList;

@end

@implementation ViewController

-(NSMutableArray *)msgList {
    if (_msgList == nil) {
        _msgList = [NSMutableArray array];
    }
    return _msgList;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.messageVC = [[MessageTableViewController alloc] init];
    [self.view addSubview:self.messageVC.tableView];
    self.messageVC.tableView.frame = CGRectMake(10, 20, self.view.bounds.size.width - 20, 300);
    
    
    self.messageVC.msgList = self.msgList;

    //加载输入框
    [self showGrowingInputView];
}
//输入框
-(void)showGrowingInputView {
    if (_growingInputView == nil) {
        _growingInputView = [[GrowingInputView alloc] initWithFrame:CGRectZero];
        _growingInputView.frame = CGRectMake(0, self.view.frame.size.height - [GrowingInputView defaultHeight], self.view.frame.size.width, [GrowingInputView defaultHeight]);
        _growingInputView.placeholder = @"我来说点什么吧~";
        _growingInputView.delegate = self;
        _growingInputView.parentView = self.view;
        
        
        [self.view addSubview:_growingInputView];
    }
    _growingInputView.hidden = NO;
    //让组件内部的textView成为第一响应者
    [_growingInputView activateInput];
    
    //添加点击空白处退键盘
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backViewTap)];
    [self.view addGestureRecognizer:tap];
}
- (void)backViewTap {
    [self.view endEditing:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - GrowingInputView输入框代理
//输入框改变高度
- (void)growingInputView:(GrowingInputView *)growingInputView didChangeHeight:(CGFloat)height keyboardVisible:(BOOL)keyboardVisible
{
    _keyboardVisible = keyboardVisible;
    if (keyboardVisible) {
        _keyboardHeight = height;
        
    } else {
        _keyboardHeight = 0;
    }
}
//输入框结束编辑
- (void)growingTextViewDidEndEditing:(GrowingInputView *)growingInputView
{
    [self resetGrowingInputView];
    _canResetGrowingInputView = YES;
}
//输入框开始编辑
- (BOOL)growingTextViewShouldBeginEditing:(GrowingInputView *)growingInputView
{
    _canResetGrowingInputView = YES;
    return YES;
}
//点击发送按钮
- (BOOL)growingInputView:(GrowingInputView *)growingInputView didSendText:(NSString *)text
{
    
    [self.msgList addObject:text];
    self.messageVC.msgList = self.msgList;
    
    return YES;
    
}
//清空输入框
- (void)resetGrowingInputView
{
    if (_canResetGrowingInputView == YES) {
        _growingInputView.placeholder = @"我来说点什么吧~";
    }
}
//切换Emoji
- (void)growingInputViewEmojiBtnClick:(GrowingInputView *)growingInputView
{
    _canResetGrowingInputView = NO;
}
//隐藏键盘时还要做的事
-(void)growingInputView:(GrowingInputView *)growingInputView didRecognizer:(id)sender {
    
}

@end
