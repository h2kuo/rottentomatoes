//
//  MovieCollectionViewCell.h
//  Rotten Tomatoes
//
//  Created by Helen Kuo on 2/7/15.
//  Copyright (c) 2015 Helen Kuo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MovieCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *posterView;
@property (weak, nonatomic) IBOutlet UIImageView *ratingImage;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;

@end
