//
//  GDWebView.m
//  gongdanApp
//
//  Created by yuan jun on 14/12/17.
//  Copyright (c) 2014年 xuexiang. All rights reserved.
//

#import "GDWebView.h"
@interface GDWebView()<UIWebViewDelegate>
@property(nonatomic,copy)loadhtmlBlock block;
@end
@implementation GDWebView
-(void)loadHTMLString:(NSString *)string withCompletBlock:(loadhtmlBlock)finishblock{
    self.block=finishblock;
    UIWebView *web=[[UIWebView alloc] initWithFrame:self.bounds];
    self.hidden=YES;
    [web loadHTMLString:string baseURL:nil];
    web.delegate=self;
    [self addSubview:web];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    CGFloat height = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight"] floatValue];
    CGFloat height2=[[webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"] floatValue];
    CGRect frame = webView.frame;
    webView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, height);
    if (height) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.block(height<height2?height:height2);
        });
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
