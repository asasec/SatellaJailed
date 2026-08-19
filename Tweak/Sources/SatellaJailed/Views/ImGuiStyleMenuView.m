#import "ImGuiStyleMenuView.h"

// Tweak.mm içindeki FreeIAP fonksiyonunun dışarıdan çağrılabilmesi için prototipi
extern void FreeIAP(BOOL enabled);

@interface ImGuiStyleMenuView ()
@property (nonatomic, strong) UIView *titleBar;
@property (nonatomic, strong) UISwitch *masterSwitch;
@property (nonatomic, strong) UISwitch *gestureSwitch;
@property (nonatomic, strong) UISwitch *observerSwitch;
@property (nonatomic, strong) UISwitch *priceZeroSwitch;
@property (nonatomic, strong) UISwitch *receiptSwitch;
@property (nonatomic, strong) UISwitch *stealthSwitch;
@end

@implementation ImGuiStyleMenuView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        // --- Ana Mod Menü Penceresi ---
        self.menuWindow = [[UIView alloc] initWithFrame:CGRectMake(50, 80, 280, 320)];
        self.menuWindow.backgroundColor = [UIColor colorWithRed:0.08 green:0.08 blue:0.10 alpha:0.97];
        self.menuWindow.layer.cornerRadius = 16.0;
        self.menuWindow.layer.borderWidth = 1.5;
        self.menuWindow.layer.borderColor = [UIColor colorWithRed:0.30 green:0.60 blue:1.00 alpha:1.0].CGColor;
        self.menuWindow.layer.shadowColor = [UIColor blackColor].CGColor;
        self.menuWindow.layer.shadowOffset = CGSizeMake(0, 8);
        self.menuWindow.layer.shadowOpacity = 0.5;
        self.menuWindow.layer.shadowRadius = 10.0;
        self.menuWindow.clipsToBounds = NO;
        self.menuWindow.hidden = YES;
        [self addSubview:self.menuWindow];

        UIPanGestureRecognizer *menuPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleMenuPan:)];
        [self.menuWindow addGestureRecognizer:menuPan];

        // --- Başlık Çubuğu ---
        self.titleBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 40)];
        self.titleBar.backgroundColor = [UIColor colorWithRed:0.85 green:0.20 blue:0.20 alpha:1.0]; // Başlangıçta Kırmızı (Kapalı)
        
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.titleBar.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(16.0, 16.0)];
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.path = maskPath.CGPath;
        self.titleBar.layer.mask = maskLayer;
        [self.menuWindow addSubview:self.titleBar];

        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, 200, 40)];
        titleLabel.text = @"🐻 SATELLA - MOD MENU";
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:13];
        [self.titleBar addSubview:titleLabel];

        // Kapatma / Küçültme [X] Butonu
        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        closeBtn.frame = CGRectMake(240, 8, 24, 24);
        [closeBtn setTitle:@"✕" forState:UIControlStateNormal];
        [closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        closeBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [closeBtn addTarget:self action:@selector(minimizeMenu) forControlEvents:UIControlEventTouchUpInside];
        [self.titleBar addSubview:closeBtn];

        // --- Ana Özellik: FreeIAP (Master Switch) ---
        UILabel *masterText = [[UILabel alloc] initWithFrame:CGRectMake(16, 55, 170, 24)];
        masterText.text = @"FreeIAP (Master Switch)";
        masterText.textColor = [UIColor whiteColor];
        masterText.font = [UIFont boldSystemFontOfSize:13];
        [self.menuWindow addSubview:masterText];

        self.masterSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(210, 52, 0, 0)];
        self.masterSwitch.isOn = NO;
        [self.masterSwitch setOnTintColor:[UIColor colorWithRed:0.20 green:0.80 blue:0.20 alpha:1.0]]; // Yeşil
        [self.masterSwitch addTarget:self action:@selector(masterSwitchChanged:) forControlEvents:UIControlEventValueChanged];
        [self.menuWindow addSubview:self.masterSwitch];

        // --- Diğer Alt Hooklar / Özellikler ---
        CGFloat startY = 95;
        CGFloat spacing = 40;
        
        self.gestureSwitch = [self createRowWithTitle:@"3-Finger Gesture" yPosition:startY];
        self.observerSwitch = [self createRowWithTitle:@"Observer Hook" yPosition:startY + spacing];
        self.priceZeroSwitch = [self createRowWithTitle:@"0,00 Price Hook" yPosition:startY + (spacing * 2)];
        self.receiptSwitch = [self createRowWithTitle:@"Receipt Bypass" yPosition:startY + (spacing * 3)];
        self.stealthSwitch = [self createRowWithTitle:@"Stealth Mode" yPosition:startY + (spacing * 4)];

        // --- Yüzen Ayı Simgesi ---
        self.floatingIcon = [UIButton buttonWithType:UIButtonTypeSystem];
        self.floatingIcon.frame = CGRectMake(40, 100, 54, 54);
        self.floatingIcon.backgroundColor = [UIColor colorWithRed:0.10 green:0.10 blue:0.13 alpha:0.92];
        [self.floatingIcon setTitle:@"🐻" forState:UIControlStateNormal];
        self.floatingIcon.titleLabel.font = [UIFont systemFontOfSize:28];
        self.floatingIcon.layer.cornerRadius = 27.0;
        self.floatingIcon.layer.borderWidth = 2.0;
        self.floatingIcon.layer.borderColor = [UIColor colorWithRed:0.30 green:0.60 blue:1.00 alpha:1.0].CGColor;
        self.floatingIcon.layer.shadowColor = [UIColor blackColor].CGColor;
        self.floatingIcon.layer.shadowOffset = CGSizeMake(0, 4);
        self.floatingIcon.layer.shadowOpacity = 0.6;
        self.floatingIcon.layer.shadowRadius = 8.0;
        self.floatingIcon.hidden = NO;
        [self.floatingIcon addTarget:self action:@selector(restoreMenu) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.floatingIcon];

        UIPanGestureRecognizer *iconPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleIconPan:)];
        [self.floatingIcon addGestureRecognizer:iconPan];
    }
    return self;
}

