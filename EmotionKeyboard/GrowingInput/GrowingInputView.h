
#import <UIKit/UIKit.h>

typedef enum _GrowingInputType
{
    GrowingInputType_Text     = 0,
    GrowingInputType_Emoji    = 1,
} GrowingInputType;


@protocol GrowingInputViewDelegate;
@interface GrowingInputView : UIView
/**
 *  父控件
 */
@property (nonatomic, weak) UIView *parentView;
/**
 *  最小行数
 */
@property (nonatomic, assign) NSInteger minNumberOfLines;
/**
 *  内部textView的文本
 */
@property (nonatomic, strong) NSString *text;
/**
 *  占位文字
 */
@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, weak) id <GrowingInputViewDelegate> delegate;
/**
 *  默认高度
  */
+ (CGFloat)defaultHeight;
/**
 *  激活键盘
 */
- (void)activateInput;
/**
 *  退键盘
 */
- (void)deactivateInput;

@end


@protocol GrowingInputViewDelegate <NSObject>

@optional

- (void)growingInputViewEmojiBtnClick:(GrowingInputView *)growingInputView;

- (BOOL)growingInputView:(GrowingInputView *)growingInputView didSendText:(NSString *)text;
- (void)growingInputView:(GrowingInputView *)growingInputView didChangeHeight:(CGFloat)height keyboardVisible:(BOOL)keyboardVisible;


- (BOOL)growingTextViewShouldBeginEditing:(GrowingInputView *)growingInputView;
- (void)growingInputView:(GrowingInputView *)growingInputView didRecognizer:(id)sender;

- (void)growingWillShow:(GrowingInputView *)growingInputView;
- (void)growingWillHide:(GrowingInputView *)growingInputView;
- (void)growingDidHide:(GrowingInputView *)growingInputView;
- (void)growingTextViewDidEndEditing:(GrowingInputView *)growingInputView;
@end

