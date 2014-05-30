//
//  M2ViewController.m
//  m2048
//
//  Created by Danqing on 3/16/14.
//  Copyright (c) 2014 Danqing. All rights reserved.
//

#import "M2ViewController.h"
#import "M2Scene.h"
#import "M2GameManager.h"
#import "M2Overlay.h"
#import "M2GridView.h"

@interface M2ViewController ()

@property (nonatomic, strong) UILabel *labelBestScoreTitle;
@property (nonatomic, strong) UILabel *labelBestScore;

@property (nonatomic, strong) UILabel *labelScoreTitle;
@property (nonatomic, strong) UILabel *labelScore;

@end

@implementation M2ViewController {
    IBOutlet UIButton *_restartButton;

    M2Scene *_scene;

    IBOutlet M2Overlay *_overlay;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self __makeView];

    [self updateState];

    self.labelBestScoreTitle.text = @"best:";
    self.labelBestScore.text      = [NSString stringWithFormat:@"%ld", (long)[Settings integerForKey:@"Best Score"]];

    self.labelScoreTitle.text = @"score:";
    self.labelScore.text      = @"0000";

    _overlay.hidden = YES;

    // Configure the view.
    SKView *skView = (SKView *)self.view;

    // Create and configure the scene.
    M2Scene *scene = [M2Scene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;

    // Present the scene.
    [skView presentScene:scene];
    [self updateScore:0];
    [scene startNewGame];

    _scene          = scene;
    _scene.delegate = self;
}

