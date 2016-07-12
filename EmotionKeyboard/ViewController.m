//
//  ViewController.m
//  EmotionKeyboard
//
//  Created by CoderXu on 16/7/12.
//  Copyright © 2016年 CoderXu. All rights reserved.
//

#import "ViewController.h"
#import "GrowingInputView.h"
#import <TYAttributedLabel.h>
#import "RegexKitLite.h"
#import "AutoLayoutAttributedLabelCell.h"
static NSString *cellId = @"AutoLayoutAttributedLabelCell";
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,GrowingInputViewDelegate,TYAttributedLabelDelegate>
{
    GrowingInputView *_growingInputView;//输入框
    BOOL _showKeyBoard;
    NSInteger _keyboardHeight;
    BOOL _keyboardVisible;
    
    BOOL _canResetGrowingInputView;
}
@property (weak, nonatomic) IBOutlet UITableView *msgTableView;
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
    
    [self showGrowingInputView];
    [self.msgTableView registerClass:[AutoLayoutAttributedLabelCell class] forCellReuseIdentifier:cellId];
    self.msgTableView.estimatedRowHeight = 20;
    self.msgTableView.rowHeight = UITableViewAutomaticDimension;
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
#pragma 消息source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.msgList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    AutoLayoutAttributedLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    
    // Configure the cell...
    cell.label.delegate = self;
    
    NSString *message=self.msgList[indexPath.row];
    
    cell.label.textContainer = [self creatTextContainerByMessage:message]; //
    
    [cell.label setBackgroundColor:[UIColor clearColor]];
    // 如果是直接赋值textContainer ，可以不用设置preferredMaxLayoutWidth，因为创建textContainer时，必须传正确的textwidth，即 preferredMaxLayoutWidth
    cell.label.preferredMaxLayoutWidth = CGRectGetWidth(tableView.frame);
    [ cell setBackgroundColor:[UIColor clearColor]];
    [[cell contentView] setBackgroundColor:[UIColor clearColor]];
    return cell;
    
}
#pragma 消息delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice].systemVersion doubleValue] >= 8.0) {
        return UITableViewAutomaticDimension;
    }
    //计算高度
    NSString *message = self.msgList[indexPath.row];
    TYTextContainer *textContaner = [self creatTextContainerByMessage:message] ;
    return textContaner.textHeight+8;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //单击退键盘
    [self.view endEditing:YES];
}
//滚动到底部
-(void)scrollviewToEnd{
    NSUInteger rowCount = [self.msgTableView numberOfSections];
    
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:rowCount-1];
    
    [self.msgTableView scrollToRowAtIndexPath:indexPath
     
                             atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}
#pragma mark 消息聊天部分
#pragma mark 消息窗体部分
- (TYTextContainer *)creatTextContainerByMessage:(NSString *)message {
    //     属性文本生成器
    TYTextContainer *textContainer = [[TYTextContainer alloc]init];
    textContainer.text = message;
    NSMutableArray *tmpArray = [NSMutableArray array];
    
    // 正则匹配图片信息
    [message enumerateStringsMatchedByRegex:@"\\[(emoji_\\d+?)\\]" usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        
        if (captureCount > 1) {
            // 图片信息储存
            TYImageStorage *imageStorage = [[TYImageStorage alloc]init];
            imageStorage.cacheImageOnMemory = YES;
            imageStorage.imageName = capturedStrings[1];
            imageStorage.range = capturedRanges[0];
            imageStorage.size = CGSizeMake(25, 25);
            
            [tmpArray addObject:imageStorage];
        }
    }];
    
    // 添加图片信息数组到label
    [textContainer addTextStorageArray:tmpArray];
    //文本中的"haha"则变红
    NSRange range = [message rangeOfString:@"haha"];
    TYTextStorage *textStorage = [[TYTextStorage alloc]init];
    textStorage.range = range;
    textStorage.textColor = [UIColor redColor];
    textStorage.font = [UIFont systemFontOfSize:16 weight:10];
    
    [textContainer addTextStorage:textStorage];
    textContainer.linesSpacing = 2;
    
    return textContainer;
}

#pragma mark - TYAttributedLabelDelegate
- (void)attributedLabel:(TYAttributedLabel *)attributedLabel textStorageClicked:(id<TYTextStorageProtocol>)TextRun atPoint:(CGPoint)point
{
    NSLog(@"textStorageClickedAtPoint");
    if ([TextRun isKindOfClass:[TYLinkTextStorage class]]) {
        
        id linkStr = ((TYLinkTextStorage*)TextRun).linkData;
        if ([linkStr isKindOfClass:[NSString class]]) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"点击提示" message:linkStr delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
        }
    }else if ([TextRun isKindOfClass:[TYImageStorage class]]) {
        TYImageStorage *imageStorage = (TYImageStorage *)TextRun;
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"点击提示" message:[NSString stringWithFormat:@"你点击了%@图片",imageStorage.imageName] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }
}


#pragma mark - QDGrowingInputView输入框代理
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
    
    [self.msgTableView reloadData];
    [self scrollviewToEnd];
    
    
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
