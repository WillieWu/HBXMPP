//
//  HBChatViewController.m
//  XMPP_Chat
//
//  Created by 伍宏彬 on 15/12/10.
//  Copyright © 2015年 Wow_我了个去. All rights reserved.
//

#import "HBChatViewController.h"
#import "XMPPMessageArchivingCoreDataStorage.h"
#import "HBBaseTableViewCell.h"
#import "HBChatView.h"
#import "HBChatModel.h"
#import "HBChatTableView.h"
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

static int chatViewH = 44;

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
        

        NSManagedObjectContext *context = [XMPPMessageArchivingCoreDataStorage sharedInstance].mainThreadManagedObjectContext;
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
        NSString *userinfo = [NSString stringWithFormat:@"%@@%@",HBXMPPMananger.xmppStream.myJID.user,HBXMPPHostName];
        NSString *friendinfo = [NSString stringWithFormat:@"%@@%@",self.title,HBXMPPHostName];
        HBChatModel *chatModel = [self.chatContents firstObject];
        NSPredicate *predicate =
        [NSPredicate predicateWithFormat:@"streamBareJidStr == %@ and bareJidStr == %@ and timestamp < %@",userinfo,friendinfo,chatModel.message.timestamp];
        request.predicate = predicate;
        
        NSSortDescriptor * sort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO];
        request.sortDescriptors = @[sort];
        request.fetchLimit = 10;
        
        NSArray *array = [context executeFetchRequest:request error:nil];

        [array enumerateObjectsUsingBlock:^(XMPPMessageArchiving_Message_CoreDataObject *msg, NSUInteger idx, BOOL * _Nonnull stop) {
            
            HBChatModel *chatModel = [HBChatModel new];
            chatModel.message = msg;

            [self.chatContents insertObject:chatModel atIndex:0];
            
        }];
        [self.tableView.mj_header endRefreshing];
     
        [self.tableView reloadData];

    }];

}

//与某个好友聊天
- (BOOL)talkToFriend:(NSString *)friendsName andMsg:(NSString *)msg
{
    XMPPJID *toFriend = [XMPPJID jidWithUser:friendsName domain:HBXMPPHostName resource:nil];
    XMPPMessage * message = [[XMPPMessage alloc] initWithType:@"chat" to:toFriend];
    [message addBody:msg];

    [HBXMPPMananger.xmppStream sendElement:message];
    return YES;
}
//获得聊天记录
- (void)getRecords
{
   
    NSManagedObjectContext *context = [XMPPMessageArchivingCoreDataStorage sharedInstance].mainThreadManagedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
    NSString *userinfo = [NSString stringWithFormat:@"%@@%@",HBXMPPMananger.xmppStream.myJID.user,HBXMPPHostName];
    NSString *friendinfo = [NSString stringWithFormat:@"%@@%@",self.title,HBXMPPHostName];
    NSPredicate *predicate =
    [NSPredicate predicateWithFormat:@"streamBareJidStr == %@ and bareJidStr == %@ ",userinfo,friendinfo];
    request.predicate = predicate;
    request.fetchLimit = 10;
    NSSortDescriptor * sort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO];
    request.sortDescriptors = @[sort];
    
    _msgFetchResult = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    _msgFetchResult.delegate = self;
    
    NSError *error = nil;
    if (![_msgFetchResult performFetch:&error]) {
        whbLog(@"chat message error - %@",error);
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
       
        [_msgFetchResult.fetchedObjects enumerateObjectsUsingBlock:^(XMPPMessageArchiving_Message_CoreDataObject *msg, NSUInteger idx, BOOL * _Nonnull stop) {
            
            HBChatModel *chatModel = [HBChatModel new];
            chatModel.message = msg;
            [self.chatContents insertObject:chatModel atIndex:0];
            
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.tableView reloadData];
            
            if (_msgFetchResult.fetchedObjects.count)
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_msgFetchResult.fetchedObjects.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        });
        
    });
    
    
}
#pragma mark - UITableViewDataSource,UITableViewDelegat
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.chatContents.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    HBChatModel *chatModel = self.chatContents[indexPath.row];
    HBBaseTableViewCell *cell = [HBBaseTableViewCell baseCell:tableView cellType:chatModel.message.messageStr];
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
        case NSFetchedResultsChangeInsert:
        {
            
            if ([anObject isKindOfClass:[XMPPMessageArchiving_Message_CoreDataObject class]]) {
                
                HBChatModel *chatModel = [HBChatModel new];
                
                chatModel.message = anObject;
                
                [self.chatContents addObject:chatModel];
                
                [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.chatContents.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.chatContents.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                
            }

        }
            break;
            
        default:
            break;
    }
   
}

#pragma mark - HBChatViewDelegate
- (void)chatView:(HBChatView *)chatView chickSend:(NSString *)content
{
    [self talkToFriend:self.title andMsg:content];
}
- (void)chatViewDidChangeFrame:(HBChatView *)chatView
{
    whbLog(@"chatViewDidChangeFrame - %@",NSStringFromCGRect(chatView.frame));
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
