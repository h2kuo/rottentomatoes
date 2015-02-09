//
//  MovieDetailsViewController.h
//  Rotten Tomatoes
//
//  Created by Helen Kuo on 2/7/15.
//  Copyright (c) 2015 Helen Kuo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MovieDetailsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *synopsisLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIImageView *posterView;

@property (nonatomic, strong) NSDictionary *movie;


@end
