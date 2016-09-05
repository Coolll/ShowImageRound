//
//  WLRoundShowView.m
//  TestShowImageRound
//
//  Created by 龙培 on 16/8/30.
//  Copyright © 2016年 龙培. All rights reserved.
//

#import "WLRoundShowView.h"
#import "SDWebImage/UIImageView+WebCache.h"

@interface WLRoundShowView ()<UIScrollViewDelegate>
/*
 *  mainScroll
 */
@property (nonatomic,strong) UIScrollView *mainScrollView;

/*
 *  left
 */
@property (nonatomic,strong) UIImageView *leftImageView;

/*
 *  middle
 */
@property (nonatomic,strong) UIImageView *middleImageView;

/*
 *  right
 */
@property (nonatomic,strong) UIImageView *rightImageView;

/*
 *  imageArray
 */
@property (nonatomic,strong) NSMutableArray *images;


/*
 *  imageURLArray
 */
@property (nonatomic,strong) NSMutableArray *imageURLs;

/*
 *  goIndex
 */
@property (nonatomic,assign) NSInteger goIndex;

/*
 *  width
 */
@property (nonatomic,assign) CGFloat singleWidth;


/*
 *  height
 */
@property (nonatomic,assign) CGFloat singleHeight;


/*
 *  lastOffset
 */
@property (nonatomic,assign) CGFloat lastXOffset;

/*
 *  isRight
 */
@property (nonatomic,assign) BOOL isRight;

/*
 *  control
 */
@property (nonatomic,strong) UIPageControl *control;

/*
 *  isLocal
 */
@property (nonatomic,assign) BOOL isLocal;




@end

@implementation WLRoundShowView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        //初始化视图
        [self loadCustomViewWithFrame:frame];
        
        //默认展示第一张图片
        self.goIndex = 0;
    
        
    }
    
    return self;
}


- (void)loadCustomViewWithFrame:(CGRect)frame
{
    
    self.singleWidth = frame.size.width;
    self.singleHeight = frame.size.height;
    
    //主ScrollView，总宽度为5个图片的宽度，依次为1，2，3，4，5，展示的卡片共有3个，依次占据2，3，4，我们命名为左、中、右，上来展示的是中间的卡片，也就是位置3，所以scrollView的偏移量为2个图片宽
    self.mainScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.singleWidth, self.singleHeight)];
    self.mainScrollView.contentOffset = CGPointMake(self.singleWidth*2, 0);
    
    //设置content大小
    self.mainScrollView.contentSize = CGSizeMake(self.singleWidth*5, self.singleHeight);

    //上次x的偏移量，当手动滑动时，判断向左还是向右滑动
    self.lastXOffset = self.singleWidth*2;
    self.mainScrollView.delegate = self;
    self.mainScrollView.pagingEnabled = YES;
    self.mainScrollView.showsVerticalScrollIndicator = NO;
    self.mainScrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:self.mainScrollView];
    
    //左卡片的点击事件
    UITapGestureRecognizer *tapLeft = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    self.leftImageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.singleWidth, 0, self.singleWidth, self.singleHeight)];
    self.leftImageView.userInteractionEnabled = YES;
    [self.leftImageView addGestureRecognizer:tapLeft];
    [self.mainScrollView addSubview:self.leftImageView];
    
    //中卡片的点击事件
    UITapGestureRecognizer *tapMiddle = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    self.middleImageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.singleWidth*2, 0, self.singleWidth, self.singleHeight)];
    self.middleImageView.userInteractionEnabled = YES;
    [self.middleImageView addGestureRecognizer:tapMiddle];
    [self.mainScrollView addSubview:self.middleImageView];
    
    //右卡片的点击事件
    UITapGestureRecognizer *tapRight = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    self.rightImageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.singleWidth*3,0, self.singleWidth, self.singleHeight)];
    self.rightImageView.userInteractionEnabled = YES;
    [self.rightImageView addGestureRecognizer:tapRight];
    [self.mainScrollView addSubview:self.rightImageView];

}

- (void)tapAction
{
    //点击后，传回当前的图片index
    if (self.delegate) {
        [self.delegate getDouchIndex:self.goIndex];
    }
}

#pragma mark - 加载定时器和点点点

- (void)loadTimerAndPageControl
{
    //pageControl
    self.control = [[UIPageControl alloc]initWithFrame:CGRectMake((self.singleWidth-100)/2, self.singleHeight-20, 100, 20)];
    
    if (self.isLocal) {
        self.control.numberOfPages = self.images.count;

    }else{
        self.control.numberOfPages = self.imageURLs.count;

    }
    self.control.currentPage = 0;
    [self addSubview:self.control];
    
    //默认切换时间为3秒，如果用户设置了，那么就用用户的
    CGFloat time = 3;
    if (self.timeIntevel > 0) {
        time = self.timeIntevel;
    }
    
    //延迟1.2秒是为了让用户看一下第一张图片，不然上来就会滚动了
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:time  target:self selector:@selector(timerGo) userInfo:nil repeats:YES];

        [timer fire];

    });
    

}

