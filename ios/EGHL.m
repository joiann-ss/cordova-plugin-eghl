#import "EGHL.h"
#import "EGHLPayViewController.h"


#pragma mark - "Private" variables

@interface EGHL ()

@property Boolean paymentInProgress;
@property UIViewController *contentViewController;
@property CDVInvokedUrlCommand* command;
@property NSArray *eGHLStringParams;

@end


#pragma mark - Implementation

@implementation EGHL

@synthesize paymentInProgress;
@synthesize contentViewController;
@synthesize command;
@synthesize eGHLStringParams;


#pragma mark - Plugin API

- (void)pluginInitialize
{
    if(self.eGHLStringParams == nil) {
        self.eGHLStringParams = @[
            @"Amount",
            @"PaymentID",
            @"OrderNumber",
            @"MerchantName",
            @"ServiceID",
            @"PymtMethod",
            @"MerchantReturnURL",
            @"CustEmail",
            @"Password",
            @"CustPhone",
            @"CurrencyCode",
            @"CustName",
            @"LanguageCode",
            @"PaymentDesc",
            @"PageTimeout",
            @"CustIP",
            @"MerchantApprovalURL",
            @"CustMAC",
            @"MerchantUnApprovalURL",
            @"CardHolder",
            @"CardNo",
            @"CardExp",
            @"CardCVV2",
            @"BillAddr",
            @"BillPostal",
            @"BillCity",
            @"BillRegion",
            @"BillCountry",
            @"ShipAddr",
            @"ShipPostal",
            @"ShipCity",
            @"ShipRegion",
            @"ShipCountry",
            @"TokenType",
            @"Token",
            @"SessionID",
            @"IssuingBank",
            @"MerchantCallBackURL",
            @"B4TaxAmt",
            @"TaxAmt",
            @"Param6",
            @"Param7"
        ];
    }
}

- (void)makePayment: (CDVInvokedUrlCommand*)command
{
    if(self.paymentInProgress) {
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"A payment is already in progress."]
                              callbackId:[command callbackId]];
        return;
    }

    NSDictionary *args = (NSDictionary*) [command argumentAtIndex:0 withDefault:nil andClass:[NSDictionary class]];
    if(args == nil) {
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Argument must be an object."]
                              callbackId:[command callbackId]];
        return;
    }

    self.paymentInProgress = YES;
    self.command = command;

    PaymentRequestPARAM *payParams = [[PaymentRequestPARAM alloc] init];
    payParams.RealHost = [args objectForKey:@"RealHost"]; // Can't check BOOL for nil, so we always have to set this param...
    for(NSString *paramName in self.eGHLStringParams) {
        NSString *paramValue = [args objectForKey:paramName];
        if(paramValue != nil) {
            [payParams setValue:paramValue forKey:paramName];
        }
    }

    EGHLPayViewController *payViewController =
        [[EGHLPayViewController alloc] initWithEGHLPlugin:self
                                       andPayment:payParams];
    self.contentViewController = [[UINavigationController alloc] initWithRootViewController:payViewController];
    [self.viewController presentViewController:self.contentViewController
                         animated:YES
                         completion:^(void){}];
}


#pragma mark - Return to JS methods

- (void)endPaymentWithStatus: (PaymentStatus)status
{
    [self dismissContentView];

    // TODO return meaningful value to JS
    switch(status) {
        case PAYMENT_SUCCESSFUL:
            break;
        case PAYMENT_FAILED:
            // [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:errorData]
            //                                 callbackId:[self.command callbackId]];
            break;
        case PAYMENT_CANCELLED:
            break;
    }
}

- (void)endPaymentWithFailureMessage: (NSString*)message
{
    [self dismissContentView];

    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:message]
                          callbackId:[self.command callbackId]];
}

- (void)endPaymentWithCancellation
{
    [self dismissContentView];

    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"cancelled"]
                          callbackId:[self.command callbackId]];
}


#pragma mark - Internal helpers

- (void)dismissContentView
{
    [self.viewController dismissViewControllerAnimated:YES
                         completion:^(void){}];
}

@end
