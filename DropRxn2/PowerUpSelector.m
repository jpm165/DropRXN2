//
//  PowerUpSelector.m
//  DropRxn2
//
//  Created by James Mundie on 12/19/16.
//  Copyright © 2016 James Mundie. All rights reserved.
//

#import "PowerUpSelector.h"
#import "JMHelpers.h"
#import "PowerUp.h"

@interface PowerUpSelector () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *powerUpsArray;

@end

@implementation PowerUpSelector

-(id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.powerUpsArray = @[@"1", @"2", @"3", @"4", @"5", @"6"];
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) collectionViewLayout:flowLayout];
        [self.collectionView setDelegate:self];
        [self.collectionView setDataSource:self];
        self.collectionView.backgroundColor = [UIColor clearColor];
        [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"powerUpCellIdentifier"];
        [self addSubview:self.collectionView];
    }
    return self;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.powerUpsArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"powerUpCellIdentifier" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundView = nil;
    //cell.opaque = NO;
    CGRect circleFrame = CGRectMake(CGRectGetMidX(cell.bounds)-[JMHelpers circleRadius]/2, CGRectGetMidY(cell.bounds)-[JMHelpers circleRadius]/2, [JMHelpers circleRadius], [JMHelpers circleRadius]);
    PowerUp *c = [[PowerUp alloc] initWithFrame:circleFrame borderWidth:[JMHelpers borderWidth]];
    [c setNumber:@(8)];
    c.delegate = [JMGameManager sharedInstance].activeGameController;
    if (indexPath.row==1) {
        c.type = kPowerUpTypeDecrementAllGreys;
    } else {
        c.type = kPowerUpTypeRemoveAllNext;
    }
    c.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [cell.contentView addSubview:c];
    
    
    
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake([JMHelpers circleRadius], [JMHelpers circleRadius]);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
