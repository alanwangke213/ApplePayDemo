//
//  ViewController.m
//  ApplePay
//
//  Created by alanwang.dev on 16/2/18.
//  Copyright © 2016年 alanwang.dev. All rights reserved.
//

#import "PaymentViewController.h"
#import <PassKit/PassKit.h>
#import "ShippingMethod.h"
#import <Stripe.h>
#define ApplePaySwagMerchantID @"merchant.com.LeshiUGC.Test"

#pragma mark - Address
/**
 *  @brief ShippingAddress
 */
//@interface Address : NSObject
//@property (nonatomic, copy) NSString *Street;
//@property (nonatomic, copy) NSString *City;
//@property (nonatomic, copy) NSString *State;
//@property (nonatomic, copy) NSString *Zip;
//@property (nonatomic, copy) NSString *FirstName;
//@property (nonatomic, copy) NSString *LastName;
//@end

#pragma mark - viewController
@interface PaymentViewController ()<PKPaymentAuthorizationViewControllerDelegate>

// 支持的支付代理机构或网关
@property (nonatomic, strong) NSArray *supportedPaymentNetworks;
// ShippingMethod模型数组
@property (nonatomic, strong) NSArray <ShippingMethod *>*shipMethods;
// 授权控制器的ShippingMethods数组
@property (nonatomic, strong) NSArray <PKShippingMethod *>*shippingMethods;
// 待支付商品数组
@property (nonatomic, strong) NSArray <PKPaymentSummaryItem *>*paymentSummaryItems;

@end

@implementation PaymentViewController

- (NSArray *)supportedPaymentNetworks{
    if (!_supportedPaymentNetworks) {
        _supportedPaymentNetworks = [NSArray arrayWithObjects:PKPaymentNetworkVisa,PKPaymentNetworkChinaUnionPay, nil];
    }
    return _supportedPaymentNetworks;
}

- (NSArray<ShippingMethod *> *)shipMethods
{
    if (!_shipMethods) {
        ShippingMethod *method_SF = [[ShippingMethod alloc] initWithPrice:[NSDecimalNumber decimalNumberWithString:@"15.00"] title:@"顺丰快递" description:@"3日内送达"];
        ShippingMethod *method_EMS = [[ShippingMethod alloc] initWithPrice:[NSDecimalNumber decimalNumberWithString:@"20.00"] title:@"EMS" description:@"5日内送达"];
        ShippingMethod *method_XX = [[ShippingMethod alloc] initWithPrice:[NSDecimalNumber decimalNumberWithString:@"10.00"] title:@"xx快递" description:@"x日内送达"];
        _shipMethods = [NSArray arrayWithObjects:method_SF,method_EMS,method_XX, nil];
    }
    return _shipMethods;
}

