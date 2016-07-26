//
//  HBChatViewController.m
//  XMPP_Chat
//
//  Created by 伍宏彬 on 15/12/10.
//  Copyright © 2015年 Wow_我了个去. All rights reserved.
//

#import "HBChatViewController.h"
#import "ChatMessage.h"
#import "HBBaseTableViewCell.h"
#import "HBChatView.h"
#import "HBChatModel.h"
#import "HBChatTableView.h"
#import "HBXMPPCoreDataManager.h"

@import MJRefresh;


@interface HBChatViewController ()<NSFetchedResultsControllerDelegate,HBChatViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
    NSFetchedResultsController *_msgFetchResult;
}
@property (strong, nonatomic) HBChatTableView *tableView;
@property (nonatomic, strong) HBChatView *chatView;
@property (nonatomic, strong) NSMutableArray *chatContents;
@property (nonatomic, strong) NSArray *indexs;

@end

@implementation HBChatViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = [[self.title componentsSeparatedByString:@"@"] firstObject];
    //1.添加tableView
    [self.view addSubview:self.tableView];
    //2.添加底部View
    [self.view addSubview:self.chatView];
    //4.获取聊天记录
    [self getRecords];

    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ChatMessage"];
        NSString *userinfo = [NSString stringWithFormat:@"%@@%@",HBXMPPMananger.xmppStream.myJID.user,HBXMPPHostName];
        NSString *friendinfo = [NSString stringWithFormat:@"%@@%@",self.title,HBXMPPHostName];
        HBChatModel *chatModel = [self.chatContents firstObject];
        NSPredicate *predicate =
        [NSPredicate predicateWithFormat:@"streamBareJidStr == %@ and bareJidStr == %@ and timestamp < %@",userinfo,friendinfo,chatModel.message.timestamp];
        request.predicate = predicate;
        
        NSSortDescriptor * sort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO];
        request.sortDescriptors = @[sort];
        request.fetchLimit = 10;
        
        NSArray *array = [[HBXMPPCoreDataManager manager].mainContext executeFetchRequest:request error:nil];
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            [array enumerateObjectsUsingBlock:^(ChatMessage *msg, NSUInteger idx, BOOL * _Nonnull stop) {
                
                HBChatModel *chatModel = [HBChatModel new];
                chatModel.message = msg;
                
                [self.chatContents insertObject:chatModel atIndex:0];
                
            }];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.tableView.mj_header endRefreshing];
                
                [self.tableView reloadData];
                
            });
        });

        
       

    }];

}

//获得聊天记录
- (void)getRecords
{
   
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ChatMessage"];
    NSString *userinfo = [NSString stringWithFormat:@"%@@%@",HBXMPPMananger.xmppStream.myJID.user,HBXMPPHostName];
    NSString *friendinfo = [NSString stringWithFormat:@"%@@%@",self.title,HBXMPPHostName];
    NSPredicate *predicate =
    [NSPredicate predicateWithFormat:@"streamBareJidStr == %@ and bareJidStr == %@ ",userinfo,friendinfo];
    request.predicate = predicate;
    request.fetchLimit = 10;
    NSSortDescriptor * sort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO];
    request.sortDescriptors = @[sort];
    
    _msgFetchResult = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[HBXMPPCoreDataManager manager].mainContext sectionNameKeyPath:nil cacheName:nil];
    _msgFetchResult.delegate = self;
    
    NSError *error = nil;
    if (![_msgFetchResult performFetch:&error]) {
        whbLog(@"chat message error - %@",error);
    }
    
    [_msgFetchResult.fetchedObjects enumerateObjectsUsingBlock:^(ChatMessage *msg, NSUInteger idx, BOOL * _Nonnull stop) {
        
        HBChatModel *chatModel = [HBChatModel new];
        chatModel.message = msg;
        [self.chatContents insertObject:chatModel atIndex:0];
        
    }];
    
    [self.tableView reloadData];
    
    if (_msgFetchResult.fetchedObjects.count)
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_msgFetchResult.fetchedObjects.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    
}
#pragma mark - UITableViewDataSource,UITableViewDelegat
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.chatContents.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    HBChatModel *chatModel = self.chatContents[indexPath.row];
    HBBaseTableViewCell *cell = [HBBaseTableViewCell baseCell:tableView cellType:chatModel.message.chatType];
    cell.chatModel = chatModel;
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HBChatModel *chatModel = self.chatContents[indexPath.row];
    return chatModel.cellHeight;
}

