//
//  SUTextMarkView.m
//  PixelHunter
//
//  Created by Alex Saenko on 10/22/13.
//  Copyright (c) 2013 Sigma Ukraine. All rights reserved.
//

#import "SUTextMarkView.h"
#import "SUConstants.h"

static NSString * const kSUPlaceHolderText = @"Type your text here...";

@interface SUTextMarkView () <UITextViewDelegate>

@property (nonatomic, assign) CGSize keyboardSize;
@property (nonatomic, assign) BOOL isKeyboardShown;

@end


@implementation SUTextMarkView

- (id)initWithFrame:(CGRect)frame withView:(UIView *)view
{
    self = [super initWithFrame:frame withView:view];
    if (self) {
        self.autoresizesSubviews = YES;
        
        // Init comment text view
        self.commentTextView = [[UITextView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
        self.commentTextView.text = kSUPlaceHolderText;
        self.commentTextView.textColor = [UIColor colorWithWhite:0.7f alpha:1.0f];
        self.commentTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.commentTextView.layer.cornerRadius = kSUCornerRadius;
        [self.commentTextView setReturnKeyType: UIReturnKeyDone];
        self.commentTextView.delegate = self;
        self.commentTextView.userInteractionEnabled = NO;
        [self addSubview:self.commentTextView];
    }
    
    return self;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:kSUPlaceHolderText]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = kSUPlaceHolderText;
        textView.textColor = [UIColor colorWithWhite:0.7f alpha:1.0f];
    }
    [textView resignFirstResponder];
}

@end