- (void)timerGo
{

    //向右滑动
    [self rightScrollAction];
    
    //滚动到右卡片
    [self.mainScrollView scrollRectToVisible:CGRectMake(self.singleWidth*3, 0, self.singleWidth, self.singleHeight) animated:YES];
    self.control.currentPage = self.goIndex;

    
    //结束滚动后，将frame调整回来
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        [self rightScrollBack];

    });

}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
    if (scrollView.contentOffset.x - self.lastXOffset >= 30 ) {
        
        //向右滚动
        [self rightScrollAction];
        
    }else if(self.lastXOffset - scrollView.contentOffset.x >= 30 ){
        
        //向左滚动
        [self leftScrollAction];
        
    }


}


//左滚动时逻辑处理
- (void)leftScrollAction
{

    //非右移
    self.isRight = NO;
    
    //当前展示的index－1
    self.goIndex = self.goIndex - 1;
    
    if (self.goIndex < 0) {
        
        
        if (self.isLocal) {
            //如果当前展示的为第一张，那么就要展示最后一张了
            self.goIndex = self.images.count -1;
            
            //设置图片
            self.leftImageView.image = self.images[self.goIndex];
        }else{
        
            self.goIndex = self.imageURLs.count-1;
            
            [self.leftImageView sd_setImageWithURL:self.imageURLs[self.goIndex]];
        }
        
        
        
    }else{
        
        
        if (self.isLocal) {
            //左侧还有，则展示前一张
            self.leftImageView.image = self.images[self.goIndex];

        }else{
        
            [self.leftImageView sd_setImageWithURL:self.imageURLs[self.goIndex]];
        }
        
        
    }
    
    //设置pageControl
    self.control.currentPage = self.goIndex;
    
    //左移时，卡片的位置的变动
    [self leftMoving];
    
    

}

//左滚动时frame处理
- (void)leftMoving
{
    
    //左卡片和中卡片不动，右卡片移动到最左侧
    
    self.leftImageView.frame = CGRectMake(self.singleWidth, 0, self.singleWidth, self.singleHeight);
    
    self.middleImageView.frame = CGRectMake(self.singleWidth*2, 0, self.singleWidth, self.singleHeight);
    
    self.rightImageView.frame = CGRectMake(0, 0, self.singleWidth, self.singleHeight);
}


//右滚动时逻辑处理
- (void)rightScrollAction
{
    
    //右滚动
    self.isRight = YES;
    
    //展示的index加1
    self.goIndex = self.goIndex + 1;
    
    if (self.isLocal) {
        
        if (self.goIndex < self.images.count) {
            
            //如果右侧有图片
            self.rightImageView.image = self.images[self.goIndex];
            
        }else{
            //如果右侧没有图片了，那么展示第一张图片
            self.goIndex = 0;
            self.rightImageView.image = self.images[self.goIndex];
            
        }
        
    }else{
    
        
        if (self.goIndex < self.imageURLs.count) {
            [self.rightImageView sd_setImageWithURL:self.imageURLs[self.goIndex]];
        }else{
        
        
            self.goIndex = 0;
            [self.rightImageView sd_setImageWithURL:self.imageURLs[self.goIndex]];
        }
    }
    
   
    
    
    
    
    //设置pageControl
    self.control.currentPage = self.goIndex;
    
    //右滚动frame处理
    [self rightMoving];

}

//右滚动时frame处理
- (void)rightMoving
{
    
    //中卡片和右卡片不动，将左卡片移动到最右侧
    
    self.leftImageView.frame = CGRectMake(self.singleWidth*4, 0, self.singleWidth, self.singleHeight);
    
    self.middleImageView.frame = CGRectMake(self.singleWidth*2, 0, self.singleWidth, self.singleHeight);
    
    self.rightImageView.frame = CGRectMake(self.singleWidth*3, 0, self.singleWidth, self.singleHeight);
}



- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    if (self.isRight) {
        
        //右回滚
        [self rightScrollBack];
        
    }else{
        
        //左回滚
        [self leftScrollBack];
        
    }

}



