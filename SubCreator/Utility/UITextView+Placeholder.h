//
//  UITextView+PlaceHolder.h
//  ABTest
//
//  Created by ripple_k on 2018/9/20.
//  Copyright © 2018 SoapVideo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT double UITextView_PlaceholderVersionNumber;
FOUNDATION_EXPORT const unsigned char UITextView_PlaceholderVersionString[];

@interface UITextView (Placeholder)
    
    @property (nonatomic, readonly) UITextView *placeholderTextView;
    
    @property (nonatomic, strong) IBInspectable NSString *placeholder;
    @property (nonatomic, strong) NSAttributedString *attributedPlaceholder;
    @property (nonatomic, strong) IBInspectable UIColor *placeholderColor;
    
+ (UIColor *)defaultPlaceholderColor;
    
    @end

NS_ASSUME_NONNULL_END


