import os

# Potential issue: string might overlap with some other events when this tool
# become more and more complicated, like the "open" string.
table = {
    # File actions for "open" event
    'O_RDONLY': '读取',
    'O_WRONLY': '写入',
    'O_RDWR': '读写',
    # File action for 'unlink' event
    'unlink': '删除',
    # Events
    'updateContacts': '修改数据',
    'removeContacts': '删除数据',
    'createContact': '建立数据',
    'contactsDetails': '读取数据',
    'CreateObjects': '建立数据',
    'RemoveObjects': '删除数据',
    'ModifyObjects': '修改数据',
    'GetObjectList': '读取数据',
    'StartPositionUpdates': '开始进行定位',
    'StopPositionUpdates': '停止进行定位',
    'MobileDataEnabled': '开关移动网络',
    'DataRoamingEnabled': '开关数据漫游',
    'QueryEvents': '查询事件',
    'RemoveEvents': '移除事件',
    # Category
    'AddressBook': '电话本',
    'Calendar': '日程表',
    'location': '定位信息',
    'connectivity': '移动网络',
    'connect': '网络连接',
    'HistoryService': '历史纪录', 
    # Camera actions
    'open': '开啟',
    'closed': '关闭',
    # Audio actions
    'IDLE': '闲置',
    'RUNNING': '进行中'
}

def i18n(result):
    if os.getenv('LANGUAGE') == 'zh_CN':
        if result in table:
            result = table[result]
    return result