- (void)setSwag:(Swag *)swag
{
    _swag = swag;
    // 更新界面
    [self configureView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Apple Pay button
    UIButton *applePayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [applePayButton addTarget:self action:@selector(didClickApplePayButton) forControlEvents:UIControlEventTouchUpInside];
    [applePayButton setImage:[UIImage imageNamed:@"applePay_btn"] forState:UIControlStateNormal];
    applePayButton.frame = CGRectMake(0, 0, 150, 50);
    applePayButton.center = CGPointMake(self.view.frame.size.width * 0.5, self.view.frame.size.height * 0.5);
    [self.view addSubview:applePayButton];
    
    // 如果当前设备不支持Apple Pay，则不显示Apple Pay 的支付按钮
    applePayButton.hidden = ![PKPaymentAuthorizationViewController canMakePayments];
#pragma mark - 可扩展 Apple Pay Set Button
    // 如果当前设备不支持提供的支付网络服务进行支付，可现实设置Apple Pay按钮或者不显示
//        applePayButton.hidden = ![PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:self.supportedPaymentNetworks];
    //    UIButton *applePaySetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        applePaySetBtn.hidden = !applePaySetBtn.hidden;

}

// 用语显示商品详情
- (void)configureView{
    //    if (![self isViewLoaded]) {
    //        return;
    //    }
    //    self.title = swag.title;
    //    self.swagPriceLabel.text = "$" + swag.priceString
    //    self.swagImage.image = swag.image
    //    self.swagTitleLabel.text = swag.description
}

/**
 *  @brief 发起支付请求
 */
- (void)didClickApplePayButton
{
    if(![PKPaymentAuthorizationViewController canMakePayments]){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"错误提示" message:@"当前设备不支持Apple Pay!" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:action];
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        
        // 1. 创建 payment rquest
        PKPaymentRequest *request = [[PKPaymentRequest alloc] init];
        
        request.merchantIdentifier = ApplePaySwagMerchantID;
        request.supportedNetworks = self.supportedPaymentNetworks;
        request.merchantCapabilities = PKMerchantCapabilityCredit|PKMerchantCapabilityDebit|PKMerchantCapability3DS|PKMerchantCapabilityEMV;
        request.countryCode = @"CN";
        request.currencyCode = @"CNY";
        
        // 默认为shipping
        request.shippingType = PKShippingTypeShipping;
//        request.applicationData = nil;
        
        // 判断requiredShippingAddressFields
        switch (_swag.swagType) {
            case Delivered:
                request.requiredShippingAddressFields = PKAddressFieldAll;
                break;
            case Electronic:
                request.requiredShippingAddressFields = PKAddressFieldEmail;
                break;
        }
        
        // request 的 shippingMethods数组
        NSMutableArray <PKShippingMethod *>*shippingMethods = [NSMutableArray array];
        switch (_swag.swagType) {
            case Delivered:
                for (ShippingMethod *shippingMethod in self.shipMethods) {
                    PKShippingMethod *method = [[PKShippingMethod alloc] init];
                    method.label = shippingMethod.title;
                    method.amount = shippingMethod.price;
                    method.identifier = shippingMethod.title;
                    method.detail = shippingMethod.methodDescription;
                    //                    [shippingMethods arrayByAddingObject:method];
                    [shippingMethods addObject:method];
                }
                _shippingMethods = shippingMethods;
                request.shippingMethods = shippingMethods;
                break;
            case Electronic:
                break;
        }
        
        // 设置paymentSummaryItem数组
        _paymentSummaryItems = [self calculateSummaryItemsFromSwag:_swag withShippingMethod:self.shippingMethods.firstObject];
        request.paymentSummaryItems = _paymentSummaryItems;
        
        // 以下为可选信息
        //        // 付款联系人
        //        PKContact *billingContact = [[PKContact alloc] init];
        //        NSPersonNameComponents *billingPerson = [[NSPersonNameComponents alloc] init];
        //        billingPerson.nickname = @"Alan";
        //        billingPerson.familyName = @"王";
        //        billingContact.name = billingPerson;
        //        request.billingContact = billingContact;
        //
        //        // 收货联系人
        // 收货人联系方式 默认 会获取银行卡的留存电话.可以自行修改
        //        PKContact *shippingContact = [[PKContact alloc] init];
        //
        //        // 收货地址
        //        CNMutablePostalAddress *postalAddress = [[CNMutablePostalAddress alloc] init];
        //        postalAddress.street = @"朝阳区朝阳公园南路";
        //        postalAddress.city = @"北京市";
        //        postalAddress.state = @"北京市";
        //        postalAddress.postalCode = @"100000";
        //        postalAddress.country = @"中国";
        //        postalAddress.ISOCountryCode = @"CN";
        //        shippingContact.postalAddress = postalAddress;
        //
        //        // 收货人信息
        //        NSPersonNameComponents *shippingPerson = [[NSPersonNameComponents alloc] init];
        //        shippingPerson.namePrefix = @"Mr.";
        //        shippingPerson.givenName = @"KeCheng";
        //        shippingPerson.middleName = nil;
        //        shippingPerson.nameSuffix = nil;
        //        shippingPerson.phoneticRepresentation = nil;
        //        shippingPerson.familyName = @"King";
        //        shippingPerson.nickname = @"PrAerr";
        //        shippingContact.name = shippingPerson;
        //
        //        request.shippingContact = shippingContact;
        
        // 授权控制权
        PKPaymentAuthorizationViewController *paymentVC = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
        paymentVC.delegate = self;
        [self presentViewController:paymentVC animated:YES completion:nil];
        
        /* --------PKPaymentToken-------- */
        //        PKPaymentToken *token = [[PKPaymentToken alloc] init];
        //        if ([token respondsToSelector:@selector(setTransactionIdentifier:)]) {
        //            NSString *uuid = [[NSUUID UUID] UUIDString];
        //            uuid = [uuid stringByReplacingOccurrencesOfString:@"~" withString:@"" options:0 range:NSMakeRange(0, uuid.length)];
        //            NSString *number = @"123112233";
        //            PKPaymentSummaryItem *lastSummaryItem = [self.paymentSummaryItems lastObject];
        //            NSDecimalNumber *amount = lastSummaryItem.amount;
        //            NSString *cents = [@([[amount decimalNumberByMultiplyingByPowerOf10:2] integerValue]) stringValue];
        //            NSString *currency = request.currencyCode;
        //            NSString *identifier = [@[@"LeEcoApplePayStubs", number, cents, currency, uuid] componentsJoinedByString:@"~"];
        //
        //            [token performSelector:@selector(setTransactionIdentifier:) withObject:identifier];
        //
        //        }
        /* --------PKPaymentToken-------- */
        
    }
    
    
}