// Yardımcı Satır Oluşturucu
- (UISwitch *)createRowWithTitle:(NSString *)title yPosition:(CGFloat)y {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, y, 180, 24)];
    label.text = title;
    label.textColor = [UIColor colorWithWhite:0.90 alpha:1.0];
    label.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    [self.menuWindow addSubview:label];

    UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(210, y - 2, 0, 0)];
    sw.isOn = NO;
    [sw setOnTintColor:[UIColor colorWithRed:0.20 green:0.60 blue:1.00 alpha:1.0]];
    [self.menuWindow addSubview:sw];
    return sw;
}

// Arkaya Tıklama Optimizasyonu (Hit-Testing)
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self) {
        return nil; // Boşluklar arkadaki oyuna tıklama geçirir
    }
    return hitView;
}

- (void)handleMenuPan:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self];
    CGPoint center = gesture.view.center;
    gesture.view.center = CGPointMake(center.x + translation.x, center.y + translation.y);
    [gesture setTranslation:CGPointZero inView:self];
}

- (void)handleIconPan:(UIPanGestureRecognizer -> *)gesture {
    CGPoint translation = [gesture translationInView:self];
    CGPoint center = gesture.view.center;
    gesture.view.center = CGPointMake(center.x + translation.x, center.y + translation.y);
    [gesture setTranslation:CGPointZero inView:self];
}

- (void)minimizeMenu {
    self.menuWindow.hidden = YES;
    self.floatingIcon.center = self.menuWindow.center;
    self.floatingIcon.hidden = NO;
}

- (void)restoreMenu {
    self.floatingIcon.hidden = YES;
    self.menuWindow.center = self.floatingIcon.center;
    self.menuWindow.hidden = NO;
}

// Master Switch Kontrolü (FreeIAP)
- (void)masterSwitchChanged:(UISwitch *)sender {
    BOOL isOn = sender.isOn;
    
    // 1. Başlık çubuğu rengini güncelle (Açıksa Yeşil, Kapalıysa Kırmızı)
    if (isOn) {
        self.titleBar.backgroundColor = [UIColor colorWithRed:0.15 green:0.75 blue:0.15 alpha:1.0]; // Yeşil
    } else {
        self.titleBar.backgroundColor = [UIColor colorWithRed:0.85 green:0.20 blue:0.20 alpha:1.0]; // Kırmızı
    }
    
    // 2. Tüm alt hookları Master Switch durumuna göre aç / kapat
    [self.gestureSwitch setOn:isOn animated:YES];
    [self.observerSwitch setOn:isOn animated:YES];
    [self.priceZeroSwitch setOn:isOn animated:YES];
    [self.receiptSwitch setOn:isOn animated:YES];
    [self.stealthSwitch setOn:isOn animated:YES];
    
    // 3. Tweak.mm içindeki FreeIAP fonksiyonunu tetikle
    FreeIAP(isOn);
}

@end
