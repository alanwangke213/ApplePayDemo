//
//  Swag.m
//  ApplePay
//
//  Created by alanwang.dev on 16/2/23.
//  Copyright © 2016年 alanwang.dev. All rights reserved.
//

#import "Swag.h"

@implementation Swag

- (instancetype)initWithImage:(UIImage *)image title:(NSString *)title price:(NSDecimalNumber *)price type:(SwagType)type description:(NSString *)description
{
    if (self = [super init]) {
        self.image = image;
        self.title = title;
        self.price = price;
        self.swagType = type;
        self.productDescription = description;
    }
    return self;
}

- (NSString *)priceString
{
    NSNumberFormatter *priceFormatter = [[NSNumberFormatter alloc] init];
    priceFormatter.minimumFractionDigits = 2;
    priceFormatter.maximumIntegerDigits = 2;
    return [priceFormatter stringFromNumber:_price];
}

@end
