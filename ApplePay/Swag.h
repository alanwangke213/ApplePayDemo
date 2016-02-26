//
//  Swag.h
//  ApplePay
//
//  Created by alanwang.dev on 16/2/23.
//  Copyright © 2016年 alanwang.dev. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger,SwagType) {
    Delivered,
    Electronic
};

@interface Swag : NSObject
@property (nonatomic, copy) UIImage *image;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSDecimalNumber *price;
@property (nonatomic, copy) NSString *productDescription;
@property (nonatomic, assign) SwagType swagType;
@property (nonatomic, copy)NSString *priceString;

- (instancetype)initWithImage:(UIImage *)image title:(NSString *)title price:(NSDecimalNumber *)price type:(SwagType)type description:(NSString *)description;
- (NSDecimalNumber *)total;

@end
