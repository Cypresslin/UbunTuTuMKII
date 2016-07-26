import os
if os.getenv('LANGUAGE') == 'zh_CN':
    table = {
        'O_RDONLY': '唯讀',
        'O_WRONLY': '唯寫',
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
        # Category 
        'AddressBook': '电话本',
        'Calendar': '日程表',
        'location': '定位信息',
        'connectivity': '网络连接'
}
