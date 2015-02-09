//
//  MovieDetailsViewController.m
//  Rotten Tomatoes
//
//  Created by Helen Kuo on 2/7/15.
//  Copyright (c) 2015 Helen Kuo. All rights reserved.
//

#import "MovieDetailsViewController.h"
#import "UIImageView+AFNetworking.h"

@interface MovieDetailsViewController ()

@end

@implementation MovieDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSString *url = [self.movie valueForKeyPath:@"posters.thumbnail"];
    url = [url stringByReplacingOccurrencesOfString:@"_tmb" withString:@"_ori"];
    [self.posterView setImageWithURL:[NSURL URLWithString:url]];
    
    self.titleLabel.text = self.movie[@"title"];
    
    self.synopsisLabel.text = self.movie[@"synopsis"];

    self.title = self.movie[@"title"];
    
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.synopsisLabel sizeToFit];
    
    CGRect contentRect = CGRectUnion(self.synopsisLabel.frame, self.titleLabel.frame);
    
    self.scrollView.contentSize = contentRect.size;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
