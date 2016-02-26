//
//  SwagListViewController.m
//  ApplePay
//
//  Created by alanwang.dev on 16/2/23.
//  Copyright © 2016年 alanwang.dev. All rights reserved.
//

#import "SwagListViewController.h"
#import "PaymentViewController.h"
#import "SwagCell.h"

#define kSwagListViewCell @"kSwagListViewCell"

@interface SwagListViewController ()
@property (nonatomic, copy) NSArray *swagList;
@end

@implementation SwagListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    Swag *swag_iGT = [[Swag alloc] initWithImage:[UIImage imageNamed:@"iGT"] title:@"iOS Games by Tutorials" price:[NSDecimalNumber decimalNumberWithString:@"45.00"] type:Electronic description:@"This book is for beginner to advanced iOS developers. Whether you are a complete beginner to making iOS games, or an advanced iOS developer looking to learn about Sprite Kit, you will learn a lot from this book!"];
    
    Swag *swag_Tshirt = [[Swag alloc] initWithImage:[UIImage imageNamed:@"T-shirt"] title:@"T-shirt" price:[NSDecimalNumber decimalNumberWithString:@"199.00"] type:Delivered description:@"Sport a stylish black t-shirt with a colorful mosaic iPhone design!"];
    self.swagList = @[swag_iGT,swag_Tshirt];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return self.swagList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SwagCell *cell = [tableView dequeueReusableCellWithIdentifier:kSwagListViewCell forIndexPath:indexPath];
    
    Swag *swag = self.swagList[indexPath.row];
    
    cell.titleLabel.text = swag.title;
    cell.priceLabel.text = [NSString stringWithFormat:@"$%@",swag.priceString];
    cell.swagImage.image = swag.image;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PaymentViewController *paymentVC = [[PaymentViewController alloc] init];
    paymentVC.swag = self.swagList[indexPath.row];
    [self.navigationController pushViewController:paymentVC animated:YES];
}

@end
