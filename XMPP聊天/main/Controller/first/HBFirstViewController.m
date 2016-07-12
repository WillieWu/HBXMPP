//
//  HBFirstViewController.m
//  XMPP_Chat
//
//  Created by 伍宏彬 on 15/12/9.
//  Copyright © 2015年 Wow_我了个去. All rights reserved.
//

#import "HBFirstViewController.h"
#import "HBXMPP.h"
#import "HBChatViewController.h"
#import "UIStoryboard+HBStoryboard.h"
@import MJRefresh;


@interface HBFirstViewController ()<XMPPRosterDelegate,NSFetchedResultsControllerDelegate,UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    NSFetchedResultsController *_friendFetchResult;

}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) UIButton *addBtn;//account_add
@end

@implementation HBFirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //1.设置bar两边按钮
    [self setBarBtn];
    
    //2.设置花名册
    [self setXMPPRoster];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
       
        NSManagedObjectContext *context= [XMPPRosterCoreDataStorage sharedInstance].mainThreadManagedObjectContext;
        NSFetchRequest *request= [[NSFetchRequest alloc]initWithEntityName:@"XMPPUserCoreDataStorageObject"];
        
        //    //对结果进行排序
        NSSortDescriptor *sort=[NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
        request.sortDescriptors=@[sort];
        
        //设置谓词过滤(把自己去掉 关系)
        NSPredicate *pre=[NSPredicate predicateWithFormat:@"displayName != %@ AND subscription = 'both'",HBXMPPMananger.xmppStream.myJID.user];
        request.predicate= pre;
        whbLog(@"NSPredicate - %@,%@",HBXMPPMananger.xmppStream.myJID,HBXMPPMananger.xmppStream.myJID.user);
        _friendFetchResult = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
        
        
        _friendFetchResult.delegate = self;
        NSError *error = nil;
        
        if (![_friendFetchResult performFetch:&error]) {
            whbLog(@"出错:%@",error);
        }
        [self.tableView.mj_header endRefreshing];
    }];
    
    [self.tableView.mj_header beginRefreshing];
    
}
- (void)setBarBtn
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.addBtn];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"下 线" style:UIBarButtonItemStylePlain target:self action:@selector(outLogin:)];
}
- (void)setXMPPRoster
{
    [HBXMPPMananger.xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [HBXMPPMananger.xmppRoster fetchRoster];
}
- (void)outLogin:(UIBarButtonItem *)leftItem
{
    BOOL isConnect = [HBXMPPMananger.xmppStream isConnected];
    if (isConnect) {
        //登出（下线）
        [HBXMPPMananger disConnectServer];
        [self.navigationItem.leftBarButtonItem setTitle:@"上 线"];
    }else{
        //登录或者注册
        [HBXMPPMananger connectServer:@"zs"
                             password:@"zs"
                  connectActionOption:ConnectActionOptionLogin
                          ServerStatu:^(XMPPStream *sender, resultOption result) {
            
        }];
        [self.navigationItem.leftBarButtonItem setTitle:@"下 线"];
    }
    
        
}
- (void)addFriends
{
    UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:@"添加好友" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    
    alterView.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [alterView show];
}
- (void)searchFriends:(NSString *)name
{
    XMPPJID *jid = [XMPPJID jidWithUser:name domain:HBXMPPHostName resource:nil];
    [HBXMPPMananger.xmppRoster addUser:jid withNickname:nil];
}
#pragma mark - NSFetchedResultsControllerDelegate
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    whbLog(@"好友列表 - didChangeObject");
}
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];
}
#pragma mark - UITableViewDataSource,UITableViewDelegat
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _friendFetchResult.fetchedObjects.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *searchID = @"searchID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:searchID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:searchID];
    }
    XMPPUserCoreDataStorageObject *user = _friendFetchResult.fetchedObjects[indexPath.row];

    cell.detailTextLabel.text = user.nickname;
    cell.textLabel.text = user.displayName;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XMPPUserCoreDataStorageObject *user = _friendFetchResult.fetchedObjects[indexPath.row];

    HBChatViewController *chatVc = (HBChatViewController *)[UIStoryboard HB_StoryboardWithVcID:@"HBChatViewController"];
    chatVc.title = user.displayName;
    [self.navigationController pushViewController:chatVc animated:YES];

}
#pragma mark - XMPPRosterDelegate
- (void)xmppRosterDidBeginPopulating:(XMPPRoster *)sender withVersion:(NSString *)version
{
    whbLog(@"xmppRosterDidBeginPopulating");
}
- (void)xmppRosterDidEndPopulating:(XMPPRoster *)sender
{
     whbLog(@"xmppRosterDidEndPopulating");
}
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
     whbLog(@"didReceivePresenceSubscriptionRequest");
    // 好友在线状态
    NSString *type = [presence type];
    // 发送请求者
    NSString *fromUser = [[presence from] user];
    // 接收者id
    NSString *user = HBXMPPMananger.xmppStream.myJID.user;
    
    whbLog(@"接收到好友请求状态：%@   发送者：%@  接收者：%@", type, fromUser, user);

    // 防止自己添加自己为好友
    if (![fromUser isEqualToString:user]) {
        if ([type isEqualToString:@"subscribe"]) { // 添加好友
            // 接受添加好友请求,发送type=@"subscribed"表示已经同意添加好友请求并添加到好友花名册中
            [HBXMPPMananger.xmppRoster acceptPresenceSubscriptionRequestFrom:[XMPPJID jidWithString:fromUser]
                                                andAddToRoster:YES];
            whbLog(@"已经添加对方为好友");
        } else if ([type isEqualToString:@"unsubscribe"]) { // 请求删除好友
            
            
        }
        
    }

}
- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterItem:(DDXMLElement *)item
{
    //去掉自己
    NSString *receiveJid = [item attributeStringValueForName:@"name"];
    if ([receiveJid isEqualToString:HBXMPPMananger.xmppStream.myJID.user]) return;
    
    NSString *subscription = [item attributeStringValueForName:@"subscription"];
    if ([subscription isEqualToString:@"both"]) {
        whbLog(@"已经是互为好友 - %@",receiveJid);
    }
}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *name = [[alertView textFieldAtIndex:0] text];
    
    if (!name.length) return;
    
    if (buttonIndex == 1) {
        
        [self searchFriends:name];
        
    }
}
- (UIButton *)addBtn
{
    if (!_addBtn) {
        _addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _addBtn.frame = CGRectMake(0, 0, 50, 30);
        [_addBtn setImage:[UIImage imageNamed:@"account_add"] forState:UIControlStateNormal];
        [_addBtn addTarget:self action:@selector(addFriends) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addBtn;
}
@end
