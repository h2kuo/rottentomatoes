//
//  MoviesViewController.m
//  Rotten Tomatoes
//
//  Created by Helen Kuo on 2/3/15.
//  Copyright (c) 2015 Helen Kuo. All rights reserved.
//

#import "MoviesViewController.h"
#import "MovieCell.h"
#import "UIImageView+AFNetworking.h"
#import "MovieDetailsViewController.h"
#import "MBProgressHUD.h"
#import "MovieCollectionViewCell.h"

@interface MoviesViewController () <UITableViewDataSource, UITableViewDelegate, UITabBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSArray *movies;
@property (weak, nonatomic) IBOutlet UIView *networkErrorView;
@property (weak, nonatomic) IBOutlet UITabBar *tabBar;
@property (nonatomic, strong) UISegmentedControl *viewControl;
@property (weak, nonatomic) IBOutlet UICollectionView *gridView;


-(void)fetchMovies:(BOOL)showHUD;

@end

@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBar.translucent = NO;
    self.tabBar.translucent = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tabBar.delegate = self;
    [self.tabBar setSelectedItem:self.tabBar.items[0]];
    
    self.viewControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"List", @"Grid", nil]];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.viewControl];
    self.navigationItem.rightBarButtonItem = barButtonItem;
    [self.viewControl addTarget:self action:@selector(onViewChange) forControlEvents:UIControlEventValueChanged];
    [self.viewControl setSelectedSegmentIndex:0];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"MovieCell" bundle:nil] forCellReuseIdentifier:@"MovieCell"];
    
    self.tableView.rowHeight = 130;
    
    self.gridView.delegate = self;
    self.gridView.dataSource = self;
    
    [self.gridView registerNib:[UINib nibWithNibName:@"MovieCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"MovieGridCell"];
//    [self.gridView setContentInset:UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height, 0, 0, 0)];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(onRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
    
    NSLog(@"auto %d", self.automaticallyAdjustsScrollViewInsets);
    
    self.title = [self.tabBar selectedItem].title;
    [self fetchMovies:YES];
    
    
}

-(void)onViewChange {
    NSLog(@"%ld", [self.viewControl selectedSegmentIndex]);
    if ([self.viewControl selectedSegmentIndex] == 0) {
        self.tableView.hidden = NO;
        self.gridView.hidden = YES;
        [self.tableView insertSubview:self.refreshControl atIndex:0];
    } else {
        self.tableView.hidden = YES;
        self.gridView.hidden = NO;
        [self.gridView insertSubview:self.refreshControl atIndex:0];
        [self.view bringSubviewToFront:self.tabBar];
    }
}

-(void)fetchMovies:(BOOL)showHUD {
    if (showHUD) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    NSURL *url;
    if ([self.title isEqualToString:@"Movies"]) {
        NSLog(@"Movies");
        url = [NSURL URLWithString:@"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?limit=30&apikey=fpk7kfybdeu96t9sgjtgeh7q"];
    } else {
        url = [NSURL URLWithString:@"http://api.rottentomatoes.com/api/public/v1.0/lists/dvds/top_rentals.json?limit=30&apikey=fpk7kfybdeu96t9sgjtgeh7q"];
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError != nil) {
            [self.networkErrorView setHidden:NO];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self.refreshControl endRefreshing];
            return;
        }
        [self.networkErrorView setHidden:YES];
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        self.movies = responseDictionary[@"movies"];
        [self.tableView reloadData];
        [self.gridView reloadData];
        if (showHUD) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        } else {
            [self.refreshControl endRefreshing];
        }
    }];
}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    self.title = item.title;
    [self fetchMovies:YES];
}

-(void)onRefresh {
    [self fetchMovies:NO];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.movies.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MovieCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCell"];
    
    NSDictionary *movie = self.movies[indexPath.row];
    cell.posterView.image = nil;
    NSString *url = [movie valueForKeyPath:@"posters.thumbnail"];
    url = [url stringByReplacingOccurrencesOfString:@"_tmb" withString:@"_ori"];
    [cell.posterView setImageWithURL:[NSURL URLWithString:url]];
    
    cell.ratingLabel.text = [NSString stringWithFormat:@"%@%%", movie[@"ratings"][@"critics_score"]];
    if ([[movie valueForKeyPath:@"ratings.critics_rating"] isEqualToString:@"Certified Fresh"]) {
        [cell.ratingImage setImage:[UIImage imageNamed:@"tomato"]];
    } else {
        [cell.ratingImage setImage:[UIImage imageNamed:@"splat"]];
    }
    
    cell.titleLabel.text = movie[@"title"];
    
    cell.synopsisLabel.text = movie[@"synopsis"];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MovieDetailsViewController *vc = [[MovieDetailsViewController alloc] init];
    vc.movie = self.movies[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Collection methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.movies.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MovieCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MovieGridCell" forIndexPath:indexPath];
    NSDictionary *movie = self.movies[indexPath.row];
    
    NSString *url = [movie valueForKeyPath:@"posters.thumbnail"];
    url = [url stringByReplacingOccurrencesOfString:@"_tmb" withString:@"_ori"];
    cell.posterView.image = nil;
    [cell.posterView setImageWithURL:[NSURL URLWithString:url]];
    
    cell.titleLabel.text = movie[@"title"];
    cell.ratingLabel.text = [NSString stringWithFormat:@"%@%%", movie[@"ratings"][@"critics_score"]];
    if ([[movie valueForKeyPath:@"ratings.critics_rating"] isEqualToString:@"Certified Fresh"]) {
        [cell.ratingImage setImage:[UIImage imageNamed:@"tomato"]];
    } else {
        [cell.ratingImage setImage:[UIImage imageNamed:@"splat"]];
    }
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    MovieDetailsViewController *vc = [[MovieDetailsViewController alloc] init];
    vc.movie = self.movies[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
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
