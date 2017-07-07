//
//  ViewController.m
//  ZSortCollectionView
//
//  Created by ZhangBob on 07/07/2017.
//  Copyright © 2017 Jixin. All rights reserved.
//

#import "ViewController.h"
#import "ZChannelsSort.h"
#import "ZDemoSortView.h"

#define KScreenSize         ([[UIScreen mainScreen] bounds].size)
#define KScreenWidth        ([[UIScreen mainScreen] bounds].size.width)
#define KScreenHeight       ([[UIScreen mainScreen] bounds].size.height)

@interface ViewController ()

@property (nonatomic, strong) ZChannelsSort *sortView;
@property (nonatomic, strong) ZDemoSortView *demoSortView;
@property (nonatomic, assign) BOOL sortViewShow;
@property (nonatomic, assign) BOOL demoSortViewShow;

@property (nonatomic, strong) UIButton *demo1;
@property (nonatomic, strong) UIButton *demo2;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"排序";
    self.view.backgroundColor = [UIColor whiteColor];
    [self __setup];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"➕" style:UIBarButtonItemStylePlain target:self action:@selector(rightAction:)];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)__setup {
    self.sortViewShow = NO;
    self.demoSortViewShow = NO;
    [self.view addSubview:self.demo1];
    [self.view addSubview:self.demo2];
}

- (ZChannelsSort *)sortView {
    if (!_sortView) {
        _sortView = [[ZChannelsSort alloc] init];
        __weak typeof (self)weakSelf = self;
        _sortView.channelsSortBlock = ^(NSDictionary *sortedChannels) {
            NSLog(@"sortedChannels");
            [weakSelf wrtieSortedChannelsToLocalWith:sortedChannels];
        };
        _sortView.hideSortViewBlock = ^{
            _sortViewShow = NO;
        };
    }
    return _sortView;
}

- (ZDemoSortView *)demoSortView {
    if (!_demoSortView) {
        _demoSortView = [[ZDemoSortView alloc] initWithFrame:self.view.bounds];
        _demoSortView.backgroundColor = [UIColor whiteColor];
        __weak typeof (self)weakSelf = self;
        _demoSortView.hideBlock =
        _demoSortView.doneBlock = ^{
            weakSelf.demoSortViewShow = NO;
            [weakSelf.demoSortView removeFromSuperview];
        };
    }
    return _demoSortView;
}

- (UIButton *)demo1 {
    if (!_demo1) {
        _demo1 = [UIButton buttonWithType:UIButtonTypeSystem];
        _demo1.frame = CGRectMake(0, 100, KScreenWidth, 50);
        [_demo1 setTitle:@"《今日头条》频道排序" forState:UIControlStateNormal];
        [_demo1 addTarget:self
                   action:@selector(rightAction:)
         forControlEvents:UIControlEventTouchUpInside];
    }
    return _demo1;
}

- (UIButton *)demo2 {
    if (!_demo2) {
        _demo2 = [UIButton buttonWithType:UIButtonTypeSystem];
        _demo2.frame = CGRectMake(0, 170, KScreenWidth, 50);
        [_demo2 setTitle:@"通用的可排序的collectionView" forState:UIControlStateNormal];
        [_demo2 addTarget:self
                   action:@selector(demo2ButtonAction:)
         forControlEvents:UIControlEventTouchUpInside];
    }
    return _demo2;
}

#pragma action

- (void)leftAction:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"alert" message:@"导航栏左侧按钮" delegate:self cancelButtonTitle:@"cancel" otherButtonTitles: nil];
    [alert show];
}

- (IBAction)demo2ButtonAction:(id)sender {
    self.demoSortViewShow = YES;
    [self.view addSubview:self.demoSortView];
}

- (IBAction)rightAction:(id)sender {
    if (_demoSortViewShow) {
        [self.demoSortView removeFromSuperview];
        _demoSortViewShow = NO;
        return;
    }
    _sortViewShow = !_sortViewShow;
    if (_sortViewShow) {
        NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
        NSString *path = paths.firstObject;
        NSString *filename=[path stringByAppendingPathComponent:@"json.plist"];
        NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:filename];
        
        NSMutableArray *pickedChannels = [NSMutableArray array];
        NSMutableArray *unpickedChannels = [NSMutableArray array];
        
        if (dic) {
            pickedChannels = [NSMutableArray arrayWithArray:[dic valueForKey:@"picked"]];
            
            unpickedChannels = [NSMutableArray arrayWithArray:[dic valueForKey:@"unpicked"]];
        } else {
            NSString *path1 = [[NSBundle mainBundle] pathForResource:@"channels" ofType:@"json"];
            
            NSData *data = [NSData dataWithContentsOfFile:path1];
            
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            NSArray *items = [response valueForKey:@"items"];
            for (NSDictionary *item in items) {
                NSNumber *value = [item valueForKey:@"is_selected"];
                if (value.boolValue) {
                    [pickedChannels addObject:item];
                } else {
                    [unpickedChannels addObject:item];
                }
            }
        }
        
        NSDictionary *channels = @{@"picked" : pickedChannels,
                                   @"unpicked" : unpickedChannels};
        [self.sortView sortChannelsAtViewController:self WithDictionary:channels];
        
    } else {
        [self.sortView hideSortView];
        self.sortView = nil;
    }
}

- (void)wrtieSortedChannelsToLocalWith:(NSDictionary *)dic {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
        NSString *path = paths.firstObject;
        NSString *filename=[path stringByAppendingPathComponent:@"json.plist"];
        
        NSFileManager* fm = [NSFileManager defaultManager];
        [fm createFileAtPath:filename contents:nil attributes:nil];
        [dic writeToFile:filename atomically:YES];
    });
}



@end