- (void)rightScrollBack
{
    //将左中右卡片复位
    self.leftImageView.frame = CGRectMake(self.singleWidth, 0, self.singleWidth, self.singleHeight);
    self.middleImageView.frame = CGRectMake(self.singleWidth*2, 0, self.singleWidth, self.singleHeight);
    self.rightImageView.frame = CGRectMake(self.singleWidth*3, 0, self.singleWidth, self.singleHeight);
    
    //修改图片
    self.middleImageView.image = self.rightImageView.image;
    
    if (self.isLocal) {
        
        //给左右图片赋值
        if (self.goIndex+1 >= self.imageArray.count) {
            
            self.rightImageView.image = self.images[0];
        }else{
            
            self.rightImageView.image = self.images[self.goIndex+1];
        }
        
        
        if (self.goIndex-1 >= 0) {
            
            self.leftImageView.image = self.images[self.goIndex-1];
        }else{
            
            self.leftImageView.image = [self.images lastObject];
        }

        
    }else{
    
        //给左右图片赋值
        if (self.goIndex+1 >= self.imageURLs.count) {
            
            [self.rightImageView sd_setImageWithURL:self.imageURLs[0]];
        }else{
            
            [self.rightImageView sd_setImageWithURL:self.imageURLs[self.goIndex+1]];
        }
        
        
        if (self.goIndex-1 >= 0) {
            
            [self.leftImageView sd_setImageWithURL:self.imageURLs[self.goIndex-1]];
        }else{
            
            [self.leftImageView sd_setImageWithURL:[self.imageURLs lastObject]];
        }

    }
    

    //将scroll回滚
    self.mainScrollView.contentOffset = CGPointMake(self.singleWidth*2, 0);
}

- (void)leftScrollBack
{
    //将左中右卡片复位
    self.middleImageView.frame = CGRectMake(self.singleWidth*2, 0, self.singleWidth, self.singleHeight);
    self.rightImageView.frame = CGRectMake(self.singleWidth*3, 0, self.singleWidth, self.singleHeight);
    self.leftImageView.frame = CGRectMake(self.singleWidth, 0, self.singleWidth, self.singleHeight);
    
    //设置中间显示的图片
    self.middleImageView.image = self.leftImageView.image;
    
    if (self.isLocal) {
        //给左右图片赋值
        if (self.goIndex-1 >= 0) {
            
            self.leftImageView.image = self.images[self.goIndex-1];
        }else{
            self.leftImageView.image = [self.images lastObject];
        }
        
        if (self.goIndex+1 >= self.imageArray.count) {
            
            self.rightImageView.image = self.images[0];
            
        }else{
            
            self.rightImageView.image = self.images[self.goIndex+1];
        }

    }else{
    
        //给左右图片赋值
        if (self.goIndex-1 >= 0) {
            
            [self.leftImageView sd_setImageWithURL:self.imageURLs[self.goIndex-1]];
        }else{
            [self.leftImageView sd_setImageWithURL:[self.imageURLs lastObject]];
        }
        
        if (self.goIndex+1 >= self.imageArray.count) {
            
            [self.rightImageView sd_setImageWithURL:self.imageURLs[0]];
            
        }else{
            
            [self.rightImageView sd_setImageWithURL:self.imageURLs[self.goIndex+1]];
        }

    }
    
    //scrollView回滚
    self.mainScrollView.contentOffset = CGPointMake(self.singleWidth*2, 0);
    

}




//图片源
- (void)setImageArray:(NSArray *)imageArray
{
    _imageArray = imageArray;

    self.isLocal = YES;
    
    self.images = [NSMutableArray array];
    
    for (NSString *string in imageArray) {
        
        UIImage *image = [UIImage imageNamed:string];
        
        [self.images addObject:image];
    }
    
    
    if (self.images.count == 0) {
        NSLog(@"Error:ImageArray is Nil!");
        
        return;
    }
    
    //scrollView能不能滚动
    if (self.images.count == 1) {
        
        self.middleImageView.image = self.images[0];
        
        self.mainScrollView.scrollEnabled = NO;
        
    }else{
        
        self.middleImageView.image = self.images[0];
        
    }
    
    //加载scroll
    [self loadTimerAndPageControl];
    
    
}


- (void)setUrlArray:(NSArray *)urlArray
{
    _urlArray = urlArray;
    
    self.imageURLs = [NSMutableArray array];
    
    self.isLocal = NO;

    for (NSString *urlString in urlArray) {
        
        NSURL *URL = [NSURL URLWithString:urlString];
        
        [self.imageURLs addObject:URL];
    }
    
    if (urlArray.count == 0) {
        NSLog(@"Error:ImageArray is Nil!");
        
        return;
    }
    
    //scrollView能不能滚动
    if (urlArray.count == 1) {
        
        [self.middleImageView sd_setImageWithURL:[NSURL URLWithString:[urlArray firstObject]]];
        
        self.mainScrollView.scrollEnabled = NO;
        
    }else{
        
        [self.middleImageView sd_setImageWithURL:[NSURL URLWithString:[urlArray firstObject]]];
        
    }
    
    //加载scroll
    [self loadTimerAndPageControl];
}


@end
