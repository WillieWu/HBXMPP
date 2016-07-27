# HBXMPP
---
####2016.7.27 补充小功能

![小菜单](http://7xnt2l.com1.z0.glb.clouddn.com/copy.gif)


---

![效果图](http://7xnt2l.com1.z0.glb.clouddn.com/drag2.gif)

######先看看项目结构图
![结构图](http://upload-images.jianshu.io/upload_images/620797-bd1511df0c191cc4.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

#####本文主要分三部分
* 数据存储 (coredata)
* 聊天内容搭建与计算
* 聊天底部tabbar工具栏

######1.`数据存储`

  `数据存储`这块也是图一个方便，直接用的xmpp框架内部数据存储`coredata`，所以也就仅仅用到那几个字段，大概的实现了主体部分。

   而正由于这个原因，**在进入聊天界面，加载聊天历史记录的时候，界面UI有些许卡顿，**加载的有些慢，影响用户体验。

自己实现`coredata`的话，聊天控制器中**查询聊天历史记录**那部分，直接把放在`异步线程`去操作，保持`主线程`更新数据就行了。（以后有时间就把这块代码加在项目中）

######2.`聊天内容搭建与计算`

内容这个也没多少说的，有个小属性可以注意下

```
  _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
  
```

效果就是这样子

![drag](http://7xnt2l.com1.z0.glb.clouddn.com/drag5.gif)


主要就说下`HBChatModel`


这个就是聊天内容的数据模型。里面就有设置`文本、图片、语音、地图`等一些`HBBaseTableViewCell`的frame。有了这个，就直接拿到`HBChatViewController`控制器设置对应的参数即可，不需要再去做额外多余的计算了。


项目中实际用到这块的话，这块最好计算一次后，就将`HBBaseTableViewCell`高度缓存到`caredata`中。第二次就直接取，不用费劲计算了。Demo中每次实例化`HBChatModel`对象，都需要计算。


```

- (void)setMessage:(XMPPMessageArchiving_Message_CoreDataObject *)message
{
    _message = message;
    
    CGSize getChatBgSize;

    if ([message.messageStr isEqualToString:HBTypeText]){//聊天文字内容

        //聊天，表情字符串
        self.chatContent = [message.body HB_StringToChatAttributeString];
        
        CGSize size = [HBHelp HB_attributeBoundsSize:CGSizeMake(HBChatBgMaxWidth,MAXFLOAT) attributeContentText:[self.chatContent mutableCopy]];
//        //1.文字内容大小
        self.textSize = size;
        
        getChatBgSize = CGSizeMake(size.width + 2 * padding, size.height);
    
    }else if ([message.messageStr isEqualToString:HBTypeImage]){//图片
            
        self.imageSize = CGSizeMake(120, 60);
        
        getChatBgSize = CGSizeMake(self.imageSize.width + 2 * padding, self.imageSize.height + 2 * padding);
        
    }else if ([message.messageStr isEqualToString:HBTypeVoice]){//语音
        
    }else if ([message.messageStr isEqualToString:HBTypeMap]){//地图
        
    }
    
    //2.聊天背景大小
    self.chatBgSize = getChatBgSize;
    //3.行高
    self.cellHeight = self.chatBgSize.height + HBUserIconImageToTop + HBUserIconImageWH + HBChatBgToUserIconImage + HBUserIconImageToTop;;
    
    
}

```
就一个 `setter`方法。


`带表情聊天内容转换成文字内容`

```

- (NSString *)HB_ChatAttributeStringToString
{
    __block NSMutableString *chatStr = [NSMutableString string];
    [self enumerateAttributesInRange:NSMakeRange(0, self.length)
                                                     options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                                                  usingBlock:^(NSDictionary<NSString *,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
                                                      
              HBTextAttachment *hbAttachment = [attrs objectForKey:@"NSAttachment"];
              if (hbAttachment) {
                  
                  [chatStr appendString:[NSString stringWithFormat:@"[/%@]",hbAttachment.emjoysName]];
                  
              }else{
                  NSAttributedString *aStr = [self attributedSubstringFromRange:range];
                  
                  [chatStr appendString:aStr.string];
              }
    }];
    return [chatStr copy];
}

```


`文字内容转换成带表情的内容`

```
- (NSAttributedString *)HB_StringToChatAttributeString
{
    static dispatch_once_t onceToken;
    static NSRegularExpression *regularExpression;
    dispatch_once(&onceToken, ^{
        regularExpression = [NSRegularExpression regularExpressionWithPattern:@"\\[[a-zA-Z0-9\\u4e00-\\u9fa5/]+\\]"
                                                                      options:NSRegularExpressionCaseInsensitive
                                                                        error:nil];
    });
   
    NSMutableAttributedString *AttributeString = [[NSMutableAttributedString alloc] initWithString:self];
    
    [AttributeString setAttributes:@{NSFontAttributeName : chatTextFont}
                             range:NSMakeRange(0, AttributeString.length)];

    NSArray *array = [regularExpression matchesInString:self options:NSMatchingReportCompletion range:NSMakeRange(0, self.length)];
    
    
    [array enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult *result, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *emjoyStr = [self substringWithRange:result.range];//[/001]
        
        NSRange range = [emjoyStr rangeOfString:@"[/"];
        NSUInteger loc = range.location + range.length;
        NSUInteger len = [emjoyStr rangeOfString:@"]"].location;
        
        NSString *emjoyName = [emjoyStr substringWithRange:NSMakeRange(loc, len - loc)];//001
        
        HBTextAttachment *textAtt = [HBTextAttachment new];
        textAtt.emjoysName = emjoyName;
        UIImage *image = [UIImage imageNamed:textAtt.emjoysName];
        textAtt.image = image;
        
        NSAttributedString *imageAttribute = [NSAttributedString attributedStringWithAttachment:textAtt];
        [AttributeString replaceCharactersInRange:result.range withAttributedString:imageAttribute];
        
    }];
    return AttributeString;
    
}

```
######3.`聊天底部tabbar工具栏`

`HBChatView`
这个写的也就是最纠结的地方。按钮的各种逻辑，状态，调了好久。体力活可真是体力活

各种监听

 ```
 
#pragma mark - Custom
- (void)keyboardNotifacation{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    //5.监听文本变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewTextChange:) name:UITextViewTextDidChangeNotification object:self.textView];
    
    [self.textView addObserver:self forKeyPath:@"attributedText" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
    [self.textView addObserver:self forKeyPath:@"inputView" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
    //6.监听自身frame
    [self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    
}


```


```

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"frame"]) {
        
        if ([self.delegate respondsToSelector:@selector(chatViewDidChangeFrame:)]) {
            [self.delegate chatViewDidChangeFrame:self];
        }
        _newFrame = [[change objectForKey:@"new"] CGRectValue];
        
    }else if ([keyPath isEqualToString:@"attributedText"]){
        
        [self caclulaterTextViewHeight];
        
    }else if ([keyPath isEqualToString:@"inputView"]) {
    
        HBEmjoyView *emjoyView = [change objectForKey:@"new"];

        [UIView animateWithDuration:0.25 animations:^{
                
            CGFloat moveHeight = ((NSNull *)emjoyView == [NSNull null]) ? 258 : emjoyView.HB_H;
            
            self.HB_Y = [UIScreen mainScreen].bounds.size.height - moveHeight - self.HB_H;
        }];
        
    }else{
        
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        
    }
}

```

多纠结，你自己看图说话😂😂

![纠结图](http://upload-images.jianshu.io/upload_images/620797-84ebfbfbcc713f0e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


计算  `textView`高度

```
- (void)caclulaterTextViewHeight{
    
    NSString *context = [self.textView.attributedText HB_ChatAttributeStringToString];
    
    if (![context hasSuffix:@"\n"] && context.length > 0) {

//        CGFloat getSysHeight = [self.textView sizeThatFits:CGSizeMake(self.textView.HB_W, MAXFLOAT)].height;
        CGFloat getHeight = [HBHelp HB_attributeBoundsSize:CGSizeMake(self.textView.HB_W, MAXFLOAT)
                  attributeContentText:[[context HB_StringToChatAttributeString] mutableCopy]].height;

        if (getHeight <= _originaTextViewH) {
            
            self.textView.HB_H = _originaTextViewH;
            
        }else{
            //1.限制最大高度
            if (getHeight >= _originaButtomViewH * 2) {
                getHeight = _originaButtomViewH * 2;
            }
            self.textView.HB_H = getHeight;
        }
        
        self.HB_H = self.textView.HB_H + self.textView.HB_Y * 2;
        self.HB_Y -= self.HB_H - _lastH;
        //2.始终更新最后的状态
        [self layoutIfNeeded];
        
        _lastButtomFrame = self.frame;
        _lastTextViewFrame = self.textView.frame;
        
    }
    
}
```
#####结语
这个项目也就提供大概的思路，但是大概的方向都是有了的。
后期有时间，会继续完善项目中细节的。

>如果这个文章帮到了你，一定给我`Star`哦！

>[GitHub](https://github.com/WillieWu/HBDrawingBoardDemo.git) **欢迎围观**！