- (void)updateState
{
    _overlay.message.font                = [UIFont systemFontOfSize:36];
    _overlay.keepPlaying.titleLabel.font = [UIFont systemFontOfSize:17];
    _overlay.restartGame.titleLabel.font = [UIFont systemFontOfSize:17];

    _overlay.message.textColor = [UIColor grayColor];
    [_overlay.keepPlaying setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_overlay.restartGame setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
}

- (void)updateScore:(NSInteger)score
{
    self.labelScore.text = [NSString stringWithFormat:@"%ld", (long)score];
    if ([Settings integerForKey:@"Best Score"] < score) {
        [Settings setInteger:score forKey:@"Best Score"];
        self.labelBestScore.text = [NSString stringWithFormat:@"%ld", (long)score];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Pause Sprite Kit. Otherwise the dismissal of the modal view would lag.
    ((SKView *)self.view).paused = YES;
}

- (IBAction)restart:(id)sender
{
    [self hideOverlay];
    [self updateScore:0];
    [_scene startNewGame];
}

- (IBAction)keepPlaying:(id)sender
{
    [self hideOverlay];
}

- (IBAction)done:(UIStoryboardSegue *)segue
{
    ((SKView *)self.view).paused = NO;
    if (GSTATE.needRefresh) {
        [GSTATE loadGlobalState];
        [self updateState];
        [self updateScore:0];
        [_scene startNewGame];
    }
}

- (void)endGame:(BOOL)won
{
    _overlay.hidden = NO;

    if (!won) {
        _overlay.keepPlaying.hidden = YES;
        _overlay.message.text       = @"Game Over";
    } else {
        _overlay.keepPlaying.hidden = NO;
        _overlay.message.text       = @"You Win!";
    }

    // Center the overlay in the board.
    CGFloat   verticalOffset = [[UIScreen mainScreen] bounds].size.height - GSTATE.verticalOffset;
    NSInteger side           = GSTATE.dimension * GSTATE.tileSize;
    _overlay.center = CGPointMake(side / 2, verticalOffset - side / 2);

    NSLog(@"x %f y %f", _overlay.center.x, _overlay.center.y);

    [UIView animateWithDuration:0.5 delay:1.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
         //_overlayBackground.alpha = 1;
     } completion:^(BOOL finished) {
         // Freeze the current game.
         ((SKView *)self.view).paused = YES;
     }];
}

- (void)hideOverlay
{
    ((SKView *)self.view).paused = NO;
    if (!_overlay.hidden) {
        [UIView animateWithDuration:0.5 animations:^{
             //_overlayBackground.alpha = 0;
         } completion:^(BOOL finished) {
             _overlay.hidden = YES;
         }];
    }
}

#pragma mark - Make View

- (void)__makeView
{
    [self __createLabelBestScoreTitle];
    [self __createLabelBestScore];
    [self __createLabelScoreTitle];
    [self __createLabelScore];

    [self __addConstraints];
}

- (void)__createLabelBestScoreTitle
{
    const CGFloat colorComp = 222.0 / 255.0;
    const CGFloat kFontSize = 12.0;

    UIColor *labelColor = [UIColor colorWithRed:colorComp green:colorComp blue:colorComp alpha:1.0];
    UIFont  *labelFont  = [UIFont fontWithName:@"HelveticaNeue-Light" size:kFontSize];

    UILabel *label = [[UILabel alloc] init];
    label.font            = labelFont;
    label.backgroundColor = [UIColor clearColor];
    label.textColor       = labelColor;
    label.textAlignment   = NSTextAlignmentLeft;

    label.translatesAutoresizingMaskIntoConstraints = NO;

    self.labelBestScoreTitle = label;
    [self.view addSubview:self.labelBestScoreTitle];
}

- (void)__createLabelBestScore
{
    const CGFloat colorComp = 222.0 / 255.0;
    const CGFloat kFontSize = 27.0;

    UIColor *labelColor = [UIColor colorWithRed:colorComp green:colorComp blue:colorComp alpha:1.0];
    UIFont  *labelFont  = [UIFont fontWithName:@"HelveticaNeue-Light" size:kFontSize];

    UILabel *label = [[UILabel alloc] init];
    label.font            = labelFont;
    label.backgroundColor = [UIColor clearColor];
    label.textColor       = labelColor;
    label.textAlignment   = NSTextAlignmentLeft;

    label.translatesAutoresizingMaskIntoConstraints = NO;

    self.labelBestScore = label;
    [self.view addSubview:self.labelBestScore];
}

- (void)__createLabelScoreTitle
{
    const CGFloat colorComp = 222.0 / 255.0;
    const CGFloat kFontSize = 12.0;

    UIColor *labelColor = [UIColor colorWithRed:colorComp green:colorComp blue:colorComp alpha:1.0];
    UIFont  *labelFont  = [UIFont fontWithName:@"HelveticaNeue-Light" size:kFontSize];

    UILabel *label = [[UILabel alloc] init];
    label.font            = labelFont;
    label.backgroundColor = [UIColor clearColor];
    label.textColor       = labelColor;
    label.textAlignment   = NSTextAlignmentRight;

    label.translatesAutoresizingMaskIntoConstraints = NO;

    self.labelScoreTitle = label;
    [self.view addSubview:self.labelScoreTitle];
}

- (void)__createLabelScore
{
    const CGFloat colorComp = 222.0 / 255.0;
    const CGFloat kFontSize = 27.0;

    UIColor *labelColor = [UIColor colorWithRed:colorComp green:colorComp blue:colorComp alpha:1.0];
    UIFont  *labelFont  = [UIFont fontWithName:@"HelveticaNeue-Light" size:kFontSize];

    UILabel *label = [[UILabel alloc] init];
    label.font            = labelFont;
    label.backgroundColor = [UIColor clearColor];
    label.textColor       = labelColor;
    label.textAlignment   = NSTextAlignmentRight;

    label.translatesAutoresizingMaskIntoConstraints = NO;

    self.labelScore = label;
    [self.view addSubview:self.labelScore];
}

#pragma mark - Constraints

- (void)__addConstraints
{
    [self __constraintLabelBestTitle];
    [self __constraintLabelBestScore];

    [self __constraintLabelScoreTitle];
    [self __constraintLabelScore];
}

- (void)__constraintLabelBestTitle
{
    const CGFloat kOffset = 20.0;

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.labelBestScoreTitle
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1.0f
                                                           constant:kOffset]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.labelBestScoreTitle
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1.0f
                                                           constant:60.0]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.labelBestScoreTitle
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0f
                                                           constant:kOffset]];
}

- (void)__constraintLabelBestScore
{
    const CGFloat kOffset = 20.0;

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.labelBestScore
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1.0f
                                                           constant:kOffset]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.labelBestScore
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1.0f
                                                           constant:60.0]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.labelBestScore
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.labelBestScoreTitle
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0f
                                                           constant:kOffset / 4]];
}

- (void)__constraintLabelScoreTitle
{
    const CGFloat kOffset = 20.0;

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.labelScoreTitle
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1.0f
                                                           constant:60.0]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.labelScoreTitle
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1.0f
                                                           constant:-kOffset]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.labelScoreTitle
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0f
                                                           constant:kOffset]];
}

- (void)__constraintLabelScore
{
    const CGFloat kOffset = 20.0;

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.labelScore
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1.0f
                                                           constant:80.0]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.labelScore
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1.0f
                                                           constant:-kOffset]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.labelScore
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.labelScoreTitle
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0f
                                                           constant:kOffset / 4]];
}

@end
