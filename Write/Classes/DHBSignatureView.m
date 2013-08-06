//
//  DHBSignatureView.m
//  Write
//
//  Created by David Brunow on 8/5/13.
//  Copyright (c) 2013 David Brunow. All rights reserved.
//

#import "DHBSignatureView.h"

@implementation DHBSignatureView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.signatureImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Texas"]];
        self.signatureLabel = [[UILabel alloc] init];
    }
    return self;
}

-(void)layoutSubviews
{
    [self.signatureLabel setFrame:CGRectMake(0, 50, self.frame.size.width, 100)];
    [self.signatureLabel setText:@"Designed and Developed in Texas by\n\nDavid Brunow\thttp:\\\\brunow.org"];
    [self.signatureLabel setNumberOfLines:0];
    [self.signatureLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:11.0]];
    [self.signatureLabel setTextAlignment:NSTextAlignmentCenter];

    [self.signatureImageView setFrame:CGRectMake((self.frame.size.width - 40) / 2, 30, 40, 40)];
    
    [self addSubview:self.signatureImageView];
    [self addSubview:self.signatureLabel];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
