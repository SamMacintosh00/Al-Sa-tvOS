#import "AlSaViewController.h"
#import <objc/message.h>

static id SendID(id obj, SEL sel) {
    return ((id (*)(id, SEL))objc_msgSend)(obj, sel);
}
static id SendID1(id obj, SEL sel, id arg) {
    return ((id (*)(id, SEL, id))objc_msgSend)(obj, sel, arg);
}
static void SendVoid1(id obj, SEL sel, id arg) {
    ((void (*)(id, SEL, id))objc_msgSend)(obj, sel, arg);
}
static void SendVoid2(id obj, SEL sel, id a, id b) {
    ((void (*)(id, SEL, id, id))objc_msgSend)(obj, sel, a, b);
}
static BOOL SendBOOL(id obj, SEL sel) {
    return ((BOOL (*)(id, SEL))objc_msgSend)(obj, sel);
}
static void SendVoid(id obj, SEL sel) {
    ((void (*)(id, SEL))objc_msgSend)(obj, sel);
}

@interface AlSaViewController ()
@property(nonatomic, strong) UIView *webView;
@property(nonatomic, strong) UIView *offlineView;
@end

@implementation AlSaViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.blackColor;

    // tvOS does not expose WKWebView as a public API. On a jailbroken Apple TV
    // we resolve the private WebKit class dynamically instead of importing it.
    Class webViewClass = NSClassFromString(@"WKWebView");
    Class configClass = NSClassFromString(@"WKWebViewConfiguration");

    if (!webViewClass || !configClass) {
        [self showMessage:@"Al-Sa could not find the tvOS WebKit engine."];
        return;
    }

    id configuration = [[configClass alloc] init];

    SEL initSEL = NSSelectorFromString(@"initWithFrame:configuration:");
    CGRect bounds = self.view.bounds;
    id webView = ((id (*)(id, SEL, CGRect, id))objc_msgSend)(
        [webViewClass alloc], initSEL, bounds, configuration
    );

    if (!webView) {
        [self showMessage:@"Al-Sa could not start the web engine."];
        return;
    }

    self.webView = webView;
    self.webView.frame = bounds;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.webView];

    // The private browser implementation accepts a navigation delegate through
    // the normal selector even though WebKit isn't publicly available to tvOS.
    SEL delegateSEL = NSSelectorFromString(@"setNavigationDelegate:");
    if ([self.webView respondsToSelector:delegateSEL]) {
        SendVoid1(self.webView, delegateSEL, self);
    }

    NSURL *url = [NSURL URLWithString:@"https://free-4819378.webadorsite.com/"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url
        cachePolicy:NSURLRequestUseProtocolCachePolicy
        timeoutInterval:20.0];

    SEL loadSEL = NSSelectorFromString(@"loadRequest:");
    if ([self.webView respondsToSelector:loadSEL]) {
        SendID1(self.webView, loadSEL, request);
    }

    [self updatePreferredFocus];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updatePreferredFocus];
}

- (void)updatePreferredFocus {
    if (@available(tvOS 9.0, *)) {
        [self setNeedsFocusUpdate];
        [self updateFocusIfNeeded];
    }
}

- (NSArray *)preferredFocusEnvironments {
    if (self.webView) {
        return @[self.webView];
    }
    return @[self.view];
}

// Siri Remote Menu button: behave like a browser back button.
// If there is no history, leave the page at the Al-Sa home page.
- (void)pressesBegan:(NSSet<UIPress *> *)presses withEvent:(UIPressesEvent *)event {
    for (UIPress *press in presses) {
        if (press.type == UIPressTypeMenu) {
            SEL canGoBackSEL = NSSelectorFromString(@"canGoBack");
            SEL goBackSEL = NSSelectorFromString(@"goBack");

            if (self.webView && [self.webView respondsToSelector:canGoBackSEL] &&
                SendBOOL(self.webView, canGoBackSEL) &&
                [self.webView respondsToSelector:goBackSEL]) {
                SendID(self.webView, goBackSEL);
            } else {
                NSURL *url = [NSURL URLWithString:@"https://free-4819378.webadorsite.com/"];
                NSURLRequest *request = [NSURLRequest requestWithURL:url];
                SEL loadSEL = NSSelectorFromString(@"loadRequest:");
                if (self.webView && [self.webView respondsToSelector:loadSEL]) {
                    SendID1(self.webView, loadSEL, request);
                }
            }
            continue;
        }
    }
    [super pressesBegan:presses withEvent:event];
}

// If the private web view exposes the standard navigation delegate selector,
// this gives us a clean failure message instead of a blank screen.
- (void)webView:(id)webView didFailProvisionalNavigation:(id)navigation withError:(NSError *)error {
    if (error.code == NSURLErrorNotConnectedToInternet ||
        error.code == NSURLErrorCannotFindHost ||
        error.code == NSURLErrorTimedOut) {
        [self showMessage:@"No Internet Connection\\n\\nThe Al-Sa website could not be reached."];
    }
}

- (void)showMessage:(NSString *)message {
    if (self.offlineView) {
        [self.offlineView removeFromSuperview];
    }

    UIView *panel = [[UIView alloc] initWithFrame:self.view.bounds];
    panel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    panel.backgroundColor = UIColor.blackColor;

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectInset(panel.bounds, 120, 120)];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    label.text = message;
    label.textColor = UIColor.whiteColor;
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:34 weight:UIFontWeightMedium];

    [panel addSubview:label];
    [self.view addSubview:panel];
    self.offlineView = panel;
}

@end
