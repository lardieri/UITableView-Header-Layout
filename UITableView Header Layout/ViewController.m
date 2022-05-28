//
//  ViewController.m
//  UITableView Header Layout
//

#import "ViewController.h"



// For a good time, try different combinations!
const BOOL autoLayout = NO;
const BOOL stackView = NO;



@interface ViewController () <UITableViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, readwrite) UITableView * tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Create the table view.
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];

    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor]
    ]];
}

- (void)viewDidLayoutSubviews
{
    // Wait until the table view has non-zero measurements before adding the header. This avoids noisy Auto Layout warnings about unsatisfiable constraints.
    if (!self.tableView.tableHeaderView) {
        [self addHeader];
    }
}

- (void)addHeader
{
    // The order of the following operations is important!

    // First, create the header.
    UIView * header;
    if (stackView) {
        header = [self makeStackViewHeader];
    } else {
        header = [self makeHeader];
    }

    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    tap.numberOfTapsRequired = 1;
    tap.delegate = self;
    tap.cancelsTouchesInView = NO; // Required for child tableviews to work correctly
    tap.name = @"Single-tap";
    [header addGestureRecognizer:tap];

    // Second, set the header's frame with the correct height.
    // Since the header's children determine its height, make sure the necessary constraints between the header and its children are set up by now.
    if (autoLayout) {
        // If you *are* using Auto Layout, force a layout pass to make Auto Layout calculate a frame with the correct height.
        header.translatesAutoresizingMaskIntoConstraints = NO;
        [header setNeedsLayout];
        [header layoutIfNeeded];
    } else {
        // If you're *not* using Auto Layout, fill in the frame yourself.
        // Height must be correct; don't worry about the other elements, they will get overwritten.
        CGFloat height = [header systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        CGRect frameWithHeight = CGRectMake(0.0, 0.0, 0.0, height);
        header.frame = frameWithHeight;
        header.translatesAutoresizingMaskIntoConstraints = YES;
    }

    // Third, set the tableHeaderView property. The property setter is magic; it does three things:
    // A) The table view adds the header as a subview.
    // B) The table view looks at the header's frame.height property and adjusts the cells down to make room. The table view only looks at the header's height in this one place, so if it ever changes, you have to re-set tableHeaderView to run the magic property setter again.
    // C) The table view adjusts the origin and width of the header's frame to position it at the top of the table view and stretch it across the entire width. The table view continues to adjust the header's frame whenever its own bounds get updated. Even if you are *not* using Auto Layout, note that your autoresizeMask gets ignored.
    self.tableView.tableHeaderView = header;

    // Fourth, if you *are* using Auto Layout, create constraints between the header and the table view for position and width. Auto Layout assumes it owns the header's entire frame (all 4 elements), so it overwrites the values for origin and width that the UITableView puts into the header view's frame. You need to add constraints that duplicate what the UITableView is doing. But you can't activate these constraints until the header is part of the table view's hierarchy or you will crash.
    if (autoLayout) {
        [NSLayoutConstraint activateConstraints:@[
            [header.topAnchor constraintEqualToAnchor:self.tableView.topAnchor],
            [header.leadingAnchor constraintEqualToAnchor:self.tableView.leadingAnchor],
            [header.widthAnchor constraintEqualToAnchor:self.tableView.widthAnchor]
        ]];
    }
}

- (void)handleGesture:(nonnull UIGestureRecognizer *)recognizer
{
    [self addHeader];
}

- (UIView *)makeHeader
{
    UIView * header = [[UIView alloc] initWithFrame:CGRectZero];
    header.backgroundColor = UIColor.cyanColor;
    header.accessibilityIdentifier = @"header";

    UILabel * label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.text = @"Tap to resize me!";
    CGFloat fontSize = 2 * arc4random_uniform(30) + 6.0;
    label.font = [UIFont systemFontOfSize:fontSize];
    label.textAlignment = NSTextAlignmentLeft;
    label.backgroundColor = UIColor.yellowColor;
    [header addSubview:label];

    UIView * separator = [[UIView alloc] initWithFrame:CGRectZero];
    separator.translatesAutoresizingMaskIntoConstraints = NO;
    separator.backgroundColor = UIColor.darkGrayColor;
    separator.accessibilityIdentifier = @"separator";
    [header addSubview:separator];

    [NSLayoutConstraint activateConstraints:@[
        [label.topAnchor constraintEqualToSystemSpacingBelowAnchor:header.topAnchor multiplier:1.0],
        [label.leadingAnchor constraintEqualToSystemSpacingAfterAnchor:header.leadingAnchor multiplier:1.0],
        [header.trailingAnchor constraintEqualToSystemSpacingAfterAnchor:label.trailingAnchor multiplier:1.0],

        [separator.topAnchor constraintEqualToSystemSpacingBelowAnchor:label.bottomAnchor multiplier:1.0],

        [separator.leadingAnchor constraintEqualToAnchor:header.leadingAnchor],
        [separator.trailingAnchor constraintEqualToAnchor:header.trailingAnchor],
        [separator.heightAnchor constraintEqualToConstant:1.0],
        [separator.bottomAnchor constraintEqualToAnchor:header.bottomAnchor]
    ]];

    return header;
}

- (UIView *)makeStackViewHeader
{
    UIStackView * header = [[UIStackView alloc] initWithFrame:CGRectZero];
    header.axis = UILayoutConstraintAxisVertical;
    header.alignment = UIStackViewAlignmentFill;
    header.distribution = UIStackViewDistributionFill;
    header.spacing = 8.0;

    UIEdgeInsets margins = UIEdgeInsetsMake(0.0, 20.0, 0.0, 0.0);
    header.layoutMargins = margins;
    header.layoutMarginsRelativeArrangement = YES;

    UIView * spacer = [[UIView alloc] initWithFrame:CGRectZero];
    spacer.backgroundColor = UIColor.cyanColor;
    spacer.translatesAutoresizingMaskIntoConstraints = NO;
    [spacer setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisVertical];
    [header addArrangedSubview:spacer];

    UILabel * label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.backgroundColor = UIColor.yellowColor;
    label.text = @"Tap to resize me!";
    CGFloat fontSize = 2 * arc4random_uniform(30) + 6.0;
    label.font = [UIFont systemFontOfSize:fontSize];
    label.textAlignment = NSTextAlignmentLeft;
    [label setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
    [label setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [header addArrangedSubview:label];

    UIView * separator = [[UIView alloc] initWithFrame:CGRectZero];
    separator.translatesAutoresizingMaskIntoConstraints = NO;
    separator.backgroundColor = UIColor.darkGrayColor;
    [separator setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [separator.heightAnchor constraintEqualToConstant:1.0].active = YES;
    [header addArrangedSubview:separator];

    return header;
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    return cell;
}

@end