#pragma mark - NSFetchedResultsControllerDelegate
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeInsert:{
            
            if ([anObject isKindOfClass:[ChatMessage class]]) {
                
                HBChatModel *chatModel = [HBChatModel new];
                
                chatModel.message = anObject;
                
                [self.chatContents addObject:chatModel];
                
                [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.chatContents.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.chatContents.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                
            }

        }
            break;
        case NSFetchedResultsChangeUpdate:{
        
            if ([anObject isKindOfClass:[ChatMessage class]]) {
                
                HBChatModel *chatModel = [self.chatContents lastObject];
                
                chatModel.message = anObject;
                
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.chatContents.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
              
                
            }
        
        }
            break;
        case NSFetchedResultsChangeDelete:{
            
            
//            if ([anObject isKindOfClass:[ChatMessage class]]) {
//                
//                ChatMessage *msg = (ChatMessage *)anObject;
//                
//                HBChatModel *chatModel = [self.chatContents lastObject];
//                
//                chatModel.message = msg;
//                
//                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.chatContents.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
//                
//                
//            }
            
            
            
        }
            break;
        default:
            break;
    }
   
}

#pragma mark - HBChatViewDelegate
- (void)chatView:(HBChatView *)chatView SendText:(NSString *)content
{
    XMPPJID *toFriend = [XMPPJID jidWithUser:self.title domain:HBXMPPHostName resource:nil];
    XMPPMessage * message = [[XMPPMessage alloc] initWithType:HBTypeText to:toFriend];
    [message addBody:content];
    [HBXMPPMananger.xmppStream sendElement:message];
}
- (void)chatView:(HBChatView *)chatView recordType:(RecordType)type voiceModel:(HBVoiceModel *)model
{
    whbLog(@"SendVoice : %@",[model.path lastPathComponent]);
    switch (type) {
        case RecordTypeStar: {
            
            if ([[HBXMPPCoreDataManager manager] HB_XMPPContainsWithVoiceName:[model.path lastPathComponent]]) {//存在此数据
                return;
            }
            
            XMPPJID *toFriend = [XMPPJID jidWithUser:self.title domain:HBXMPPHostName resource:nil];
            XMPPMessage * message = [[XMPPMessage alloc] initWithType:HBTypeVoice to:toFriend];
            [message addBody:[model.path lastPathComponent]];
            [[HBXMPPCoreDataManager manager] HB_XMPPSaveChatMessage:message isOutGoing:YES];

            break;
        }
        case RecordTypeCancle: {//删除
            
            HBChatModel *chatModel = [self.chatContents lastObject];
            
            if (![chatModel.message.chatBody isEqualToString:[model.path lastPathComponent]]) {
                return;
            }
            
            [[HBXMPPCoreDataManager manager] HB_XMPPDeleteWithDate:chatModel.message.timestamp];
            
            NSIndexPath *dRow = [NSIndexPath indexPathForRow:self.chatContents.count - 1 inSection:0];
            [self.chatContents removeObject:chatModel];
            [self.tableView deleteRowsAtIndexPaths:@[dRow] withRowAnimation:UITableViewRowAnimationFade];
            
            break;
        }
        case RecordTypeFinish: {//修改
            
            HBChatModel *chatModel = [self.chatContents lastObject];
            
            if (![chatModel.message.chatBody isEqualToString:[model.path lastPathComponent]]) {
                return;
            }
            
            NSString *time = [NSString stringWithFormat:@"%@",@(model.lengthTime)];
            [[HBXMPPCoreDataManager manager] HB_XMPPUpdateVoiceDate:chatModel.message.timestamp time:time];
            
            break;
        }
    }
    
    
        
    
        
    
}
- (void)chatViewDidChangeFrame:(HBChatView *)chatView
{
//    whbLog(@"chatViewDidChangeFrame - %@",NSStringFromCGRect(chatView.frame));
    CGFloat toButtom = [UIScreen mainScreen].bounds.size.height - chatView.HB_Y;
    [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, toButtom, 0)];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.chatContents.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mark - getter
- (HBChatTableView *)tableView
{
    if (!_tableView) {
        _tableView = [[HBChatTableView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64) style:UITableViewStylePlain];
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"girl"]];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, chatViewH, 0);

    }
    return _tableView;
}
- (HBChatView *)chatView
{
    if (!_chatView) {
        _chatView = [[HBChatView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - chatViewH, [UIScreen mainScreen].bounds.size.width, chatViewH)];
        _chatView.delegate = self;
    }
    return _chatView;
}
- (NSMutableArray *)chatContents
{
    if (!_chatContents) {
        _chatContents = [NSMutableArray array];
    }
    return _chatContents;
}
- (NSArray *)indexs
{
    if (!_indexs) {
        _indexs = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:0],
                                           [NSIndexPath indexPathForRow:1 inSection:0],
                                           [NSIndexPath indexPathForRow:2 inSection:0],
                                           [NSIndexPath indexPathForRow:3 inSection:0],
                                           [NSIndexPath indexPathForRow:4 inSection:0],
                                           [NSIndexPath indexPathForRow:5 inSection:0],
                                           [NSIndexPath indexPathForRow:6 inSection:0],
                                           [NSIndexPath indexPathForRow:7 inSection:0],
                                           [NSIndexPath indexPathForRow:8 inSection:0],
                                           [NSIndexPath indexPathForRow:9 inSection:0],
                                           nil];
    }
    return _indexs;
}

@end