#pragma mark - 此处还需扩展Address
/**
 *  将ABRecord 信息存储到 Address 结构体中.
 */
//func createShippingAddressFromRef(address: ABRecord!) -> Address {
//    var shippingAddress: Address = Address()
//    
//    shippingAddress.FirstName = ABRecordCopyValue(address, kABPersonFirstNameProperty)?.takeRetainedValue() as? String
//    shippingAddress.LastName = ABRecordCopyValue(address, kABPersonLastNameProperty)?.takeRetainedValue() as? String
//    
//    let addressProperty : ABMultiValueRef = ABRecordCopyValue(address, kABPersonAddressProperty).takeUnretainedValue() as ABMultiValueRef
//    if let dict : NSDictionary = ABMultiValueCopyValueAtIndex(addressProperty, 0).takeUnretainedValue() as? NSDictionary {
//        shippingAddress.Street = dict[String(kABPersonAddressStreetKey)] as? String
//        shippingAddress.City = dict[String(kABPersonAddressCityKey)] as? String
//        shippingAddress.State = dict[String(kABPersonAddressStateKey)] as? String
//        shippingAddress.Zip = dict[String(kABPersonAddressZIPKey)] as? String
//    }
//    
//    return shippingAddress
//}

/**
 *  @brief 计算summaryItems
 *  @param swag 商品信息
 */
- (NSMutableArray *)calculateSummaryItemsFromSwag:(Swag *)swag withShippingMethod:(PKShippingMethod *)shippingMethod{
    NSMutableArray *summaryItems = [NSMutableArray array];
    
    // 商品item
    PKPaymentSummaryItem *item_product = [PKPaymentSummaryItem summaryItemWithLabel:swag.title amount:swag.price];
    [summaryItems addObject:item_product];
    // 邮寄item
    if (shippingMethod) {
        // 邮寄方式才拼接邮寄item
        if (swag.swagType == Delivered) {
            [summaryItems addObject:shippingMethod];
        }
    }
    
    // 商家item
    PKPaymentSummaryItem *item_merchant = [PKPaymentSummaryItem summaryItemWithLabel:@"乐视UGC" amount:[self totalPriceWithShippingMethod:shippingMethod]];
    [summaryItems addObject:item_merchant];
    
    return summaryItems;
}

- (NSDecimalNumber *)totalPriceWithShippingMethod:(PKShippingMethod *)shippingMethod
{
    NSDecimalNumber *amount = _swag.price;
    
    if (_swag.swagType == Delivered) {
        if (!shippingMethod) {
            amount = [amount decimalNumberByAdding:self.shippingMethods.firstObject.amount];
        }else{
            amount = [amount decimalNumberByAdding:shippingMethod.amount];
        }
    }
    
    return amount;
}

#pragma mark - PKPaymentAuthorizationViewControllerDelegate

/**
 *  @brief 即将授权前调用
 */
- (void)paymentAuthorizationViewControllerWillAuthorizePayment:(PKPaymentAuthorizationViewController *)controller
{
    NSLog(@"---WillAuthorize--->");
}

/**
 *  @brief 完成授权
 *  @param payment    支付信息(包括付款人信息，邮寄地址，收货人信息等)
 *  @param completion 授权完成后的回调
 */
- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus))completion
{
    completion(PKPaymentAuthorizationStatusSuccess);
#pragma mark - 此处需要进行后续处理
#warning - 需要集成银联SDK或其它官方支持的第三方SDK以及调用后台接口，并配合后台进行购物信息保留
    
    [Stripe setDefaultPublishableKey:@"pk_test_Ga4uBUFMnPUohi68z4a93mxg"];
    //  使用Stripe的SDK的Swift测试代码
    
    [[STPAPIClient sharedClient] createTokenWithPayment:payment completion:^(STPToken * _Nullable token, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"%@",error);
            completion(PKPaymentAuthorizationStatusFailure);
            return;
        }
        
        [self createBackendChargeWithToken:token completion:completion];
    }];
    
    //    let shippingAddress = self.createShippingAddressFromRef(payment.shippingAddress)
    //    // 2
    //    Stripe.setDefaultPublishableKey("pk_test_Ga4uBUFMnPUohi68z4a93mxg")  // Replace With Your Own Key!
    //    // 3
    //    STPAPIClient.sharedClient().createTokenWithPayment(payment) {
    //        (token, error) -> Void in
    //
    //        if (error != nil) {
    //            print(error)
    //            completion(PKPaymentAuthorizationStatus.Failure)
    //            return
    //        }
    //
    //        // 4
    //        let shippingAddress = self.createShippingAddressFromRef(payment.shippingAddress)
    //
    //        // 5
    //        let url = NSURL(string: "http://10.58.187.66/pay")  // Replace with computers local IP Address!
    //        let request = NSMutableURLRequest(URL: url!)
    //        request.HTTPMethod = "POST"
    //        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    //        request.setValue("application/json", forHTTPHeaderField: "Accept")
    //
    //        // 6
    //        let body = ["stripeToken": token!.tokenId,
    //                    "amount": self.swag!.total().decimalNumberByMultiplyingBy(NSDecimalNumber(string: "100")),
    //                    "description": self.swag!.title,
    //                    "shipping": [
    //                                 "city": shippingAddress.City!,
    //                                 "state": shippingAddress.State!,
    //                                 "zip": shippingAddress.Zip!,
    //                                 "firstName": shippingAddress.FirstName!,
    //                                 "lastName": shippingAddress.LastName!]
    //                    ]
    //
    //        var error: NSError?
    //
    //        request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(body, options: NSJSONWritingOptions())
    //
    //        // 7
    //        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
    //            if (error != nil) {
    //                completion(PKPaymentAuthorizationStatus.Failure)
    //            } else {
    //                completion(PKPaymentAuthorizationStatus.Success)
    //            }
    //        }
    //    }
}

/**
 *  @brief 取消授权
 */
- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller
{
    NSLog(@"DidFinish -->");
    [controller dismissViewControllerAnimated:YES completion:nil];
}

/**
 *  @brief 选择支付方式代理
 *
 *  @param paymentMethod 支付方式信息
 *  @param completion    完成回调
 */
- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller didSelectPaymentMethod:(PKPaymentMethod *)paymentMethod completion:(void (^)(NSArray<PKPaymentSummaryItem *> * _Nonnull))completion
{
    NSString *paymentType;
    switch (paymentMethod.type) {
        case PKPaymentMethodTypeUnknown:
            paymentType = @"未知方式";
            break;
        case PKPaymentMethodTypeDebit:
            paymentType = @"借记卡";
            break;
        case PKPaymentMethodTypeCredit:
            paymentType = @"信用卡";
            break;
        case PKPaymentMethodTypePrepaid:
            paymentType = @"预付卡";
            break;
        case PKPaymentMethodTypeStore:
            paymentType = @"Store方式";
            break;
        default:
            break;
    }
    // 网络内购部分数据会为nil
    NSLog(@"当前网络:%@,支付方式:%@,支付卡号:%@",paymentMethod.network,paymentType,paymentMethod.displayName);
    NSLog(@"%@",paymentMethod.paymentPass);
    completion(self.paymentSummaryItems);
}

/**
 *  @brief 选择邮寄方式
 *
 *  @param shippingMethod 邮寄方式
 *  @param completion     完成回调
 */
-(void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller didSelectShippingMethod:(PKShippingMethod *)shippingMethod completion:(void (^)(PKPaymentAuthorizationStatus, NSArray<PKPaymentSummaryItem *> * _Nonnull))completion
{
    // 选择快递方式后需回调处理新的paymentSummaryItems数组
    completion(PKPaymentAuthorizationStatusSuccess,[self calculateSummaryItemsFromSwag:_swag withShippingMethod:shippingMethod]);
}

/**
 *  @brief 选择联系人信息
 *
 *  @param contact    联系人
 *  @param completion 完成回调
 */
- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller didSelectShippingContact:(PKContact *)contact completion:(void (^)(PKPaymentAuthorizationStatus, NSArray<PKShippingMethod *> * _Nonnull, NSArray<PKPaymentSummaryItem *> * _Nonnull))completion
{
    NSLog(@"选择shipping contact : %@",contact.name);
    completion(PKPaymentAuthorizationStatusSuccess,_shippingMethods,self.paymentSummaryItems);
}

#pragma mark -
// 将token发送给服务器
- (void)createBackendChargeWithToken:(STPToken *)token
                          completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    NSURL *url = [NSURL URLWithString:@"http://192.168.1.36/pay"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    NSString *body     = [NSString stringWithFormat:@"stripeToken=%@", token.tokenId];
    request.HTTPBody   = [body dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURLSessionDataTask *task =
    [session dataTaskWithRequest:request
               completionHandler:^(NSData *data,
                                   NSURLResponse *response,
                                   NSError *error) {
                   if (error) {
                       completion(PKPaymentAuthorizationStatusFailure);
                   } else {
                       completion(PKPaymentAuthorizationStatusSuccess);
                   }
               }];
    [task resume];
}
@end

